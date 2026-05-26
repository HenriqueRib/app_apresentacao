import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/voice_volume_calibration.dart';
import '../services/storage_service.dart';
import '../services/voice_volume_calibrator.dart';

enum VolumeTestState { idle, listening, calibrating, error }

class VoiceVolumeTestProvider extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  VolumeTestState _state = VolumeTestState.idle;
  bool _hasMicPermission = true;
  String? _errorMessage;
  double _rawCurrentDb = 0;
  double _rawAvgDb = 0;
  final List<double> _samples = [];
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  String? _tempPath;
  VoiceVolumeCalibration? _calibration;
  Timer? _idealZoneTimer;
  Timer? _calibrationTimer;
  Timer? _calibrationSafetyTimer;
  bool _calibrationFinishing = false;
  double _idealSecondsHeld = 0;
  final List<double> _calibrationSamples = [];

  static const int idealVolumeGoalSeconds = defaultIdealVolumeGoalSeconds;

  VolumeTestState get state => _state;
  bool get hasMicPermission => _hasMicPermission;
  String? get errorMessage => _errorMessage;
  double get currentDb => _adjustedCurrentDb;
  double get avgDb => _adjustedAvgDb;
  bool get isListening => _state == VolumeTestState.listening;
  bool get isCalibrating => _state == VolumeTestState.calibrating;
  VoiceVolumeCalibration? get calibration => _calibration;
  double get idealSecondsHeld => _idealSecondsHeld;
  bool get goalReached => _idealSecondsHeld >= idealVolumeGoalSeconds;

  double get _adjustedCurrentDb =>
      applyCalibration(_rawCurrentDb, _calibration);

  double get _adjustedAvgDb => applyCalibration(_rawAvgDb, _calibration);

  VolumeZone get currentZone => classifyVolumeZone(_adjustedCurrentDb);
  VolumeZone get avgZone => classifyVolumeZone(_adjustedAvgDb);

  Future<bool> initialize() async {
    _hasMicPermission = await _recorder.hasPermission();
    if (!_hasMicPermission) {
      _state = VolumeTestState.error;
      _errorMessage = 'Permissão de microfone negada.';
      notifyListeners();
      return false;
    }

    final storage = await StorageService.getInstance();
    _calibration = await storage.getVolumeCalibration();
    notifyListeners();
    return true;
  }

  Future<void> start() async {
    if (_state == VolumeTestState.listening) return;

    final ready = await initialize();
    if (!ready) return;

    _samples.clear();
    _rawCurrentDb = 0;
    _rawAvgDb = 0;
    _idealSecondsHeld = 0;
    _errorMessage = null;

    try {
      await _beginRecording();
      _state = VolumeTestState.listening;
      _startIdealZoneTimer();
      notifyListeners();
    } catch (e) {
      _state = VolumeTestState.error;
      _errorMessage = 'Erro ao iniciar teste: $e';
      notifyListeners();
    }
  }

  Future<void> startCalibration() async {
    if (_state == VolumeTestState.calibrating ||
        _state == VolumeTestState.listening) {
      return;
    }

    final ready = await initialize();
    if (!ready) return;

    _calibrationSamples.clear();
    _errorMessage = null;

    try {
      await _beginRecording();
      _state = VolumeTestState.calibrating;
      notifyListeners();

      _calibrationTimer?.cancel();
      _calibrationSafetyTimer?.cancel();
      _calibrationTimer = Timer(const Duration(seconds: 5), () async {
        await _finishCalibration();
      });
      _calibrationSafetyTimer = Timer(const Duration(seconds: 8), () async {
        if (_state == VolumeTestState.calibrating) {
          await _finishCalibration();
        }
      });
    } catch (e) {
      _state = VolumeTestState.error;
      _errorMessage = 'Erro na calibração: $e';
      notifyListeners();
    }
  }

  /// Libera gravador e estado se o usuário sair durante calibração/escuta.
  Future<void> cancelActiveSession() async {
    _idealZoneTimer?.cancel();
    _calibrationTimer?.cancel();
    _calibrationSafetyTimer?.cancel();
    if (_state == VolumeTestState.calibrating ||
        _state == VolumeTestState.listening) {
      await _stopRecordingInternal();
      _state = VolumeTestState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _finishCalibration() async {
    if (_calibrationFinishing || _state != VolumeTestState.calibrating) {
      return;
    }
    _calibrationFinishing = true;
    _calibrationTimer?.cancel();
    _calibrationSafetyTimer?.cancel();
    await _stopRecordingInternal();

    try {
      if (_calibrationSamples.isEmpty) {
        _state = VolumeTestState.error;
        _errorMessage = 'Não foi possível medir o volume. Tente novamente.';
        notifyListeners();
        return;
      }

      final referenceDb = _calibrationSamples.reduce((a, b) => a + b) /
          _calibrationSamples.length;
      final calibration = buildCalibration(referenceDb);
      final storage = await StorageService.getInstance();
      await storage.saveVolumeCalibration(calibration);
      _calibration = calibration;
      _state = VolumeTestState.idle;
      notifyListeners();
    } finally {
      _calibrationFinishing = false;
    }
  }

  Future<void> clearCalibration() async {
    final storage = await StorageService.getInstance();
    await storage.clearVolumeCalibration();
    _calibration = null;
    notifyListeners();
  }

  Future<void> stop() async {
    _idealZoneTimer?.cancel();
    _calibrationTimer?.cancel();
    _calibrationSafetyTimer?.cancel();
    await _stopRecordingInternal();
    _state = VolumeTestState.idle;
    notifyListeners();
  }

  Future<void> _beginRecording() async {
    final dir = await getTemporaryDirectory();
    _tempPath =
        '${dir.path}/volume_test_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _tempPath!,
    );

    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription =
        _recorder.onAmplitudeChanged(const Duration(milliseconds: 150)).listen(
      (amp) {
        _rawCurrentDb = amp.current;
        _samples.add(amp.current);
        if (_samples.length > 120) {
          _samples.removeAt(0);
        }
        if (_samples.isNotEmpty) {
          _rawAvgDb = _samples.reduce((a, b) => a + b) / _samples.length;
        }

        if (_state == VolumeTestState.calibrating) {
          _calibrationSamples.add(amp.current);
        }

        notifyListeners();
      },
    );
  }

  Future<void> _stopRecordingInternal() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    if (_tempPath != null) {
      final file = File(_tempPath!);
      if (file.existsSync()) {
        await file.delete();
      }
      _tempPath = null;
    }
  }

  void _startIdealZoneTimer() {
    _idealZoneTimer?.cancel();
    _idealZoneTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_state != VolumeTestState.listening) return;
      if (currentZone == VolumeZone.ideal) {
        _idealSecondsHeld += 0.2;
        if (_idealSecondsHeld > idealVolumeGoalSeconds) {
          _idealSecondsHeld = idealVolumeGoalSeconds.toDouble();
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _idealZoneTimer?.cancel();
    _calibrationTimer?.cancel();
    _calibrationSafetyTimer?.cancel();
    _amplitudeSubscription?.cancel();
    unawaited(_stopRecordingInternal());
    _recorder.dispose();
    super.dispose();
  }
}

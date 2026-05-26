import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/speech.dart';
import '../models/voice_rehearsal.dart';
import '../models/voice_rehearsal_attempt.dart';
import '../models/voice_rehearsal_next_focus.dart';
import '../models/voice_rehearsal_session_prefs.dart';
import '../models/voice_rehearsal_smart_flags.dart';
import '../models/voice_rehearsal_weekly_goal.dart';
import '../models/voice_recording.dart';
import '../models/voice_teleprompter_section.dart';
import '../models/voice_volume_calibration.dart';
import '../services/characteristics_service.dart';
import '../services/storage_service.dart';
import '../services/voice_analysis_engine.dart';
import '../services/voice_coach_focus_filter.dart';
import '../services/voice_filler_words_service.dart';
import '../services/voice_outline_teleprompter_builder.dart';
import '../services/voice_rehearsal_topic_helper.dart';
import '../services/voice_recording_transcriber.dart';
import '../services/voice_session_checkpoint.dart';
import '../services/voice_volume_calibrator.dart';

enum VoiceRehearsalState { idle, recording, stopped, error }

enum VoiceSessionPhase { idle, countdown, warmup, recording, stopped }

const int kWarmupDurationSeconds = 45;

class VoiceRehearsalProvider extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceAnalysisEngine _engine = VoiceAnalysisEngine();
  final _uuid = const Uuid();

  VoiceRehearsalState _state = VoiceRehearsalState.idle;
  VoiceSessionMode? _sessionMode;
  bool _hasMicPermission = true;
  bool _speechAvailable = false;
  String? _errorMessage;
  String? _recordingPath;
  Timer? _sessionTimer;
  Timer? _checkpointTimer;
  Timer? _sttRestartTimer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  int _elapsedSeconds = 0;
  VoiceRehearsalSummary? _summary;
  final List<VoiceFeedbackEvent> _liveEvents = [];
  bool _sessionActive = false;
  bool _teardownInProgress = false;
  bool _sttRestartInProgress = false;
  DateTime? _lastSttRestartAt;
  String? _sessionTopic;
  VoiceVolumeCalibration? _volumeCalibration;
  bool _isAnalyzingRecording = false;
  bool _isPaused = false;
  final VoiceRecordingTranscriber _transcriber = VoiceRecordingTranscriber();
  VoiceRehearsalSessionPrefs _sessionPrefs = VoiceRehearsalSessionPrefs.defaults;
  VoiceRehearsalSmartFlags _smartFlags = VoiceRehearsalSmartFlags.defaults;
  VoiceRehearsalNextFocus? _nextFocus;
  VoiceSessionPhase _sessionPhase = VoiceSessionPhase.idle;
  VoiceSessionMode? _pendingSessionMode;
  bool _isWarmupPhase = false;
  String? _seriesName;
  String? _linkedSpeechId;
  List<VoiceTeleprompterSection> _teleprompterSections = const [];
  String? _sessionMilestoneBanner;
  String? _smartPauseBanner;
  final Set<String> _firedMilestones = {};
  int _lastHapticFillerCount = 0;
  bool _lastHapticWpmOutOfRange = false;
  final List<({int charId, DateTime at})> _recentAlertTimes = [];
  Timer? _notifyDebounceTimer;
  Timer? _metricsDebounceTimer;

  /// Atualiza só métricas/relógio (evita rebuild do feed a cada segundo).
  final ChangeNotifier metricsListenable = ChangeNotifier();

  /// Atualiza feed, dicas, características e banners.
  final ChangeNotifier contentListenable = ChangeNotifier();

  VoiceRehearsalState get state => _state;
  String? get sessionTopic => _sessionTopic;
  VoiceSessionMode? get sessionMode => _sessionMode;
  bool get hasMicPermission => _hasMicPermission;
  bool get speechAvailable => _speechAvailable;
  String? get errorMessage => _errorMessage;
  String? get recordingPath => _recordingPath;
  int get elapsedSeconds => _elapsedSeconds;
  VoiceRehearsalMetrics get metrics => _engine.metrics;
  VoiceRehearsalSummary? get summary => _summary;
  List<VoiceFeedbackEvent> get liveEvents => List.unmodifiable(_liveEvents);
  List<VoiceImprovementInsight> get insights => filteredInsights;
  List<VoiceImprovementInsight> get rawInsights => _engine.insights;
  double get liveScore => _engine.liveScore;
  double? get displayScore =>
      _isWarmupPhase ? null : (_summary?.metrics.liveScore ?? _engine.liveScore);
  List<VoiceFeedbackEvent> get filteredLiveEvents =>
      VoiceCoachFocusFilter.filterEvents(
        _liveEvents,
        coachFocusEnabled: _smartFlags.coachFocusEnabled,
        mode: _smartFlags.coachFocusMode,
      );
  List<VoiceImprovementInsight> get filteredInsights =>
      VoiceCoachFocusFilter.filterInsights(
        _engine.insights,
        coachFocusEnabled: _smartFlags.coachFocusEnabled,
        mode: _smartFlags.coachFocusMode,
        minimalCoach: _smartFlags.minimalCoachEnabled,
      );
  String get fullTranscript => _engine.fullTranscript;
  bool get isRecording => _state == VoiceRehearsalState.recording;
  bool get isTrainingMode => _sessionMode == VoiceSessionMode.training;
  bool get isAnalyzingRecording => _isAnalyzingRecording;
  bool get isPaused => _isPaused;
  VoiceRehearsalSessionPrefs get sessionPrefs => _sessionPrefs;
  int? get durationGoalSeconds => _sessionPrefs.durationGoalSeconds;
  bool get focusMode => _sessionPrefs.focusMode;
  bool get hasVolumeCalibration => _volumeCalibration != null;
  VoiceRehearsalSmartFlags get smartFlags => _smartFlags;
  VoiceRehearsalNextFocus? get nextFocus => _nextFocus;
  VoiceSessionPhase get sessionPhase => _sessionPhase;
  bool get isWarmupPhase => _isWarmupPhase;
  bool get needsCountdown =>
      _sessionPhase == VoiceSessionPhase.countdown;
  String? get sessionMilestoneBanner => _sessionMilestoneBanner;
  String? get smartPauseBanner => _smartPauseBanner;
  String? get seriesName => _seriesName;
  String? get linkedSpeechId => _linkedSpeechId;
  List<VoiceTeleprompterSection> get teleprompterSections =>
      _teleprompterSections;

  void setSeriesName(String? name) {
    final trimmed = name?.trim();
    _seriesName = trimmed != null && trimmed.isNotEmpty ? trimmed : null;
    _notifyAll();
  }

  void setSessionTopic(String? topic) {
    final trimmed = topic?.trim();
    _sessionTopic = trimmed != null && trimmed.isNotEmpty ? trimmed : null;
    _notifyAll();
  }

  Future<void> loadSessionPrefs() async {
    final storage = await StorageService.getInstance();
    _sessionPrefs = await storage.getVoiceRehearsalSessionPrefs();
    await loadSmartFlags();
    _notifyAll();
  }

  Future<void> loadSmartFlags() async {
    final storage = await StorageService.getInstance();
    _smartFlags = await storage.getVoiceRehearsalSmartFlags();
    _nextFocus = await storage.getVoiceRehearsalNextFocus();
    final linkedId = await storage.getVoiceRehearsalLinkedSpeechId();
    if (linkedId != null) {
      _linkedSpeechId = linkedId;
    }
    _notifyAll();
  }

  Future<void> updateSmartFlags(VoiceRehearsalSmartFlags flags) async {
    _smartFlags = flags;
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalSmartFlags(flags);
    if (flags.weeklyGoalEnabled) {
      final goal = await storage.getVoiceRehearsalWeeklyGoal();
      if (!goal.enabled) {
        await storage.setVoiceRehearsalWeeklyGoal(goal.copyWith(enabled: true));
      }
    }
    _notifyAll();
  }

  Future<void> linkSpeech(Speech? speech) async {
    final storage = await StorageService.getInstance();
    if (speech == null) {
      _linkedSpeechId = null;
      _teleprompterSections = const [];
      await storage.setVoiceRehearsalLinkedSpeechId(null);
      _notifyAll();
      return;
    }
    _linkedSpeechId = speech.id;
    _teleprompterSections =
        VoiceOutlineTeleprompterBuilder.fromOutline(speech.outline);
    final topic = speech.title.trim().isNotEmpty
        ? speech.title.trim()
        : speech.theme.trim();
    if (topic.isNotEmpty) {
      setSessionTopic(topic);
    }
    if (_sessionPrefs.durationGoalSeconds == null) {
      final goalSeconds = speech.type == SpeechType.student10min ? 360 : 600;
      await setDurationGoalSeconds(goalSeconds);
    }
    await storage.setVoiceRehearsalLinkedSpeechId(speech.id);
    _notifyAll();
  }

  void dismissSmartPauseBanner() {
    _smartPauseBanner = null;
    _notifyContent(force: true);
  }

  /// Inicia fluxo inteligente; retorna true se a UI deve exibir countdown.
  Future<bool> startSessionWithSmartFlow(VoiceSessionMode mode) async {
    await loadSmartFlags();
    _pendingSessionMode = mode;
    _firedMilestones.clear();
    _sessionMilestoneBanner = null;
    _smartPauseBanner = null;
    _lastHapticFillerCount = 0;
    _lastHapticWpmOutOfRange = false;
    _recentAlertTimes.clear();

    if (_smartFlags.countdownEnabled) {
      _sessionPhase = VoiceSessionPhase.countdown;
      _notifyAll();
      return true;
    }
    await _beginSessionAfterCountdown();
    return false;
  }

  Future<void> completeCountdownAndStart() async {
    await _beginSessionAfterCountdown();
  }

  Future<void> _beginSessionAfterCountdown() async {
    final mode = _pendingSessionMode;
    if (mode == null) return;
    _pendingSessionMode = null;

    if (_smartFlags.warmupEnabled) {
      await startSession(mode);
      _isWarmupPhase = true;
      _sessionPhase = VoiceSessionPhase.warmup;
      _notifyAll();
      return;
    }

    await startSession(mode);
    _sessionPhase = VoiceSessionPhase.recording;
  }

  Future<void> endWarmupAndStartMain() async {
    if (!_isWarmupPhase) return;
    _isWarmupPhase = false;
    _sessionPhase = VoiceSessionPhase.recording;
    _sessionMilestoneBanner = 'Ensaio valendo — boa apresentação!';
    _notifyAll();
  }

  void cancelCountdown() {
    _pendingSessionMode = null;
    _sessionPhase = VoiceSessionPhase.idle;
    _notifyAll();
  }

  Future<void> setDurationGoalSeconds(int? seconds) async {
    _sessionPrefs = _sessionPrefs.copyWith(
      durationGoalSeconds: () => seconds,
    );
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalSessionPrefs(_sessionPrefs);
    _notifyAll();
  }

  Future<void> setFocusMode(bool enabled) async {
    _sessionPrefs = _sessionPrefs.copyWith(focusMode: enabled);
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalSessionPrefs(_sessionPrefs);
    _notifyAll();
  }

  void _notifyMetrics({bool immediate = false}) {
    if (immediate || !_sessionActive) {
      _metricsDebounceTimer?.cancel();
      metricsListenable.notifyListeners();
      return;
    }
    _metricsDebounceTimer?.cancel();
    _metricsDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      metricsListenable.notifyListeners();
    });
  }

  void _notifyContent({bool force = false}) {
    if (force || !_sessionActive) {
      _notifyDebounceTimer?.cancel();
      contentListenable.notifyListeners();
      notifyListeners();
      return;
    }
    _notifyDebounceTimer?.cancel();
    _notifyDebounceTimer = Timer(const Duration(milliseconds: 220), () {
      if (_sessionActive) contentListenable.notifyListeners();
    });
  }

  void _notifyAll({bool force = true}) {
    if (force) {
      _notifyDebounceTimer?.cancel();
      _metricsDebounceTimer?.cancel();
    }
    metricsListenable.notifyListeners();
    _notifyContent(force: true);
  }

  Future<bool> initialize() async {
    _hasMicPermission = await _recorder.hasPermission();
    if (!_hasMicPermission) {
      _state = VoiceRehearsalState.error;
      _errorMessage = 'Permissão de microfone negada.';
      _notifyAll();
      return false;
    }

    final storage = await StorageService.getInstance();
    _volumeCalibration = await storage.getVolumeCalibration();
    _sessionPrefs = await storage.getVoiceRehearsalSessionPrefs();

    _speechAvailable = await _speech.initialize(
      onError: (error) {
        if (kDebugMode) {
          debugPrint('SpeechToText error: ${error.errorMsg}');
        }
      },
      onStatus: (status) {
        if (kDebugMode && status != 'listening' && status != 'done') {
          debugPrint('SpeechToText status: $status');
        }
        if (_sessionActive &&
            !_teardownInProgress &&
            (status == 'done' || status == 'notListening')) {
          _scheduleListeningRestart();
        }
      },
    );

    _notifyAll();
    return _hasMicPermission;
  }

  Future<VoiceSessionCheckpoint?> loadCheckpoint() =>
      VoiceSessionCheckpoint.load();

  Future<void> resumeFromCheckpoint(VoiceSessionCheckpoint checkpoint) async {
    final ready = await initialize();
    if (!ready) return;

    _engine.reset();
    await _loadFillerWords();
    _engine.restoreFromCheckpoint(
      elapsedSeconds: checkpoint.elapsedSeconds,
      transcript: checkpoint.transcript,
      liveScore: checkpoint.liveScore,
      events: checkpoint.events,
    );
    _liveEvents.clear();
    _liveEvents.addAll(checkpoint.events.reversed);
    _elapsedSeconds = checkpoint.elapsedSeconds;
    _sessionMode = checkpoint.mode;
    _summary = null;
    _sessionActive = true;
    _isPaused = false;

    await WakelockPlus.enable();

    if (_sessionMode == VoiceSessionMode.recording) {
      final dir = await _ensureRecordingsDir();
      _recordingPath =
          '${dir.path}/ensaio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath!,
      );
      await _startAmplitudeStream();
    }

    await _startListeningIfNeeded();
    _startTimers();
    _state = VoiceRehearsalState.recording;
    _notifyAll();
  }

  Future<void> startSession(VoiceSessionMode mode) async {
    if (_state == VoiceRehearsalState.recording) return;

    final ready = await initialize();
    if (!ready) return;

    _engine.reset();
    await _loadFillerWords();
    _liveEvents.clear();
    _summary = null;
    _elapsedSeconds = 0;
    _errorMessage = null;
    _sessionMode = mode;
    _sessionActive = true;
    _isPaused = false;

    await WakelockPlus.enable();
    await VoiceSessionCheckpoint.clear();

    if (mode == VoiceSessionMode.recording) {
      final dir = await _ensureRecordingsDir();
      _recordingPath =
          '${dir.path}/ensaio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath!,
      );
      await _startAmplitudeStream();
    }

    await _startListeningIfNeeded();
    _startTimers();

    _state = VoiceRehearsalState.recording;
    if (!_isWarmupPhase) {
      _sessionPhase = VoiceSessionPhase.recording;
    }
    _notifyAll();
  }

  Future<void> pauseSession() async {
    if (_state != VoiceRehearsalState.recording || _isPaused) return;

    _isPaused = true;
    _sessionTimer?.cancel();
    _sessionTimer = null;

    try {
      if (_speechAvailable && _speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao pausar STT: $e');
    }

    await _saveCheckpoint();
    _notifyAll();
  }

  Future<void> resumeSession() async {
    if (_state != VoiceRehearsalState.recording || !_isPaused) return;

    _isPaused = false;
    await _startListeningIfNeeded();
    _startTimers(resume: true);
    _notifyAll();
  }

  Future<void> stopSession() async {
    if (_state != VoiceRehearsalState.recording) return;

    await _teardownSession();

    _engine.tick(Duration(seconds: _elapsedSeconds));
    _engine.flushLiveAnalysis(topic: _sessionTopic);
    _summary = _engine.buildSummary(topic: _sessionTopic);
    _state = VoiceRehearsalState.stopped;
    _sessionPhase = VoiceSessionPhase.stopped;
    _isWarmupPhase = false;

    if (_smartFlags.carryOverFocusEnabled) {
      await _saveNextFocusFromSummary(_summary!);
    }

    final attemptId = _uuid.v4();
    final savedTopic = _sessionTopic;
    final savedDuration = _elapsedSeconds;
    final savedRecordingPath = _recordingPath;

    await _persistAttempt(_summary!, attemptId);

    if (_sessionMode == VoiceSessionMode.recording &&
        savedRecordingPath != null &&
        File(savedRecordingPath).existsSync()) {
      await _persistRecording(_summary!, attemptId);
      if (_summary!.fullTranscript.trim().isEmpty) {
        unawaited(_analyzeRecordingInBackground(
          recordingId: attemptId,
          filePath: savedRecordingPath,
          durationSeconds: savedDuration,
          topic: savedTopic,
        ));
      }
    }

    _sessionTopic = null;
    await VoiceSessionCheckpoint.clear();
    _notifyAll();
  }

  Future<void> discardSession() async {
    await _teardownSession();

    if (_recordingPath != null && _sessionMode == VoiceSessionMode.recording) {
      final file = File(_recordingPath!);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    _recordingPath = null;
    _summary = null;
    _liveEvents.clear();
    _engine.reset();
    _elapsedSeconds = 0;
    _sessionMode = null;
    _sessionTopic = null;
    _isPaused = false;
    _state = VoiceRehearsalState.idle;
    _sessionPhase = VoiceSessionPhase.idle;
    _isWarmupPhase = false;
    _errorMessage = null;
    await VoiceSessionCheckpoint.clear();
    _notifyAll();
  }

  Future<void> _saveNextFocusFromSummary(VoiceRehearsalSummary summary) async {
    final scores = summary.characteristicScores;
    if (scores.isEmpty) return;

    int? worstId;
    int worstScore = 999;
    for (final e in scores.entries) {
      if (e.value < worstScore) {
        worstScore = e.value;
        worstId = e.key;
      }
    }
    if (worstId == null) return;

    final title =
        CharacteristicsService.instance.getCharacteristicById(worstId)?.title ??
            'Característica #$worstId';
    final focus = VoiceRehearsalNextFocus(
      characteristicId: worstId,
      label: title,
      savedAt: DateTime.now(),
    );
    _nextFocus = focus;
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalNextFocus(focus);
  }

  Future<void> _persistAttempt(
    VoiceRehearsalSummary summary,
    String attemptId,
  ) async {
    try {
      final storage = await StorageService.getInstance();
      final transcript = summary.fullTranscript;
      final attempt = VoiceRehearsalAttempt(
        id: attemptId,
        createdAt: DateTime.now(),
        mode: _sessionMode ?? VoiceSessionMode.training,
        durationSeconds: _elapsedSeconds,
        finalScore: summary.metrics.liveScore,
        topic: _sessionTopic,
        subjectPreview: VoiceRehearsalTopicHelper.buildSubjectPreview(
          userTopic: _sessionTopic,
          transcript: transcript,
        ),
        summary: summary,
        recordingFilePath: _sessionMode == VoiceSessionMode.recording
            ? _recordingPath
            : null,
        seriesName: _seriesName,
        linkedSpeechId: _linkedSpeechId,
      );
      await storage.addVoiceRehearsalAttempt(attempt);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar histórico: $e');
      }
    }
  }

  Future<void> _analyzeRecordingInBackground({
    required String recordingId,
    required String filePath,
    required int durationSeconds,
    String? topic,
  }) async {
    _isAnalyzingRecording = true;
    _notifyAll();

    try {
      final transcript = await _transcriber.transcribeFromFile(filePath);
      if (transcript == null || transcript.trim().isEmpty) return;

      _engine.reset();
      await _loadFillerWords();
      _summary = _engine.buildSummaryFromTranscript(
        transcript: transcript,
        elapsedSeconds: durationSeconds,
        topic: topic,
      );

      final storage = await StorageService.getInstance();
      final recordings = await storage.getVoiceRecordings();
      final idx = recordings.indexWhere((r) => r.id == recordingId);
      if (idx != -1) {
        final updated = recordings[idx].copyWith(
          summary: _summary,
          finalScore: _summary!.metrics.liveScore,
        );
        await storage.updateVoiceRecording(updated);
      }

      final attempts = await storage.getVoiceRehearsalAttempts();
      final attemptIdx = attempts.indexWhere((a) => a.id == recordingId);
      if (attemptIdx != -1) {
        final old = attempts[attemptIdx];
        await storage.updateVoiceRehearsalAttempt(
          VoiceRehearsalAttempt(
            id: old.id,
            createdAt: old.createdAt,
            mode: old.mode,
            durationSeconds: old.durationSeconds,
            finalScore: _summary!.metrics.liveScore,
            topic: old.topic,
            subjectPreview: VoiceRehearsalTopicHelper.buildSubjectPreview(
              userTopic: old.topic,
              transcript: transcript,
            ),
            summary: _summary!,
            recordingFilePath: old.recordingFilePath,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao transcrever gravação: $e');
    } finally {
      _isAnalyzingRecording = false;
      _notifyAll();
    }
  }

  /// Transcreve e analisa uma gravação existente (tela de gravações).
  Future<VoiceRehearsalSummary?> analyzeRecordingFile({
    required String filePath,
    required int durationSeconds,
    String? topic,
  }) async {
    _isAnalyzingRecording = true;
    _notifyAll();

    try {
      final transcript = await _transcriber.transcribeFromFile(filePath);
      if (transcript == null || transcript.trim().isEmpty) return null;

      final engine = VoiceAnalysisEngine();
      await _loadFillerWordsForEngine(engine);
      return engine.buildSummaryFromTranscript(
        transcript: transcript,
        elapsedSeconds: durationSeconds,
        topic: topic,
      );
    } finally {
      _isAnalyzingRecording = false;
      _notifyAll();
    }
  }

  Future<void> _loadFillerWordsForEngine(VoiceAnalysisEngine engine) async {
    final storage = await StorageService.getInstance();
    final custom = await storage.getCustomFillerWords();
    engine.setFillerWords(
      VoiceFillerWordsService.effectiveFillers(custom.toSet()),
    );
  }

  Future<void> _persistRecording(
    VoiceRehearsalSummary summary,
    String attemptId,
  ) async {
    try {
      final storage = await StorageService.getInstance();
      final recording = VoiceRecording(
        id: attemptId,
        filePath: _recordingPath!,
        createdAt: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        finalScore: summary.metrics.liveScore,
        title: _sessionTopic,
        summary: summary,
      );
      await storage.addVoiceRecording(recording);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar gravação: $e');
      }
    }
  }

  Future<void> _teardownSession() async {
    if (_teardownInProgress) return;
    _teardownInProgress = true;
    _sessionActive = false;

    _sessionTimer?.cancel();
    _sessionTimer = null;
    _checkpointTimer?.cancel();
    _checkpointTimer = null;
    _sttRestartTimer?.cancel();
    _sttRestartTimer = null;

    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    try {
      if (_speechAvailable && _speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao parar STT: $e');
    }

    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (_sessionMode == VoiceSessionMode.recording) {
          _recordingPath = path ?? _recordingPath;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao parar gravador: $e');
    }

    await WakelockPlus.disable();
    _teardownInProgress = false;
  }

  void _startTimers({bool resume = false}) {
    if (!resume) {
      _checkpointTimer?.cancel();
      _checkpointTimer = Timer.periodic(
        VoiceSessionCheckpoint.saveInterval,
        (_) => _saveCheckpoint(),
      );
    }

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      _elapsedSeconds++;
      _engine.tick(Duration(seconds: _elapsedSeconds));
      _handleSmartSessionTick();
      if (_isWarmupPhase &&
          _smartFlags.warmupEnabled &&
          _elapsedSeconds >= kWarmupDurationSeconds) {
        unawaited(endWarmupAndStartMain());
      }
      _notifyMetrics(immediate: true);
    });
  }

  void _handleSmartSessionTick() {
    if (!_sessionActive || _isPaused) return;

    final m = _engine.metrics;

    if (_smartFlags.hapticEnabled) {
      if (m.fillerCount >= _lastHapticFillerCount + 3) {
        _lastHapticFillerCount = m.fillerCount;
        HapticFeedback.mediumImpact();
      }
      final wpmOut = m.wpm > 0 &&
          (m.wpm < VoiceAnalysisThresholds.wpmLow ||
              m.wpm > VoiceAnalysisThresholds.wpmHigh);
      if (wpmOut && !_lastHapticWpmOutOfRange) {
        _lastHapticWpmOutOfRange = true;
        HapticFeedback.lightImpact();
      } else if (!wpmOut) {
        _lastHapticWpmOutOfRange = false;
      }
    }

    if (_smartFlags.timeMilestonesEnabled) {
      final goal = _sessionPrefs.durationGoalSeconds;
      if (goal != null && goal > 0) {
        final half = goal ~/ 2;
        if (_elapsedSeconds >= half &&
            !_firedMilestones.contains('half')) {
          _firedMilestones.add('half');
          _sessionMilestoneBanner = 'Metade da meta de tempo ($half s)';
          _notifyContent(force: true);
        }
        if (_elapsedSeconds >= goal &&
            !_firedMilestones.contains('goal')) {
          _firedMilestones.add('goal');
          _sessionMilestoneBanner = 'Meta de tempo atingida!';
          _notifyContent(force: true);
        }
        if (_elapsedSeconds >= goal + 60 &&
            !_firedMilestones.contains('over')) {
          _firedMilestones.add('over');
          _sessionMilestoneBanner =
              '+1 min além da meta — considere encerrar.';
          _notifyContent(force: true);
        }
      }
    }
  }

  Future<void> saveCheckpointNow() => _saveCheckpoint();

  Future<void> _saveCheckpoint() async {
    if (!_sessionActive || _sessionMode == null) return;
    final events = _engine.events;
    final trimmedEvents = events.length > VoiceSessionCheckpoint.maxCheckpointEvents
        ? events.sublist(events.length - VoiceSessionCheckpoint.maxCheckpointEvents)
        : events;
    await VoiceSessionCheckpoint.save(
      VoiceSessionCheckpoint(
        elapsedSeconds: _elapsedSeconds,
        transcript: _engine.fullTranscript,
        liveScore: _engine.liveScore,
        mode: _sessionMode!,
        events: trimmedEvents,
        savedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _startAmplitudeStream() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription =
        _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen(
      (amp) {
        if (!_sessionActive || _teardownInProgress || _isPaused) return;
        final events = _engine.onAmplitude(_adjustVolume(amp.current));
        _appendLiveEvents(events, debounceUi: true);
      },
    );
  }

  /// Treino: só STT. Gravar: só gravador (evita dois consumidores do mic no iOS).
  Future<void> _startListeningIfNeeded() async {
    if (_sessionMode == VoiceSessionMode.recording || _isPaused) return;
    await _startListening(useSoundLevel: true);
  }

  Future<void> _startListening({required bool useSoundLevel}) async {
    if (!_speechAvailable || !_sessionActive || _teardownInProgress) return;
    if (_speech.isListening) return;

    try {
      await _speech.listen(
      onResult: (result) {
        if (!_sessionActive || _teardownInProgress) return;
        final events = _engine.onTranscript(
          result.recognizedWords,
          confidence: result.confidence,
        );
        _appendLiveEvents(events, debounceUi: events.isEmpty);
        _notifyMetrics();
        _notifyContent();
      },
      onSoundLevelChange: useSoundLevel
          ? (level) {
              if (!_sessionActive || _teardownInProgress || _isPaused) {
                return;
              }
              final pseudoDb = _adjustVolume(-50 + (level * 30));
              _engine.recordAmplitudeSample(pseudoDb);
              _notifyMetrics();
            }
          : null,
      listenOptions: stt.SpeechListenOptions(
        localeId: 'pt_BR',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(hours: 1),
        pauseFor: const Duration(seconds: 5),
      ),
    );
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao iniciar STT: $e');
    }
  }

  void _scheduleListeningRestart() {
    if (!_sessionActive || !_speechAvailable || _teardownInProgress) return;
    if (_sessionMode == VoiceSessionMode.recording) return;

    _sttRestartTimer?.cancel();
    _sttRestartTimer = Timer(const Duration(milliseconds: 900), () {
      unawaited(_restartListening());
    });
  }

  Future<void> _restartListening() async {
    if (!_sessionActive || !_speechAvailable || _teardownInProgress) return;
    if (_sessionMode == VoiceSessionMode.recording) return;
    if (_sttRestartInProgress) return;

    final now = DateTime.now();
    if (_lastSttRestartAt != null &&
        now.difference(_lastSttRestartAt!) <
            const Duration(seconds: 1)) {
      _scheduleListeningRestart();
      return;
    }

    _sttRestartInProgress = true;
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!_sessionActive || _teardownInProgress) return;
      if (_speech.isListening) return;
      await _startListening(useSoundLevel: true);
      _lastSttRestartAt = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao reiniciar STT: $e');
      }
    } finally {
      _sttRestartInProgress = false;
    }
  }

  Future<Directory> _ensureRecordingsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/ensaio_bet');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _loadFillerWords() async {
    final storage = await StorageService.getInstance();
    final custom = await storage.getCustomFillerWords();
    _engine.setFillerWords(
      VoiceFillerWordsService.effectiveFillers(custom.toSet()),
    );
  }

  double _adjustVolume(double rawDb) =>
      applyCalibration(rawDb, _volumeCalibration);

  void _appendLiveEvents(
    List<VoiceFeedbackEvent> events, {
    bool debounceUi = false,
  }) {
    if (events.isEmpty || !_sessionActive || _teardownInProgress) return;
    _liveEvents.insertAll(0, events);
    if (_liveEvents.length > 20) {
      _liveEvents.removeRange(20, _liveEvents.length);
    }

    if (_smartFlags.smartPauseEnabled) {
      final now = DateTime.now();
      for (final e in events) {
        _recentAlertTimes.add((charId: e.characteristicId, at: now));
      }
      _recentAlertTimes.removeWhere(
        (r) => now.difference(r.at) > const Duration(seconds: 60),
      );
      if (_recentAlertTimes.length >= 3) {
        final lastThree = _recentAlertTimes.length >= 3
            ? _recentAlertTimes.sublist(_recentAlertTimes.length - 3)
            : _recentAlertTimes;
        if (lastThree.length == 3 &&
            lastThree.every((r) => r.charId == lastThree.first.charId)) {
          _smartPauseBanner =
              'Respire 10 segundos e retome com calma.';
          _recentAlertTimes.clear();
        }
      }
    }

    _notifyMetrics();
    _notifyContent(force: !debounceUi);
  }

  @override
  void dispose() {
    _sessionActive = false;
    _sessionTimer?.cancel();
    _checkpointTimer?.cancel();
    _notifyDebounceTimer?.cancel();
    _metricsDebounceTimer?.cancel();
    metricsListenable.dispose();
    contentListenable.dispose();
    _sttRestartTimer?.cancel();
    _transcriber.dispose();
    unawaited(_teardownSession());
    unawaited(_recorder.dispose());
    unawaited(WakelockPlus.disable());
    super.dispose();
  }
}

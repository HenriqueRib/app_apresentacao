import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/voice_recording.dart';
import '../models/voice_rehearsal.dart';
import '../services/storage_service.dart';
import '../services/voice_analysis_engine.dart';
import '../services/voice_filler_words_service.dart';
import '../services/voice_recording_transcriber.dart';

class VoiceRecordingsProvider extends ChangeNotifier {
  List<VoiceRecording> _recordings = [];
  bool _loading = false;
  String? _playingId;
  String? _analyzingId;
  final AudioPlayer _player = AudioPlayer();
  final VoiceRecordingTranscriber _transcriber = VoiceRecordingTranscriber();

  List<VoiceRecording> get recordings => List.unmodifiable(_recordings);
  bool get loading => _loading;
  String? get playingId => _playingId;
  String? get analyzingId => _analyzingId;

  VoiceRecordingsProvider() {
    _player.onPlayerComplete.listen((_) {
      _playingId = null;
      notifyListeners();
    });
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final storage = await StorageService.getInstance();
      _recordings = await storage.getVoiceRecordings();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    final index = _recordings.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final recording = _recordings[index];
    final file = File(recording.filePath);
    if (file.existsSync()) {
      await file.delete();
    }
    final storage = await StorageService.getInstance();
    await storage.deleteVoiceRecording(id);
    if (_playingId == id) {
      await _player.stop();
      _playingId = null;
    }
    _recordings.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> rename(String id, String title) async {
    final index = _recordings.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final updated = _recordings[index].copyWith(title: title);
    final storage = await StorageService.getInstance();
    await storage.updateVoiceRecording(updated);
    _recordings[index] = updated;
    notifyListeners();
  }

  Future<void> play(VoiceRecording recording) async {
    if (_playingId == recording.id) {
      await _player.stop();
      _playingId = null;
      notifyListeners();
      return;
    }
    await _player.stop();
    _playingId = recording.id;
    notifyListeners();
    await _player.play(DeviceFileSource(recording.filePath));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _playingId = null;
    notifyListeners();
  }

  /// Transcreve gravação e atualiza resumo com análise be-T (#38/#39/#51).
  Future<VoiceRehearsalSummary?> analyzeRecording(VoiceRecording recording) async {
    if (_analyzingId != null) return null;
    if (!File(recording.filePath).existsSync()) return null;

    _analyzingId = recording.id;
    notifyListeners();

    try {
      final transcript =
          await _transcriber.transcribeFromFile(recording.filePath);
      if (transcript == null || transcript.trim().isEmpty) return null;

      final engine = VoiceAnalysisEngine();
      final storage = await StorageService.getInstance();
      final custom = await storage.getCustomFillerWords();
      engine.setFillerWords(
        VoiceFillerWordsService.effectiveFillers(custom.toSet()),
      );

      final summary = engine.buildSummaryFromTranscript(
        transcript: transcript,
        elapsedSeconds: recording.durationSeconds,
        topic: recording.title,
      );

      final updated = recording.copyWith(
        summary: summary,
        finalScore: summary.metrics.liveScore,
      );

      await storage.updateVoiceRecording(updated);
      final index = _recordings.indexWhere((r) => r.id == recording.id);
      if (index != -1) {
        _recordings[index] = updated;
      }

      return summary;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao analisar gravação: $e');
      return null;
    } finally {
      _analyzingId = null;
      notifyListeners();
    }
  }

  bool needsAnalysis(VoiceRecording recording) {
    final summary = recording.summary;
    if (summary == null) return true;
    return summary.fullTranscript.trim().isEmpty;
  }

  @override
  void dispose() {
    _transcriber.dispose();
    _player.dispose();
    super.dispose();
  }
}

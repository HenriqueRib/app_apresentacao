import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/voice_rehearsal_attempt.dart';
import '../services/storage_service.dart';

class VoiceRehearsalHistoryProvider extends ChangeNotifier {
  List<VoiceRehearsalAttempt> _attempts = [];
  bool _loading = false;
  String? _playingId;
  final AudioPlayer _player = AudioPlayer();

  List<VoiceRehearsalAttempt> get attempts => List.unmodifiable(_attempts);
  bool get loading => _loading;
  String? get playingId => _playingId;

  VoiceRehearsalHistoryProvider() {
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
      _attempts = await storage.getVoiceRehearsalAttempts();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void refreshAttempt(VoiceRehearsalAttempt updated) {
    final index = _attempts.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _attempts[index] = updated;
      notifyListeners();
    }
  }

  Future<void> updateUserNote(String id, String? note) async {
    final index = _attempts.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final trimmed = note?.trim();
    final updated = _attempts[index].copyWith(
      userNote: trimmed != null && trimmed.isNotEmpty ? trimmed : null,
      clearUserNote: trimmed == null || trimmed.isEmpty,
    );

    final storage = await StorageService.getInstance();
    await storage.updateVoiceRehearsalAttempt(updated);
    _attempts[index] = updated;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final attempt = _attempts.where((a) => a.id == id).firstOrNull;
    if (attempt == null) return;

    final path = attempt.recordingFilePath;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    final storage = await StorageService.getInstance();
    await storage.deleteVoiceRehearsalAttempt(id);
    if (attempt.recordingFilePath != null) {
      await storage.deleteVoiceRecording(id);
    }

    if (_playingId == id) {
      await _player.stop();
      _playingId = null;
    }

    _attempts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> playRecording(VoiceRehearsalAttempt attempt) async {
    final path = attempt.recordingFilePath;
    if (path == null || !File(path).existsSync()) return;

    if (_playingId == attempt.id) {
      await _player.stop();
      _playingId = null;
      notifyListeners();
      return;
    }

    await _player.stop();
    _playingId = attempt.id;
    notifyListeners();
    await _player.play(DeviceFileSource(path));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _playingId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

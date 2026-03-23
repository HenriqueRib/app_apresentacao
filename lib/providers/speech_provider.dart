import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/speech.dart';
import '../services/storage_service.dart';

class SpeechProvider extends ChangeNotifier {
  List<Speech> _speeches = [];
  Speech? _currentSpeech;
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<Speech> get speeches => _speeches;
  Speech? get currentSpeech => _currentSpeech;
  bool get isLoading => _isLoading;

  List<Speech> get activeSpeechesSorted {
    final active = _speeches
        .where((s) => s.status != SpeechStatus.archived)
        .toList();
    active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return active;
  }

  List<Speech> get archivedSpeeches =>
      _speeches.where((s) => s.status == SpeechStatus.archived).toList();

  Future<void> loadSpeeches() async {
    _isLoading = true;
    notifyListeners();

    final storage = await StorageService.getInstance();
    _speeches = await storage.getSpeeches();

    _isLoading = false;
    notifyListeners();
  }

  Future<Speech> createSpeech({
    required String title,
    required SpeechType type,
    required SpeechGoalType goalType,
    required String centralObjective,
    AudienceAnalysis? audienceAnalysis,
    int? focusCharacteristicId,
  }) async {
    final now = DateTime.now();
    final speech = Speech(
      id: _uuid.v4(),
      title: title,
      type: type,
      goalType: goalType,
      centralObjective: centralObjective,
      audienceAnalysis: audienceAnalysis,
      focusCharacteristicId: focusCharacteristicId,
      status: SpeechStatus.planning,
      createdAt: now,
      updatedAt: now,
    );

    final storage = await StorageService.getInstance();
    await storage.addSpeech(speech);

    _speeches.add(speech);
    _currentSpeech = speech;
    notifyListeners();

    return speech;
  }

  Future<void> updateSpeech(Speech speech) async {
    final storage = await StorageService.getInstance();
    await storage.updateSpeech(speech);

    final index = _speeches.indexWhere((s) => s.id == speech.id);
    if (index != -1) {
      _speeches[index] = speech;
    }

    if (_currentSpeech?.id == speech.id) {
      _currentSpeech = speech;
    }

    notifyListeners();
  }

  Future<void> deleteSpeech(String id) async {
    final storage = await StorageService.getInstance();
    await storage.deleteSpeech(id);

    _speeches.removeWhere((s) => s.id == id);

    if (_currentSpeech?.id == id) {
      _currentSpeech = null;
    }

    notifyListeners();
  }

  void setCurrentSpeech(Speech? speech) {
    _currentSpeech = speech;
    notifyListeners();
  }

  Future<void> updateOutline(String speechId, SpeechOutline outline) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(
        outline: outline,
        status: SpeechStatus.preparing,
      );
      await updateSpeech(updated);
    }
  }

  Future<void> updateAudienceAnalysis(
    String speechId,
    AudienceAnalysis analysis,
  ) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(audienceAnalysis: analysis);
      await updateSpeech(updated);
    }
  }

  Future<void> updateTrainingProgress(
    String speechId,
    TrainingProgress progress,
  ) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(
        trainingProgress: progress,
        status: SpeechStatus.training,
      );
      await updateSpeech(updated);
    }
  }

  Future<void> markAsReady(String speechId) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(status: SpeechStatus.ready);
      await updateSpeech(updated);
    }
  }

  Future<void> recordExecution(
    String speechId,
    ExecutionRecord record,
  ) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(
        executionRecord: record,
        status: SpeechStatus.executed,
      );
      await updateSpeech(updated);
    }
  }

  Future<void> addFeedback(String speechId, FeedbackRecord feedback) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(feedbackRecord: feedback);
      await updateSpeech(updated);
    }
  }

  Future<void> archiveSpeech(String speechId) async {
    final index = _speeches.indexWhere((s) => s.id == speechId);
    if (index != -1) {
      final updated = _speeches[index].copyWith(status: SpeechStatus.archived);
      await updateSpeech(updated);
    }
  }

  Map<String, dynamic> getProgressStats() {
    final executed = _speeches.where((s) => s.status == SpeechStatus.executed);
    final totalSpeeches = _speeches.length;
    final executedCount = executed.length;

    double avgEngagement = 0;
    int objectivesAchieved = 0;

    for (final speech in executed) {
      if (speech.feedbackRecord != null) {
        avgEngagement += speech.feedbackRecord!.audienceEngagement;
        if (speech.feedbackRecord!.objectiveAchieved) objectivesAchieved++;
      }
    }

    if (executedCount > 0) {
      avgEngagement /= executedCount;
    }

    return {
      'totalSpeeches': totalSpeeches,
      'executedCount': executedCount,
      'avgEngagement': avgEngagement,
      'objectivesAchieved': objectivesAchieved,
      'successRate': executedCount > 0
          ? (objectivesAchieved / executedCount * 100).toStringAsFixed(1)
          : '0',
    };
  }
}

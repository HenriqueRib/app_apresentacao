import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/self_assessment_record.dart';
import '../services/storage_service.dart';

class OratoryGuideProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<SelfAssessmentRecord> _records = [];
  List<int> _weeklyFocusIds = [];

  List<SelfAssessmentRecord> get records =>
      List.unmodifiable(_records..sort((a, b) => b.completedAt.compareTo(a.completedAt)));
  List<int> get weeklyFocusIds => List.unmodifiable(_weeklyFocusIds);

  Future<void> load() async {
    final storage = await StorageService.getInstance();
    _records = await storage.getSelfAssessments();
    _weeklyFocusIds = await storage.getWeeklyFocusCharacteristicIds();
    notifyListeners();
  }

  Future<void> saveAssessment({
    required List<CharacteristicScore> scores,
    String? speechTitle,
  }) async {
    final record = SelfAssessmentRecord(
      id: _uuid.v4(),
      completedAt: DateTime.now(),
      speechTitle: speechTitle,
      scores: scores,
    );
    _records.insert(0, record);
    final storage = await StorageService.getInstance();
    await storage.saveSelfAssessments(_records);
    notifyListeners();
  }

  Future<void> toggleWeeklyFocus(int characteristicId) async {
    if (_weeklyFocusIds.contains(characteristicId)) {
      _weeklyFocusIds.remove(characteristicId);
    } else {
      _weeklyFocusIds.add(characteristicId);
    }
    final storage = await StorageService.getInstance();
    await storage.saveWeeklyFocusCharacteristicIds(_weeklyFocusIds);
    notifyListeners();
  }

  bool isWeeklyFocus(int characteristicId) =>
      _weeklyFocusIds.contains(characteristicId);
}

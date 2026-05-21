import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/study_outline.dart';
import '../services/storage_service.dart';

class StudyStudioProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<StudyOutline> _outlines = [];
  bool _isLoading = false;
  bool _isLoaded = false;

  List<StudyOutline> get outlines {
    final sorted = List<StudyOutline>.from(_outlines)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(sorted);
  }

  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final storage = await StorageService.getInstance();
    _outlines = await storage.getStudyOutlines();
    _isLoading = false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _ensureLoaded() async {
    if (!_isLoaded) await load();
  }

  Future<StudyOutline> createOutline(String title) async {
    await _ensureLoaded();
    final now = DateTime.now();
    final outline = StudyOutline(
      id: _uuid.v4(),
      title: title.trim().isEmpty ? 'Novo esboço' : title.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _outlines.add(outline);
    await _persist();
    notifyListeners();
    return outline;
  }

  Future<void> updateOutline(StudyOutline outline) async {
    await _ensureLoaded();
    final index = _outlines.indexWhere((o) => o.id == outline.id);
    if (index == -1) return;
    _outlines[index] = outline.copyWith(updatedAt: DateTime.now());
    await _persist();
    notifyListeners();
  }

  Future<void> deleteOutline(String id) async {
    await _ensureLoaded();
    _outlines.removeWhere((o) => o.id == id);
    await _persist();
    notifyListeners();
  }

  StudyOutline? getById(String id) {
    try {
      return _outlines.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    final storage = await StorageService.getInstance();
    await storage.saveStudyOutlines(_outlines);
  }
}

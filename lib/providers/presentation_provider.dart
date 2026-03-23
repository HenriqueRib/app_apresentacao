import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/presentation.dart';
import '../services/storage_service.dart';

class PresentationProvider extends ChangeNotifier {
  List<Presentation> _presentations = [];
  Presentation? _currentPresentation;
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<Presentation> get presentations => _presentations;
  Presentation? get currentPresentation => _currentPresentation;
  bool get isLoading => _isLoading;

  List<Presentation> get draftPresentations =>
      _presentations.where((p) => p.status == PresentationStatus.draft).toList();

  List<Presentation> get activePresentations => _presentations
      .where((p) =>
          p.status != PresentationStatus.draft &&
          p.status != PresentationStatus.archived)
      .toList();

  List<Presentation> get archivedPresentations =>
      _presentations.where((p) => p.status == PresentationStatus.archived).toList();

  Future<void> loadPresentations() async {
    _isLoading = true;
    notifyListeners();

    final storage = await StorageService.getInstance();
    _presentations = await storage.getPresentations();

    _isLoading = false;
    notifyListeners();
  }

  Future<Presentation> createPresentation({
    required String title,
    required WorkflowType workflowType,
    required String kpiGoal,
  }) async {
    final now = DateTime.now();
    final presentation = Presentation(
      id: _uuid.v4(),
      title: title,
      workflowType: workflowType,
      kpiGoal: kpiGoal,
      status: PresentationStatus.planning,
      createdAt: now,
      updatedAt: now,
    );

    final storage = await StorageService.getInstance();
    await storage.addPresentation(presentation);

    _presentations.add(presentation);
    _currentPresentation = presentation;
    notifyListeners();

    return presentation;
  }

  Future<void> updatePresentation(Presentation presentation) async {
    final storage = await StorageService.getInstance();
    await storage.updatePresentation(presentation);

    final index = _presentations.indexWhere((p) => p.id == presentation.id);
    if (index != -1) {
      _presentations[index] = presentation;
    }

    if (_currentPresentation?.id == presentation.id) {
      _currentPresentation = presentation;
    }

    notifyListeners();
  }

  Future<void> deletePresentation(String id) async {
    final storage = await StorageService.getInstance();
    await storage.deletePresentation(id);

    _presentations.removeWhere((p) => p.id == id);

    if (_currentPresentation?.id == id) {
      _currentPresentation = null;
    }

    notifyListeners();
  }

  void setCurrentPresentation(Presentation? presentation) {
    _currentPresentation = presentation;
    notifyListeners();
  }

  Future<void> updateMessageArchitecture(
    String presentationId,
    MessageArchitecture architecture,
  ) async {
    final index = _presentations.indexWhere((p) => p.id == presentationId);
    if (index != -1) {
      final updated = _presentations[index].copyWith(
        messageArchitecture: architecture,
        status: PresentationStatus.preparing,
      );
      await updatePresentation(updated);
    }
  }

  Future<void> updateTrainingData(
    String presentationId,
    TrainingData trainingData,
  ) async {
    final index = _presentations.indexWhere((p) => p.id == presentationId);
    if (index != -1) {
      final updated = _presentations[index].copyWith(
        trainingData: trainingData,
        status: PresentationStatus.training,
      );
      await updatePresentation(updated);
    }
  }

  Future<void> updateExecutionData(
    String presentationId,
    ExecutionData executionData,
  ) async {
    final index = _presentations.indexWhere((p) => p.id == presentationId);
    if (index != -1) {
      final updated = _presentations[index].copyWith(
        executionData: executionData,
        status: PresentationStatus.executed,
      );
      await updatePresentation(updated);
    }
  }

  Future<void> updatePerformanceMetrics(
    String presentationId,
    PerformanceMetrics metrics,
  ) async {
    final index = _presentations.indexWhere((p) => p.id == presentationId);
    if (index != -1) {
      final updated = _presentations[index].copyWith(
        performanceMetrics: metrics,
      );
      await updatePresentation(updated);
    }
  }

  Future<void> markAsReady(String presentationId) async {
    final index = _presentations.indexWhere((p) => p.id == presentationId);
    if (index != -1) {
      final updated = _presentations[index].copyWith(
        status: PresentationStatus.ready,
      );
      await updatePresentation(updated);
    }
  }

  Future<void> archivePresentation(String presentationId) async {
    final index = _presentations.indexWhere((p) => p.id == presentationId);
    if (index != -1) {
      final updated = _presentations[index].copyWith(
        status: PresentationStatus.archived,
      );
      await updatePresentation(updated);
    }
  }
}

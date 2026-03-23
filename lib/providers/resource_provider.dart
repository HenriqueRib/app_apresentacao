import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/creative_resource.dart';
import '../services/storage_service.dart';

class ResourceProvider extends ChangeNotifier {
  List<CreativeResource> _resources = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<CreativeResource> get resources => _resources;
  bool get isLoading => _isLoading;

  List<CreativeResource> get strongTitles =>
      _resources.where((r) => r.type == ResourceType.strongTitle).toList();

  List<CreativeResource> get illustrativeCases =>
      _resources.where((r) => r.type == ResourceType.illustrativeCase).toList();

  List<CreativeResource> get connectionRepertoire =>
      _resources.where((r) => r.type == ResourceType.connectionRepertoire).toList();

  List<CreativeResource> get multimediaAssets =>
      _resources.where((r) => r.type == ResourceType.multimediaAsset).toList();

  int get originalContentCount => _resources.where((r) => r.isOriginal).length;
  int get marketingContentCount => _resources.where((r) => !r.isOriginal).length;

  double get depthScore {
    if (_resources.isEmpty) return 1.0;
    return originalContentCount / _resources.length;
  }

  bool get hasDepthWarning => depthScore < 0.6;

  Future<void> loadResources() async {
    _isLoading = true;
    notifyListeners();

    final storage = await StorageService.getInstance();
    _resources = await storage.getCreativeResources();

    _isLoading = false;
    notifyListeners();
  }

  Future<CreativeResource> createResource({
    required ResourceType type,
    required String title,
    required String content,
    List<String> tags = const [],
    String? mediaPath,
    bool isOriginal = true,
  }) async {
    final now = DateTime.now();
    final resource = CreativeResource(
      id: _uuid.v4(),
      type: type,
      title: title,
      content: content,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      mediaPath: mediaPath,
      isOriginal: isOriginal,
    );

    final storage = await StorageService.getInstance();
    await storage.addCreativeResource(resource);

    _resources.add(resource);
    notifyListeners();

    return resource;
  }

  Future<void> updateResource(CreativeResource resource) async {
    final storage = await StorageService.getInstance();
    await storage.updateCreativeResource(resource);

    final index = _resources.indexWhere((r) => r.id == resource.id);
    if (index != -1) {
      _resources[index] = resource;
    }

    notifyListeners();
  }

  Future<void> deleteResource(String id) async {
    final storage = await StorageService.getInstance();
    await storage.deleteCreativeResource(id);

    _resources.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<CreativeResource> searchResources(String query) {
    if (query.isEmpty) return _resources;

    final lowerQuery = query.toLowerCase();
    return _resources.where((r) {
      return r.title.toLowerCase().contains(lowerQuery) ||
          r.content.toLowerCase().contains(lowerQuery) ||
          r.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<CreativeResource> getResourcesByTags(List<String> tags) {
    if (tags.isEmpty) return _resources;

    return _resources.where((r) {
      return r.tags.any((tag) => tags.contains(tag));
    }).toList();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/presentation.dart';
import '../models/creative_resource.dart';
import '../models/speech.dart';

class StorageService {
  static const String _presentationsKey = 'presentations';
  static const String _resourcesKey = 'creative_resources';
  static const String _speechesKey = 'speeches';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingCompletedKey, value);
  }

  Future<List<Presentation>> getPresentations() async {
    final String? data = _prefs.getString(_presentationsKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Presentation.fromJson(json)).toList();
  }

  Future<void> savePresentations(List<Presentation> presentations) async {
    final String data =
        jsonEncode(presentations.map((p) => p.toJson()).toList());
    await _prefs.setString(_presentationsKey, data);
  }

  Future<void> addPresentation(Presentation presentation) async {
    final presentations = await getPresentations();
    presentations.add(presentation);
    await savePresentations(presentations);
  }

  Future<void> updatePresentation(Presentation presentation) async {
    final presentations = await getPresentations();
    final index = presentations.indexWhere((p) => p.id == presentation.id);
    if (index != -1) {
      presentations[index] = presentation;
      await savePresentations(presentations);
    }
  }

  Future<void> deletePresentation(String id) async {
    final presentations = await getPresentations();
    presentations.removeWhere((p) => p.id == id);
    await savePresentations(presentations);
  }

  Future<Presentation?> getPresentation(String id) async {
    final presentations = await getPresentations();
    try {
      return presentations.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<CreativeResource>> getCreativeResources() async {
    final String? data = _prefs.getString(_resourcesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => CreativeResource.fromJson(json)).toList();
  }

  Future<void> saveCreativeResources(List<CreativeResource> resources) async {
    final String data = jsonEncode(resources.map((r) => r.toJson()).toList());
    await _prefs.setString(_resourcesKey, data);
  }

  Future<void> addCreativeResource(CreativeResource resource) async {
    final resources = await getCreativeResources();
    resources.add(resource);
    await saveCreativeResources(resources);
  }

  Future<void> updateCreativeResource(CreativeResource resource) async {
    final resources = await getCreativeResources();
    final index = resources.indexWhere((r) => r.id == resource.id);
    if (index != -1) {
      resources[index] = resource;
      await saveCreativeResources(resources);
    }
  }

  Future<void> deleteCreativeResource(String id) async {
    final resources = await getCreativeResources();
    resources.removeWhere((r) => r.id == id);
    await saveCreativeResources(resources);
  }

  Future<List<CreativeResource>> getResourcesByType(ResourceType type) async {
    final resources = await getCreativeResources();
    return resources.where((r) => r.type == type).toList();
  }

  Future<List<Speech>> getSpeeches() async {
    final String? data = _prefs.getString(_speechesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Speech.fromJson(json)).toList();
  }

  Future<void> saveSpeeches(List<Speech> speeches) async {
    final String data = jsonEncode(speeches.map((s) => s.toJson()).toList());
    await _prefs.setString(_speechesKey, data);
  }

  Future<void> addSpeech(Speech speech) async {
    final speeches = await getSpeeches();
    speeches.add(speech);
    await saveSpeeches(speeches);
  }

  Future<void> updateSpeech(Speech speech) async {
    final speeches = await getSpeeches();
    final index = speeches.indexWhere((s) => s.id == speech.id);
    if (index != -1) {
      speeches[index] = speech;
      await saveSpeeches(speeches);
    }
  }

  Future<void> deleteSpeech(String id) async {
    final speeches = await getSpeeches();
    speeches.removeWhere((s) => s.id == id);
    await saveSpeeches(speeches);
  }

  Future<Speech?> getSpeech(String id) async {
    final speeches = await getSpeeches();
    try {
      return speeches.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/presentation.dart';
import '../models/creative_resource.dart';
import '../models/speech.dart';
import '../models/weekly_comment_note.dart';
import '../models/study_outline.dart';
import '../models/timer_preset.dart';
import '../models/self_assessment_record.dart';
import '../models/assentinel_study.dart';
import '../models/parte.dart';
import '../models/resposta_gerada.dart';

class StorageService {
  static const String _presentationsKey = 'presentations';
  static const String _resourcesKey = 'creative_resources';
  static const String _speechesKey = 'speeches';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _weeklyCommentPinsKey = 'weekly_comment_pins';
  static const String _studyOutlinesKey = 'study_outlines';
  static const String _timerPresetsKey = 'timer_presets';
  static const String _selfAssessmentsKey = 'self_assessments';
  static const String _weeklyFocusCharacteristicsKey =
      'weekly_focus_characteristics';
  static const String _assentinelStudiesKey = 'assentinel_studies';
  static const String _partesKey = 'partes_reuniao';
  static const String _respostasGeradasKey = 'respostas_geradas';
  static const String _assentinelSettingsKey = 'assentinel_settings';
  static const String _discursoSettingsKey = 'discurso_settings';
  static const String _parteSettingsKey = 'parte_settings';

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

  Future<List<WeeklyCommentNote>> getWeeklyCommentNotes() async {
    final data = _prefs.getString(_weeklyCommentPinsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => WeeklyCommentNote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWeeklyCommentNotes(List<WeeklyCommentNote> notes) async {
    await _prefs.setString(
      _weeklyCommentPinsKey,
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }

  Future<List<StudyOutline>> getStudyOutlines() async {
    final data = _prefs.getString(_studyOutlinesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => StudyOutline.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveStudyOutlines(List<StudyOutline> outlines) async {
    await _prefs.setString(
      _studyOutlinesKey,
      jsonEncode(outlines.map((o) => o.toJson()).toList()),
    );
  }

  Future<List<TimerPreset>> getTimerPresets() async {
    final data = _prefs.getString(_timerPresetsKey);
    if (data == null) return [TimerPreset.defaultPart10Min()];
    final list = jsonDecode(data) as List<dynamic>;
    final presets = list
        .map((e) => TimerPreset.fromJson(e as Map<String, dynamic>))
        .toList();
    return presets.isEmpty ? [TimerPreset.defaultPart10Min()] : presets;
  }

  Future<void> saveTimerPresets(List<TimerPreset> presets) async {
    await _prefs.setString(
      _timerPresetsKey,
      jsonEncode(presets.map((p) => p.toJson()).toList()),
    );
  }

  Future<List<SelfAssessmentRecord>> getSelfAssessments() async {
    final data = _prefs.getString(_selfAssessmentsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => SelfAssessmentRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSelfAssessments(List<SelfAssessmentRecord> records) async {
    await _prefs.setString(
      _selfAssessmentsKey,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<int>> getWeeklyFocusCharacteristicIds() async {
    final data = _prefs.getStringList(_weeklyFocusCharacteristicsKey);
    if (data == null) return [];
    return data.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();
  }

  Future<void> saveWeeklyFocusCharacteristicIds(List<int> ids) async {
    await _prefs.setStringList(
      _weeklyFocusCharacteristicsKey,
      ids.map((id) => id.toString()).toList(),
    );
  }

  // --- A Sentinela Storage ---
  Future<List<AssentinelStudy>> getAssentinelStudies() async {
    final String? data = _prefs.getString(_assentinelStudiesKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => AssentinelStudy.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAssentinelStudies(List<AssentinelStudy> studies) async {
    final String data = jsonEncode(studies.map((s) => s.toJson()).toList());
    await _prefs.setString(_assentinelStudiesKey, data);
  }

  // --- Partes Storage ---
  Future<List<Parte>> getPartes() async {
    final String? data = _prefs.getString(_partesKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Parte.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePartes(List<Parte> partes) async {
    final String data = jsonEncode(partes.map((p) => p.toJson()).toList());
    await _prefs.setString(_partesKey, data);
  }

  // --- Respostas Geradas Storage ---
  Future<List<RespostaGerada>> getRespostasGeradas() async {
    final String? data = _prefs.getString(_respostasGeradasKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => RespostaGerada.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRespostasGeradas(List<RespostaGerada> respostas) async {
    final String data = jsonEncode(respostas.map((r) => r.toJson()).toList());
    await _prefs.setString(_respostasGeradasKey, data);
  }

  Future<Map<String, String>> getToolSettings(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        );
      }
    } catch (_) {}
    return {};
  }

  Future<void> saveToolSettings(String key, Map<String, String> settings) async {
    await _prefs.setString(key, jsonEncode(settings));
  }

  Future<Map<String, String>> getAssentinelSettings() =>
      getToolSettings(_assentinelSettingsKey);

  Future<void> saveAssentinelSettings(Map<String, String> settings) =>
      saveToolSettings(_assentinelSettingsKey, settings);

  Future<Map<String, String>> getDiscursoSettings() =>
      getToolSettings(_discursoSettingsKey);

  Future<void> saveDiscursoSettings(Map<String, String> settings) =>
      saveToolSettings(_discursoSettingsKey, settings);

  Future<String> getPartePromptGeral() async {
    final map = await getToolSettings(_parteSettingsKey);
    return map['prompt_geral'] ?? '';
  }

  Future<void> savePartePromptGeral(String prompt) =>
      saveToolSettings(_parteSettingsKey, {'prompt_geral': prompt});
}

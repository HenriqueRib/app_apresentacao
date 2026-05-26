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
import '../models/voice_recording.dart';
import '../models/voice_rehearsal_attempt.dart';
import '../models/voice_rehearsal_report_view_mode.dart';
import '../models/voice_rehearsal_session_prefs.dart';
import '../models/voice_rehearsal_streak.dart';
import '../models/voice_rehearsal_smart_flags.dart';
import '../models/voice_rehearsal_next_focus.dart';
import '../models/voice_rehearsal_weekly_goal.dart';
import '../models/voice_volume_calibration.dart';

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
  static const String _voiceRecordingsKey = 'voice_recordings';
  static const String _voiceRehearsalHistoryKey = 'voice_rehearsal_history';
  static const String _voiceVolumeCalibrationKey = 'voice_volume_calibration';
  static const String _voiceCustomFillerWordsKey = 'voice_custom_filler_words';
  static const String _voiceRehearsalOnlineHelpKey =
      'voice_rehearsal_online_help_enabled';
  static const String _voiceRehearsalReportViewModeKey =
      'voice_rehearsal_report_view_mode';
  static const String _voiceRehearsalSessionPrefsKey =
      'voice_rehearsal_session_prefs';
  static const String _voiceRehearsalSmartFlagsKey =
      'voice_rehearsal_smart_flags';
  static const String _voiceRehearsalNextFocusKey = 'voice_rehearsal_next_focus';
  static const String _voiceRehearsalWeeklyGoalKey =
      'voice_rehearsal_weekly_goal';
  static const String _voiceRehearsalLinkedSpeechIdKey =
      'voice_rehearsal_linked_speech_id';
  static const String _voiceRehearsalOnboardingKey =
      'voice_rehearsal_onboarding_done';
  static const String _voiceRehearsalStreakKey = 'voice_rehearsal_streak';
  static const String _voiceRehearsalBlockPracticeIndexKey =
      'voice_rehearsal_block_practice_index';
  static const int _maxVoiceRehearsalHistory = 100;

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

  // --- Gravações Ensaio be-T ---
  Future<List<VoiceRecording>> getVoiceRecordings() async {
    final data = _prefs.getString(_voiceRecordingsKey);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((e) => VoiceRecording.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVoiceRecordings(List<VoiceRecording> recordings) async {
    await _prefs.setString(
      _voiceRecordingsKey,
      jsonEncode(recordings.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> addVoiceRecording(VoiceRecording recording) async {
    final list = await getVoiceRecordings();
    list.insert(0, recording);
    await saveVoiceRecordings(list);
  }

  Future<void> deleteVoiceRecording(String id) async {
    final list = await getVoiceRecordings();
    list.removeWhere((r) => r.id == id);
    await saveVoiceRecordings(list);
  }

  Future<void> updateVoiceRecording(VoiceRecording recording) async {
    final list = await getVoiceRecordings();
    final index = list.indexWhere((r) => r.id == recording.id);
    if (index != -1) {
      list[index] = recording;
      await saveVoiceRecordings(list);
    }
  }

  // --- Histórico de tentativas Ensaio be-T ---
  Future<List<VoiceRehearsalAttempt>> getVoiceRehearsalAttempts() async {
    final data = _prefs.getString(_voiceRehearsalHistoryKey);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((e) => VoiceRehearsalAttempt.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVoiceRehearsalAttempts(List<VoiceRehearsalAttempt> attempts) async {
    await _prefs.setString(
      _voiceRehearsalHistoryKey,
      jsonEncode(attempts.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> addVoiceRehearsalAttempt(VoiceRehearsalAttempt attempt) async {
    final list = await getVoiceRehearsalAttempts();
    list.insert(0, attempt);
    while (list.length > _maxVoiceRehearsalHistory) {
      list.removeLast();
    }
    await saveVoiceRehearsalAttempts(list);
  }

  Future<void> updateVoiceRehearsalAttempt(VoiceRehearsalAttempt attempt) async {
    final list = await getVoiceRehearsalAttempts();
    final index = list.indexWhere((a) => a.id == attempt.id);
    if (index == -1) return;
    list[index] = attempt;
    await saveVoiceRehearsalAttempts(list);
  }

  Future<VoiceRehearsalAttempt?> getVoiceRehearsalAttemptById(String id) async {
    final list = await getVoiceRehearsalAttempts();
    try {
      return list.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteVoiceRehearsalAttempt(String id) async {
    final list = await getVoiceRehearsalAttempts();
    list.removeWhere((a) => a.id == id);
    await saveVoiceRehearsalAttempts(list);
  }

  // --- Calibração de volume Ensaio be-T ---
  Future<VoiceVolumeCalibration?> getVolumeCalibration() async {
    final data = _prefs.getString(_voiceVolumeCalibrationKey);
    if (data == null) return null;
    try {
      return VoiceVolumeCalibration.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVolumeCalibration(VoiceVolumeCalibration calibration) async {
    await _prefs.setString(
      _voiceVolumeCalibrationKey,
      jsonEncode(calibration.toJson()),
    );
  }

  Future<void> clearVolumeCalibration() async {
    await _prefs.remove(_voiceVolumeCalibrationKey);
  }

  // --- Muletas personalizadas Ensaio be-T ---
  Future<List<String>> getCustomFillerWords() async {
    final data = _prefs.getString(_voiceCustomFillerWordsKey);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomFillerWords(List<String> words) async {
    await _prefs.setString(_voiceCustomFillerWordsKey, jsonEncode(words));
  }

  // --- Ajuda online Ensaio be-T ---
  Future<bool> getVoiceRehearsalOnlineHelpEnabled() async {
    return _prefs.getBool(_voiceRehearsalOnlineHelpKey) ?? false;
  }

  Future<void> setVoiceRehearsalOnlineHelpEnabled(bool value) async {
    await _prefs.setBool(_voiceRehearsalOnlineHelpKey, value);
  }

  // --- Modo de visualização do relatório de ensaio ---
  Future<VoiceRehearsalReportViewMode> getVoiceRehearsalReportViewMode() async {
    final raw = _prefs.getString(_voiceRehearsalReportViewModeKey);
    return VoiceRehearsalReportViewMode.fromStorage(raw);
  }

  Future<void> setVoiceRehearsalReportViewMode(
    VoiceRehearsalReportViewMode mode,
  ) async {
    await _prefs.setString(_voiceRehearsalReportViewModeKey, mode.storageKey);
  }

  // --- Metas da sessão ao vivo (Ensaio be-T) ---
  Future<VoiceRehearsalSessionPrefs> getVoiceRehearsalSessionPrefs() async {
    final raw = _prefs.getString(_voiceRehearsalSessionPrefsKey);
    if (raw == null) return VoiceRehearsalSessionPrefs.defaults;
    try {
      return VoiceRehearsalSessionPrefs.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return VoiceRehearsalSessionPrefs.defaults;
    }
  }

  Future<void> setVoiceRehearsalSessionPrefs(
    VoiceRehearsalSessionPrefs prefs,
  ) async {
    await _prefs.setString(
      _voiceRehearsalSessionPrefsKey,
      jsonEncode(prefs.toJson()),
    );
  }

  // --- Modo inteligente Ensaio be-T ---
  Future<VoiceRehearsalSmartFlags> getVoiceRehearsalSmartFlags() async {
    final raw = _prefs.getString(_voiceRehearsalSmartFlagsKey);
    if (raw == null) return VoiceRehearsalSmartFlags.defaults;
    try {
      return VoiceRehearsalSmartFlags.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return VoiceRehearsalSmartFlags.defaults;
    }
  }

  Future<void> setVoiceRehearsalSmartFlags(
    VoiceRehearsalSmartFlags flags,
  ) async {
    await _prefs.setString(
      _voiceRehearsalSmartFlagsKey,
      jsonEncode(flags.toJson()),
    );
  }

  Future<VoiceRehearsalNextFocus?> getVoiceRehearsalNextFocus() async {
    final raw = _prefs.getString(_voiceRehearsalNextFocusKey);
    if (raw == null) return null;
    try {
      return VoiceRehearsalNextFocus.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setVoiceRehearsalNextFocus(VoiceRehearsalNextFocus? focus) async {
    if (focus == null) {
      await _prefs.remove(_voiceRehearsalNextFocusKey);
      return;
    }
    await _prefs.setString(
      _voiceRehearsalNextFocusKey,
      jsonEncode(focus.toJson()),
    );
  }

  Future<VoiceRehearsalWeeklyGoal> getVoiceRehearsalWeeklyGoal() async {
    final raw = _prefs.getString(_voiceRehearsalWeeklyGoalKey);
    if (raw == null) return VoiceRehearsalWeeklyGoal.defaults;
    try {
      return VoiceRehearsalWeeklyGoal.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return VoiceRehearsalWeeklyGoal.defaults;
    }
  }

  Future<void> setVoiceRehearsalWeeklyGoal(
    VoiceRehearsalWeeklyGoal goal,
  ) async {
    await _prefs.setString(
      _voiceRehearsalWeeklyGoalKey,
      jsonEncode(goal.toJson()),
    );
  }

  Future<String?> getVoiceRehearsalLinkedSpeechId() async {
    return _prefs.getString(_voiceRehearsalLinkedSpeechIdKey);
  }

  Future<void> setVoiceRehearsalLinkedSpeechId(String? speechId) async {
    if (speechId == null || speechId.isEmpty) {
      await _prefs.remove(_voiceRehearsalLinkedSpeechIdKey);
      return;
    }
    await _prefs.setString(_voiceRehearsalLinkedSpeechIdKey, speechId);
  }

  Future<bool> isVoiceRehearsalOnboardingDone() async {
    return _prefs.getBool(_voiceRehearsalOnboardingKey) ?? false;
  }

  Future<void> setVoiceRehearsalOnboardingDone(bool value) async {
    await _prefs.setBool(_voiceRehearsalOnboardingKey, value);
  }

  Future<VoiceRehearsalStreak> getVoiceRehearsalStreak() async {
    final raw = _prefs.getString(_voiceRehearsalStreakKey);
    if (raw == null) return const VoiceRehearsalStreak();
    try {
      return VoiceRehearsalStreak.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const VoiceRehearsalStreak();
    }
  }

  Future<VoiceRehearsalStreak> recordVoiceRehearsalStreak({
    required int durationSeconds,
  }) async {
    final current = await getVoiceRehearsalStreak();
    final updated = current.recordSession(
      DateTime.now(),
      minSeconds: durationSeconds,
    );
    await _prefs.setString(
      _voiceRehearsalStreakKey,
      jsonEncode(updated.toJson()),
    );
    return updated;
  }

  Future<int> getVoiceRehearsalBlockPracticeIndex() async {
    return _prefs.getInt(_voiceRehearsalBlockPracticeIndexKey) ?? 0;
  }

  Future<void> setVoiceRehearsalBlockPracticeIndex(int index) async {
    await _prefs.setInt(_voiceRehearsalBlockPracticeIndexKey, index);
  }

  /// Tentativas com `createdAt` na semana ISO atual (segunda a domingo).
  Future<int> countVoiceRehearsalAttemptsThisWeek() async {
    final attempts = await getVoiceRehearsalAttempts();
    final now = DateTime.now();
    final weekStart = _startOfIsoWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    return attempts
        .where(
          (a) =>
              !a.createdAt.isBefore(weekStart) && a.createdAt.isBefore(weekEnd),
        )
        .length;
  }

  static DateTime _startOfIsoWeek(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final weekday = local.weekday;
    return local.subtract(Duration(days: weekday - 1));
  }
}

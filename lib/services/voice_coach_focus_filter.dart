import '../models/voice_rehearsal.dart';
import '../models/voice_rehearsal_smart_flags.dart';

/// Filtra insights e eventos ao vivo conforme o foco do coach.
class VoiceCoachFocusFilter {
  static bool matchesInsight(
    VoiceImprovementInsight insight,
    CoachFocusMode mode,
  ) {
    if (mode == CoachFocusMode.all) return true;
    return switch (mode) {
      CoachFocusMode.muletas =>
        insight.category == 'muleta' || insight.characteristicId == 4,
      CoachFocusMode.ritmo =>
        insight.category == 'ritmo' ||
            insight.category == 'pausas' ||
            insight.characteristicId == 2 ||
            insight.characteristicId == 51,
      CoachFocusMode.volume =>
        insight.category == 'volume' || insight.characteristicId == 8,
      CoachFocusMode.modulacao =>
        insight.category == 'modulacao' || insight.characteristicId == 5,
      CoachFocusMode.estrutura =>
        insight.category.contains('estrutura') ||
            insight.characteristicId == 38 ||
            insight.characteristicId == 39,
      CoachFocusMode.all => true,
    };
  }

  static bool matchesEvent(VoiceFeedbackEvent event, CoachFocusMode mode) {
    if (mode == CoachFocusMode.all) return true;
    return switch (mode) {
      CoachFocusMode.muletas => event.characteristicId == 4,
      CoachFocusMode.ritmo =>
        event.characteristicId == 2 || event.characteristicId == 51,
      CoachFocusMode.volume => event.characteristicId == 8,
      CoachFocusMode.modulacao => event.characteristicId == 5,
      CoachFocusMode.estrutura =>
        event.characteristicId == 38 || event.characteristicId == 39,
      CoachFocusMode.all => true,
    };
  }

  static List<VoiceImprovementInsight> filterInsights(
    List<VoiceImprovementInsight> insights, {
    required bool coachFocusEnabled,
    required CoachFocusMode mode,
    required bool minimalCoach,
  }) {
    var list = insights;
    if (coachFocusEnabled && mode != CoachFocusMode.all) {
      list = list.where((i) => matchesInsight(i, mode)).toList();
    }
    if (minimalCoach) {
      list = list.where((i) => i.severityRank >= 3).toList();
    }
    return list;
  }

  static List<VoiceFeedbackEvent> filterEvents(
    List<VoiceFeedbackEvent> events, {
    required bool coachFocusEnabled,
    required CoachFocusMode mode,
  }) {
    if (!coachFocusEnabled || mode == CoachFocusMode.all) return events;
    return events.where((e) => matchesEvent(e, mode)).toList();
  }
}

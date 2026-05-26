import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal_smart_flags.dart';
import 'package:palestrante_de_sucesso/services/voice_coach_focus_filter.dart';

void main() {
  test('filters muleta insights', () {
    const insights = [
      VoiceImprovementInsight(
        category: 'muleta',
        message: 'm',
        suggestion: 's',
        characteristicId: 4,
      ),
      VoiceImprovementInsight(
        category: 'ritmo',
        message: 'r',
        suggestion: 's',
        characteristicId: 2,
      ),
    ];

    final filtered = VoiceCoachFocusFilter.filterInsights(
      insights,
      coachFocusEnabled: true,
      mode: CoachFocusMode.muletas,
      minimalCoach: false,
    );

    expect(filtered.length, 1);
    expect(filtered.first.category, 'muleta');
  });

  test('minimal coach keeps high severity only', () {
    const insights = [
      VoiceImprovementInsight(
        category: 'muleta',
        message: 'low',
        suggestion: 's',
        severityRank: 1,
      ),
      VoiceImprovementInsight(
        category: 'muleta',
        message: 'high',
        suggestion: 's',
        severityRank: 4,
      ),
    ];

    final filtered = VoiceCoachFocusFilter.filterInsights(
      insights,
      coachFocusEnabled: false,
      mode: CoachFocusMode.all,
      minimalCoach: true,
    );

    expect(filtered.length, 1);
    expect(filtered.first.severityRank, 4);
  });
}

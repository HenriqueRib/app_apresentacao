import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/speech.dart';
import '../models/voice_rehearsal.dart';
import '../providers/speech_provider.dart';
import '../providers/voice_rehearsal_provider.dart';
import '../screens/execution/stage_mode_new_screen.dart';
import '../screens/planning/speech_planning_details_screen.dart';
import '../screens/tools/bet_guide/self_assessment_screen.dart';
import '../screens/tools/bet_guide/voice_rehearsal_history_screen.dart';
import '../utils/voice_rehearsal_ui.dart';
import 'voice_coaching_tip_card.dart';

/// Resumo enxuto pós-sessão: top dicas, integração ciclo e próximos passos.
class VoiceSessionEndSummary extends StatelessWidget {
  final VoiceRehearsalSummary summary;
  final bool includeTipCards;

  const VoiceSessionEndSummary({
    super.key,
    required this.summary,
    this.includeTipCards = true,
  });

  @override
  Widget build(BuildContext context) {
    final topInsights = List<VoiceImprovementInsight>.from(summary.insights)
      ..sort((a, b) => b.severityRank.compareTo(a.severityRank));

    final score = summary.metrics.liveScore;
    final weakIds = weakestCharacteristicIds(summary);

    return Consumer2<VoiceRehearsalProvider, SpeechProvider>(
      builder: (context, rehearsal, speeches, _) {
        final linkedId = rehearsal.linkedSpeechId;
        Speech? linkedSpeech;
        if (linkedId != null) {
          linkedSpeech = speeches.findSpeechById(linkedId);
        }
        final suggestStage = linkedSpeech != null &&
            score >= kStageModeSuggestMinScore;

        return Card(
          margin: EdgeInsets.zero,
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (includeTipCards) ...[
                  Text(
                    'Para subir sua nota na próxima vez',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (topInsights.isEmpty)
                    Text(
                      'Bom trabalho! Continue praticando para manter a consistência.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    ...topInsights.take(3).map(
                          (i) => VoiceCoachingTipCard(
                            insight: i,
                            showActions: true,
                          ),
                        ),
                ] else
                  Text(
                    'Resumo da sessão',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                if (summary.outlineCoveragePercent != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cobertura do esboço: '
                    '${summary.outlineCoveragePercent!.round()}% '
                    'das palavras-chave citadas.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
                if (suggestStage) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.successColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ensaio forte (${score.toStringAsFixed(1)}/10)! '
                          'Que tal simular o palco com o mesmo discurso?',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StageModeNewScreen(
                                speech: linkedSpeech!,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.theater_comedy_outlined,
                              size: 18),
                          label: const Text('Abrir Modo Palco'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (summary.scoreBreakdown.isNotEmpty ||
                    summary.topRepeatedWords.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'Detalhamento da nota',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    children: [
                      if (summary.scoreBreakdown.isNotEmpty)
                        ...summary.scoreBreakdown.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${item.points >= 0 ? '+' : ''}${item.points.toStringAsFixed(1)} ${item.label}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      if (summary.topRepeatedWords.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Palavras mais repetidas:',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        ...summary.topRepeatedWords.map(
                          (w) => Text(
                            "'${w.word}' — ${w.count}x",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
                Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SelfAssessmentScreen(
                            focusCharacteristicId: weakIds.isNotEmpty
                                ? weakIds.first
                                : null,
                            highlightCharacteristicIds: weakIds,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.fact_check, size: 18),
                      label: const Text('Autoavaliação be-T'),
                    ),
                    if (linkedSpeech != null)
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SpeechPlanningDetailsScreen(
                              speech: linkedSpeech!,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.auto_stories_outlined, size: 18),
                        label: const Text('Abrir esboço'),
                      ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VoiceRehearsalHistoryScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Histórico'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

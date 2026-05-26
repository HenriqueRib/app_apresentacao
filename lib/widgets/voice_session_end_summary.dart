import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal.dart';
import '../screens/tools/bet_guide/self_assessment_screen.dart';
import '../screens/tools/bet_guide/voice_rehearsal_history_screen.dart';
import 'voice_coaching_tip_card.dart';

/// Resumo enxuto pós-sessão: top dicas + breakdown colapsável.
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
                      (i) => VoiceCoachingTipCard(insight: i, showActions: true),
                    ),
            ] else
              Text(
                'Resumo da sessão',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (summary.scoreBreakdown.isNotEmpty ||
                summary.topRepeatedWords.isNotEmpty) ...[
              const SizedBox(height: 4),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Detalhamento da nota',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SelfAssessmentScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.fact_check, size: 18),
                  label: const Text('Autoavaliação be-T'),
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
  }
}

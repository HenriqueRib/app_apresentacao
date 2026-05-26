import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/masterclass_step.dart';
import '../models/voice_rehearsal.dart';
import '../services/masterclass_service.dart';

/// Seção offline com dicas do Método Shinyashiki (Roberto Shinyashiki),
/// geradas a partir das métricas do ensaio.
class VoiceShinyashikiFeedbackSection extends StatelessWidget {
  final VoiceRehearsalSummary summary;
  final bool dense;

  const VoiceShinyashikiFeedbackSection({
    super.key,
    required this.summary,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: MasterclassService.instance.loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Não foi possível carregar a masterclass local.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 36,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final steps = MasterclassService.instance.steps;
        if (steps.isEmpty) {
          return Text(
            'Masterclass indisponível.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          );
        }

        final picks = _pickSteps(steps, summary.metrics);
        final primary = picks.isNotEmpty ? picks.first : null;
        final secondary = picks.length > 1 ? picks.sublist(1) : const <MasterclassStep>[];
        final method = 'Roberto Shinyashiki';
        final source = 'Os segredos das apresentações poderosas';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!dense) ...[
              Text(
                'Feedback do $method',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                source,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
            ] else ...[
              Text(
                'Feedback do $method',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
            ],
            if (primary != null)
              _PrimaryTipCard(step: primary, dense: dense),
            if (secondary.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 8),
                child: Text(
                  'Complementos do método',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              ...secondary.map((step) => _StepCard(step: step, dense: dense)),
            ],
          ],
        );
      },
    );
  }

  List<MasterclassStep> _pickSteps(
    List<MasterclassStep> steps,
    VoiceRehearsalMetrics m,
  ) {
    MasterclassStep? byNumber(int n) {
      for (final s in steps) {
        if (s.stepNumber == n) return s;
      }
      return null;
    }

    final scored = <({MasterclassStep step, int score})>[];

    // 3 Treinar: quando WPM fora da faixa ou muletas altas.
    final fillerRatio = m.wordCount > 0 ? (m.fillerCount / m.wordCount) : 0.0;
    final wpmOut = m.wpm > 0 && (m.wpm < 90 || m.wpm > 170);
    if (wpmOut || fillerRatio >= 0.08) {
      final s = byNumber(3);
      if (s != null) {
        final score = (wpmOut ? 3 : 0) + (fillerRatio >= 0.08 ? 2 : 0);
        scored.add((step: s, score: score));
      }
    }

    // 4 Executar: quando pausas longas aparecem.
    if (m.longPauseCount >= 2) {
      final s = byNumber(4);
      if (s != null) {
        scored.add((step: s, score: 2 + m.longPauseCount));
      }
    }

    // 5 Aprimorar: sempre útil no pós.
    final improve = byNumber(5);
    if (improve != null) scored.add((step: improve, score: 1));

    // fallback: garantir ao menos 2 cards.
    if (scored.length < 2) {
      final prepare = byNumber(2);
      if (prepare != null) scored.add((step: prepare, score: 1));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    // Dedup + limitar preservando prioridade.
    final unique = <int, MasterclassStep>{};
    for (final entry in scored) {
      unique.putIfAbsent(entry.step.stepNumber, () => entry.step);
    }
    return unique.values.take(3).toList();
  }
}

class _PrimaryTipCard extends StatelessWidget {
  final MasterclassStep step;
  final bool dense;

  const _PrimaryTipCard({required this.step, required this.dense});

  @override
  Widget build(BuildContext context) {
    final topTip = step.tips.isNotEmpty ? step.tips.first : step.summary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFromName(step.iconName), size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dica principal do Roberto para esta sessão',
                  style: TextStyle(
                    fontSize: dense ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${step.stepNumber}. ${step.title}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            topTip,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final MasterclassStep step;
  final bool dense;

  const _StepCard({required this.step, required this.dense});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10 : 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFromName(step.iconName), size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${step.stepNumber}. ${step.title}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              step.summary,
              style: TextStyle(
                fontSize: dense ? 12 : 13,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
            if (step.tips.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...step.tips.take(3).map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(height: 1.35)),
                          Expanded(
                            child: Text(
                              t,
                              style: const TextStyle(fontSize: 12, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _iconFromName(String name) {
  switch (name) {
    case 'track_changes':
      return Icons.track_changes;
    case 'edit_note':
      return Icons.edit_note;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'record_voice_over':
      return Icons.record_voice_over;
    case 'trending_up':
      return Icons.trending_up;
    default:
      return Icons.school;
  }
}


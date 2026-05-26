import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal.dart';
import '../screens/tools/bet_guide/characteristic_detail_screen.dart';
import '../screens/tools/bet_guide/self_assessment_screen.dart';
import '../services/characteristics_service.dart';
import '../services/voice_speech_structure_analyzer.dart';
import 'voice_coaching_tip_card.dart';

/// Relatório detalhado reutilizável (resumo ao vivo ou histórico).
class VoiceRehearsalReportSection extends StatelessWidget {
  final VoiceRehearsalSummary summary;
  final bool showTranscript;

  const VoiceRehearsalReportSection({
    super.key,
    required this.summary,
    this.showTranscript = true,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = summary.characteristicScores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final weakest = sorted.take(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nota: ${summary.metrics.liveScore.toStringAsFixed(1)}/10 · '
          'Duração: ${_formatTime(summary.metrics.elapsedSeconds)} · '
          'WPM: ${summary.metrics.wpm.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (summary.scoreBreakdown.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Detalhamento da nota:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          ...summary.scoreBreakdown.map((item) => Text(
                '${item.points >= 0 ? '+' : ''}${item.points.toStringAsFixed(1)} ${item.label}',
                style: const TextStyle(fontSize: 12),
              )),
        ],
        if (summary.insights.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'O que melhorar:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          ...summary.insights.take(5).map(
                (i) => VoiceCoachingTipCard(insight: i),
              ),
        ],
        if (summary.topRepeatedWords.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Palavras mais repetidas:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          ...summary.topRepeatedWords.map((w) => Text(
                "'${w.word}' — ${w.count}x",
                style: const TextStyle(fontSize: 12),
              )),
        ],
        if (weakest.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Características be-T a revisar:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          ...weakest.map((entry) => VoiceCharacteristicReviewCard(
                characteristicId: entry.key,
                score: entry.value,
                summary: summary,
              )),
        ],
        ..._structureSections(context),
        if (showTranscript && summary.fullTranscript.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text(
              'Transcrição completa',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  summary.formattedTranscript.isNotEmpty
                      ? summary.formattedTranscript
                      : summary.fullTranscript,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<Widget> _structureSections(BuildContext context) {
    final json = summary.speechStructureJson;
    if (json == null) return const [];

    final structure = SpeechStructureAnalysis.fromJson(json);
    if (structure.intro.text.isEmpty && structure.conclusion.text.isEmpty) {
      return const [];
    }

    return [
      const SizedBox(height: 12),
      Text(
        'Estrutura do discurso (be-T)',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 8),
      if (structure.intro.text.isNotEmpty)
        _SegmentCard(
          title: 'Introdução (${structure.intro.pctOfTotal.toStringAsFixed(0)}%)',
          text: structure.intro.text,
          checks: structure.introChecks,
          characteristicId: 38,
        ),
      if (structure.conclusion.text.isNotEmpty) ...[
        const SizedBox(height: 8),
        _SegmentCard(
          title:
              'Conclusão (${structure.conclusion.pctOfTotal.toStringAsFixed(0)}%)',
          text: structure.conclusion.text,
          checks: structure.conclusionChecks,
          characteristicId: 39,
        ),
      ],
    ];
  }
}

class _SegmentCard extends StatelessWidget {
  final String title;
  final String text;
  final List<RubricCheckItem> checks;
  final int characteristicId;

  const _SegmentCard({
    required this.title,
    required this.text,
    required this.checks,
    required this.characteristicId,
  });

  @override
  Widget build(BuildContext context) {
    final char =
        CharacteristicsService.instance.getCharacteristicById(characteristicId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (char != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '#$characteristicId ${char.title}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
            if (checks.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...checks.map((c) {
                final icon = switch (c.status) {
                  RubricStatus.ok => Icons.check_circle_outline,
                  RubricStatus.atencao => Icons.warning_amber_outlined,
                  RubricStatus.falta => Icons.cancel_outlined,
                };
                final color = switch (c.status) {
                  RubricStatus.ok => AppTheme.successColor,
                  RubricStatus.atencao => AppTheme.warningColor,
                  RubricStatus.falta => AppTheme.errorColor,
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class VoiceCharacteristicReviewCard extends StatelessWidget {
  final int characteristicId;
  final int score;
  final VoiceRehearsalSummary summary;

  const VoiceCharacteristicReviewCard({
    super.key,
    required this.characteristicId,
    required this.score,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final char =
        CharacteristicsService.instance.getCharacteristicById(characteristicId);
    final sessionInsight = summary.insights
        .where((i) => i.characteristicId == characteristicId)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: char != null
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CharacteristicDetailScreen(characteristic: char),
                  ),
                )
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#$characteristicId ${char?.title ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _ScoreBadge(score: score),
                ],
              ),
              if (sessionInsight != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Nesta sessão: ${sessionInsight.message}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warningColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (char != null) ...[
                const SizedBox(height: 8),
                Text(
                  'O que fazer (be-T):',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  char.action,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SelfAssessmentScreen(
                          focusCharacteristicId: characteristicId,
                        ),
                      ),
                    ),
                    child: const Text('Autoavaliar esta char'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final labels = ['Atenção', 'Regular', 'Bom', 'Ótimo'];
    final colors = [
      AppTheme.errorColor,
      AppTheme.warningColor,
      AppTheme.primaryColor,
      AppTheme.successColor,
    ];
    final idx = score.clamp(0, 3);
    return Chip(
      label: Text(
        labels[idx],
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: colors[idx],
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}


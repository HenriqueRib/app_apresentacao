import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/voice_rehearsal_attempt.dart';
import '../../../utils/voice_rehearsal_ui.dart';

/// Comparação de 2–4 tentativas do histórico (tabela + cabeçalhos).
class VoiceRehearsalCompareScreen extends StatelessWidget {
  final List<VoiceRehearsalAttempt> attempts;

  const VoiceRehearsalCompareScreen({
    super.key,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<VoiceRehearsalAttempt>.from(attempts)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (sorted.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comparar ensaios')),
        body: const Center(child: Text('Selecione ao menos 2 ensaios.')),
      );
    }

    final first = sorted.first;
    final last = sorted.last;
    final scoreDelta = last.finalScore - first.finalScore;
    final deltaColor = scoreDelta > 0.05
        ? AppTheme.accentColor
        : scoreDelta < -0.05
            ? AppTheme.errorColor
            : AppTheme.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comparar ${sorted.length} ensaios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 40),
                      child: Icon(Icons.arrow_forward,
                          size: 16, color: AppTheme.textSecondary),
                    ),
                  _AttemptCard(
                    attempt: sorted[i],
                    label: i == 0
                        ? 'Mais antigo'
                        : i == sorted.length - 1
                            ? 'Mais recente'
                            : 'Meio ${i + 1}',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    scoreDelta >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: deltaColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _scoreDeltaLabel(scoreDelta, sorted.length),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: deltaColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CompareTable(attempts: sorted),
        ],
      ),
    );
  }

  String _scoreDeltaLabel(double delta, int count) {
    if (count == 2) {
      if (delta.abs() < 0.05) {
        return 'Notas equivalentes entre os dois ensaios.';
      }
      final sign = delta > 0 ? '+' : '';
      return 'O ensaio mais recente ficou $sign${delta.toStringAsFixed(1)} na nota.';
    }
    if (delta.abs() < 0.05) {
      return 'Nota do mais recente equivalente ao mais antigo.';
    }
    final sign = delta > 0 ? '+' : '';
    return 'Do mais antigo ao mais recente: $sign${delta.toStringAsFixed(1)} na nota.';
  }
}

class _AttemptCard extends StatelessWidget {
  final VoiceRehearsalAttempt attempt;
  final String label;

  const _AttemptCard({
    required this.attempt,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = voiceRehearsalScoreColor(attempt.finalScore);

    return SizedBox(
      width: 140,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                attempt.finalScore.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                'nota / 10',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                attempt.listTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                formatVoiceRehearsalDateTime(attempt.createdAt),
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final List<VoiceRehearsalAttempt> attempts;

  const _CompareTable({required this.attempts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _headerRow(),
            _metricRow(
              'Duração',
              attempts.map((a) => _formatDuration(a.durationSeconds)).toList(),
            ),
            _metricRow(
              'WPM',
              attempts
                  .map((a) => a.summary.metrics.wpm > 0
                      ? a.summary.metrics.wpm.toStringAsFixed(0)
                      : '—')
                  .toList(),
            ),
            _metricRow(
              'Palavras',
              attempts
                  .map((a) => '${a.summary.metrics.wordCount}')
                  .toList(),
            ),
            _metricRow(
              'Muletas',
              attempts
                  .map((a) => '${a.summary.metrics.fillerCount}')
                  .toList(),
            ),
            _metricRow(
              'Pausas longas',
              attempts
                  .map((a) => '${a.summary.metrics.longPauseCount}')
                  .toList(),
            ),
            if (attempts.any(
              (a) => a.summary.outlineCoveragePercent != null,
            ))
              _metricRow(
                'Esboço',
                attempts
                    .map((a) => a.summary.outlineCoveragePercent != null
                        ? '${a.summary.outlineCoveragePercent!.round()}%'
                        : '—')
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Métrica',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          for (var i = 0; i < attempts.length; i++)
            Expanded(
              child: Text(
                '${i + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          for (final value in values)
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

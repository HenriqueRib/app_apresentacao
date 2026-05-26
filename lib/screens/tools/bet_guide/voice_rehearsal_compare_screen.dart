import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/voice_rehearsal_attempt.dart';
import '../../../utils/voice_rehearsal_ui.dart';

/// Comparação lado a lado de duas tentativas do histórico.
class VoiceRehearsalCompareScreen extends StatelessWidget {
  final VoiceRehearsalAttempt older;
  final VoiceRehearsalAttempt newer;

  const VoiceRehearsalCompareScreen({
    super.key,
    required this.older,
    required this.newer,
  });

  @override
  Widget build(BuildContext context) {
    final scoreDelta = newer.finalScore - older.finalScore;
    final deltaColor = scoreDelta > 0.05
        ? AppTheme.accentColor
        : scoreDelta < -0.05
            ? AppTheme.errorColor
            : AppTheme.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar ensaios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CompareHeader(older: older, newer: newer),
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
                      _scoreDeltaLabel(scoreDelta),
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
          _CompareTable(older: older, newer: newer),
        ],
      ),
    );
  }

  String _scoreDeltaLabel(double delta) {
    if (delta.abs() < 0.05) {
      return 'Notas equivalentes entre os dois ensaios.';
    }
    final sign = delta > 0 ? '+' : '';
    return 'O ensaio mais recente ficou $sign${delta.toStringAsFixed(1)} na nota.';
  }
}

class _CompareHeader extends StatelessWidget {
  final VoiceRehearsalAttempt older;
  final VoiceRehearsalAttempt newer;

  const _CompareHeader({
    required this.older,
    required this.newer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _AttemptCard(attempt: older, label: 'Anterior')),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 40),
          child: Icon(Icons.compare_arrows, color: AppTheme.textSecondary),
        ),
        Expanded(child: _AttemptCard(attempt: newer, label: 'Mais recente')),
      ],
    );
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

    return Card(
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
            Text(
              attempt.modeLabel,
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final VoiceRehearsalAttempt older;
  final VoiceRehearsalAttempt newer;

  const _CompareTable({
    required this.older,
    required this.newer,
  });

  @override
  Widget build(BuildContext context) {
    final o = older.summary.metrics;
    final n = newer.summary.metrics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _row(
              'Duração',
              _formatDuration(older.durationSeconds),
              _formatDuration(newer.durationSeconds),
              newer.durationSeconds - older.durationSeconds,
              suffix: 's',
              lowerIsBetter: false,
            ),
            _row(
              'WPM',
              o.wpm > 0 ? o.wpm.toStringAsFixed(0) : '—',
              n.wpm > 0 ? n.wpm.toStringAsFixed(0) : '—',
              (n.wpm - o.wpm).round(),
            ),
            _row(
              'Palavras',
              '${o.wordCount}',
              '${n.wordCount}',
              n.wordCount - o.wordCount,
            ),
            _row(
              'Muletas',
              '${o.fillerCount}',
              '${n.fillerCount}',
              n.fillerCount - o.fillerCount,
              lowerIsBetter: true,
            ),
            _row(
              'Pausas longas',
              '${o.longPauseCount}',
              '${n.longPauseCount}',
              n.longPauseCount - o.longPauseCount,
              lowerIsBetter: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String left,
    String right,
    int delta, {
    String suffix = '',
    bool lowerIsBetter = false,
  }) {
    Color? deltaColor;
    String? deltaText;
    if (delta != 0) {
      final improved = lowerIsBetter ? delta < 0 : delta > 0;
      deltaColor = improved ? AppTheme.accentColor : AppTheme.warningColor;
      final sign = delta > 0 ? '+' : '';
      deltaText = '$sign$delta$suffix';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (deltaText != null)
                  Text(
                    deltaText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: deltaColor,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              right,
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

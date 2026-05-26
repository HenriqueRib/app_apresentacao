import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../utils/voice_rehearsal_ui.dart';
import 'voice_rehearsal_compact_metrics.dart';

/// Cabeçalho de resultado ao encerrar o ensaio (antes do feed de resumo).
class VoiceRehearsalSessionEndHeader extends StatelessWidget {
  final double score;
  final int durationSeconds;
  final String? deltaLabel;
  final Color? deltaColor;

  const VoiceRehearsalSessionEndHeader({
    super.key,
    required this.score,
    required this.durationSeconds,
    this.deltaLabel,
    this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = voiceRehearsalScoreColor(score);

    return Material(
      color: AppTheme.primaryColor.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ensaio encerrado',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    VoiceRehearsalCompactMetrics.formatTime(durationSeconds),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 4),
                      child: Text(
                        '/10',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (deltaLabel != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (deltaColor ?? AppTheme.textSecondary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      deltaLabel!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: deltaColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

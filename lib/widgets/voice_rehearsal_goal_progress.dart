import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'voice_rehearsal_compact_metrics.dart';

/// Barra de progresso em relação à meta de tempo do ensaio.
class VoiceRehearsalGoalProgress extends StatelessWidget {
  final int elapsedSeconds;
  final int goalSeconds;
  final bool minimalStyle;

  const VoiceRehearsalGoalProgress({
    super.key,
    required this.elapsedSeconds,
    required this.goalSeconds,
    this.minimalStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (elapsedSeconds / goalSeconds).clamp(0.0, 1.0);
    final overGoal = elapsedSeconds > goalSeconds;
    final remaining = goalSeconds - elapsedSeconds;
    final color = overGoal
        ? AppTheme.warningColor
        : progress > 0.85
            ? AppTheme.accentColor
            : AppTheme.primaryColor;

    return Material(
      color: minimalStyle ? AppTheme.backgroundColor : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                minHeight: 4,
                backgroundColor: Colors.grey.shade300,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              overGoal
                  ? 'Meta ${VoiceRehearsalCompactMetrics.formatTime(goalSeconds)} — '
                      '+${VoiceRehearsalCompactMetrics.formatTime(elapsedSeconds - goalSeconds)}'
                  : 'Meta ${VoiceRehearsalCompactMetrics.formatTime(goalSeconds)} — '
                      'faltam ${VoiceRehearsalCompactMetrics.formatTime(remaining)}',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

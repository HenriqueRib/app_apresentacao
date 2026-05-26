import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/voice_analysis_engine.dart';
import '../voice_rehearsal_compact_metrics.dart';
import '../voice_rehearsal_goal_progress.dart';
import 'voice_rehearsal_live_context.dart';

/// Cabeçalho fixo ao vivo: nota em destaque, tempo e métricas secundárias.
class VoiceRehearsalLiveCockpit extends StatelessWidget {
  final VoiceRehearsalLiveContext ctx;

  const VoiceRehearsalLiveCockpit({super.key, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final scoreColor = ctx.scoreColor;
    final showGoal = ctx.durationGoalSeconds != null &&
        (ctx.isRecording || ctx.summary != null);
    final isLive = ctx.isRecording && !ctx.isPaused;

    return RepaintBoundary(
      child: Semantics(
        container: true,
        label: 'Painel do ensaio: nota, tempo e métricas',
        child: Material(
      color: AppTheme.surfaceColor,
      elevation: 1,
      shadowColor: Colors.black26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctx.hideScore ? '—' : ctx.score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 36,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: ctx.hideScore
                              ? AppTheme.textSecondary
                              : scoreColor,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'nota / 10',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      VoiceRehearsalCompactMetrics.formatTime(
                        ctx.elapsedSeconds,
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      ctx.isPaused ? 'pausado' : 'tempo',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (ctx.scoreDeltaLabel != null) ...[
                  const SizedBox(width: 10),
                  _DeltaChip(
                    label: ctx.scoreDeltaLabel!,
                    color: ctx.scoreDeltaColor ?? AppTheme.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          if (showGoal)
            VoiceRehearsalGoalProgress(
              elapsedSeconds: ctx.elapsedSeconds,
              goalSeconds: ctx.durationGoalSeconds!,
              minimalStyle: true,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              children: [
                _MetricChip(
                  label: 'WPM',
                  value: ctx.metrics.wpm > 0
                      ? ctx.metrics.wpm.toStringAsFixed(0)
                      : '—',
                ),
                const SizedBox(width: 6),
                _MetricChip(
                  label: 'Muletas',
                  value: '${ctx.metrics.fillerCount}',
                ),
                const SizedBox(width: 6),
                _MetricChip(
                  label: 'Palavras',
                  value: '${ctx.metrics.wordCount}',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _VolumeChip(
                    db: ctx.metrics.avgAmplitudeDb,
                    isActive: isLive,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _DeltaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _VolumeChip extends StatelessWidget {
  final double db;
  final bool isActive;

  const _VolumeChip({required this.db, required this.isActive});

  Color _color(double value) {
    if (value == 0) return Colors.grey;
    if (value < VoiceAnalysisThresholds.volumeLowDb) {
      return AppTheme.warningColor;
    }
    if (value > VoiceAnalysisThresholds.volumeHighDb) {
      return AppTheme.errorColor;
    }
    return AppTheme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(db);
    final fill = isActive ? ((db + 60) / 50).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Volume',
            style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: isActive ? fill.clamp(0.0, 1.0) : 0.0,
              minHeight: 4,
              backgroundColor: Colors.grey.shade300,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

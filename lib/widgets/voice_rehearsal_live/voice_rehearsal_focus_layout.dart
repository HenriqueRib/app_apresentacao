import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../voice_coaching_focus_banner.dart';
import '../voice_rehearsal_goal_progress.dart';
import '../voice_rehearsal_report/voice_rehearsal_score_gauge.dart';
import 'voice_rehearsal_live_context.dart';

/// Layout centralizado do modo foco durante o ensaio.
class VoiceRehearsalFocusLayout extends StatelessWidget {
  final VoiceRehearsalLiveContext ctx;
  final VoidCallback? onScrollToInsight;

  const VoiceRehearsalFocusLayout({
    super.key,
    required this.ctx,
    this.onScrollToInsight,
  });

  @override
  Widget build(BuildContext context) {
    final showGoal = ctx.durationGoalSeconds != null;

    return Expanded(
      child: ColoredBox(
        color: AppTheme.backgroundColor,
        child: Column(
          children: [
            const Spacer(flex: 2),
            VoiceRehearsalScoreGauge(
              score: ctx.score,
              color: ctx.scoreColor,
              size: 120,
            ),
            const SizedBox(height: 12),
            Text(
              ctx.score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(ctx.elapsedSeconds),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            if (ctx.scoreDeltaLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                ctx.scoreDeltaLabel!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ctx.scoreDeltaColor,
                ),
              ),
            ],
            if (showGoal) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: VoiceRehearsalGoalProgress(
                  elapsedSeconds: ctx.elapsedSeconds,
                  goalSeconds: ctx.durationGoalSeconds!,
                ),
              ),
            ],
            const Spacer(),
            if (ctx.topInsight != null)
              VoiceCoachingFocusBanner(
                topInsight: ctx.topInsight,
                onTap: onScrollToInsight,
              ),
            if (ctx.isRecording && !ctx.isPaused)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ctx.isTrainingMode ? 'Ouvindo…' : 'Gravando áudio…',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

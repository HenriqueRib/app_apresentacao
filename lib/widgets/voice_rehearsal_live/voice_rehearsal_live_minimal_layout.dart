import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/voice_rehearsal.dart';
import '../../providers/voice_rehearsal_provider.dart';
import '../voice_coaching_feed.dart';
import '../voice_coaching_focus_banner.dart';
import '../voice_live_transcript_panel.dart';
import '../voice_rehearsal_analyzing_banner.dart';
import '../voice_rehearsal_characteristic_pills.dart';
import '../voice_rehearsal/voice_rehearsal_session_banner.dart';
import '../voice_rehearsal/voice_rehearsal_teleprompter_strip.dart';
import '../voice_rehearsal/voice_rehearsal_warmup_banner.dart';
import '../voice_rehearsal_session_end_header.dart';
import 'voice_rehearsal_focus_layout.dart';
import 'voice_rehearsal_live_bindings.dart';
import 'voice_rehearsal_live_cockpit.dart';
import 'voice_rehearsal_live_context.dart';

class VoiceRehearsalLiveMinimalLayout extends StatelessWidget {
  final VoiceRehearsalProvider provider;
  final VoiceRehearsalLiveBindings bindings;
  final VoiceImprovementInsight? topInsight;

  const VoiceRehearsalLiveMinimalLayout({
    super.key,
    required this.provider,
    required this.bindings,
    this.topInsight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: provider.metricsListenable,
          builder: (context, _) {
            final ctx = VoiceRehearsalLiveContext.fromProvider(
              provider: provider,
              bindings: bindings,
            );
            if (ctx.summary != null) {
              return VoiceRehearsalSessionEndHeader(
                score: ctx.score,
                durationSeconds: ctx.elapsedSeconds,
                deltaLabel: ctx.scoreDeltaLabel,
                deltaColor: ctx.scoreDeltaColor,
              );
            }
            if (!ctx.isRecording) {
              return const SizedBox.shrink();
            }
            return VoiceRehearsalLiveCockpit(ctx: ctx);
          },
        ),
        ListenableBuilder(
          listenable: provider.contentListenable,
          builder: (context, _) => _ContentBlock(
            provider: provider,
            bindings: bindings,
            topInsight: topInsight,
          ),
        ),
      ],
    );
  }
}

class _ContentBlock extends StatelessWidget {
  final VoiceRehearsalProvider provider;
  final VoiceRehearsalLiveBindings bindings;
  final VoiceImprovementInsight? topInsight;

  const _ContentBlock({
    required this.provider,
    required this.bindings,
    this.topInsight,
  });

  @override
  Widget build(BuildContext context) {
    final ctx = VoiceRehearsalLiveContext.fromProvider(
      provider: provider,
      bindings: bindings,
      topInsight: topInsight,
    );
    final focusLive = ctx.focusMode && ctx.isRecording && ctx.summary == null;

    if (!ctx.isRecording && ctx.summary == null) {
      return const SizedBox.shrink();
    }

    if (focusLive) {
      return VoiceRehearsalFocusLayout(
        ctx: ctx,
        onScrollToInsight: ctx.onScrollToFirstInsight,
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const VoiceRehearsalWarmupBanner(),
          const VoiceRehearsalSessionBanner(),
          const VoiceRehearsalTeleprompterStrip(),
          if (ctx.isPaused)
            _PausedBanner(recordingMode: !ctx.isTrainingMode),
          if (!focusLive && ctx.summary == null)
            VoiceRehearsalCharacteristicPills(
              items: ctx.characteristicItems,
              onShowAll: ctx.characteristicItems.length > 3
                  ? () => VoiceRehearsalCharacteristicPills.showAllBottomSheet(
                        context,
                        items: ctx.characteristicItems,
                      )
                  : null,
            ),
          if (ctx.isTrainingMode && ctx.isRecording)
            VoiceLiveTranscriptPanel(
              transcript: ctx.fullTranscript,
              isRecording: ctx.isRecording,
              elapsedSeconds: ctx.elapsedSeconds,
            ),
          if (ctx.isAnalyzingRecording) const VoiceRehearsalAnalyzingBanner(),
          if (ctx.isRecording && ctx.topInsight != null)
            VoiceCoachingFocusBanner(
              topInsight: ctx.topInsight,
              carryOverLabel: ctx.carryOverLabel,
              onTap: ctx.onScrollToFirstInsight,
            ),
          Expanded(child: _buildFeed(ctx)),
        ],
      ),
    );
  }

  Widget _buildFeed(VoiceRehearsalLiveContext ctx) {
    return VoiceCoachingFeed(
      insights: ctx.insights,
      liveEvents: ctx.liveEvents,
      selectedFilter: ctx.selectedFilter,
      onFilterChanged: ctx.onFilterChanged,
      isRecording: ctx.isRecording,
      isTrainingMode: ctx.isTrainingMode,
      speechAvailable: ctx.speechAvailable,
      scrollController: ctx.feedScrollController,
      firstInsightKey: ctx.firstInsightKey,
      sessionSummary: ctx.summary,
      showSessionFooter: ctx.summary != null,
    );
  }

}

class _PausedBanner extends StatelessWidget {
  final bool recordingMode;

  const _PausedBanner({this.recordingMode = false});

  @override
  Widget build(BuildContext context) {
    final message = recordingMode
        ? 'Pausado — o áudio continua gravando. Toque Retomar para voltar ao feedback.'
        : 'Ensaio pausado — toque Retomar para continuar.';

    return Material(
      color: AppTheme.warningColor.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.pause_circle_outline,
                size: 18, color: AppTheme.warningColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 12, color: AppTheme.warningColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

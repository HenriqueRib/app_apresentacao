import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/voice_rehearsal.dart';
import '../../providers/voice_rehearsal_provider.dart';
import '../../services/voice_analysis_engine.dart';
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
import '../voice_rehearsal_report/voice_rehearsal_characteristic_bars.dart';
import '../voice_rehearsal_report/voice_rehearsal_metric_tile.dart';
import '../voice_rehearsal_report/voice_rehearsal_structure_bar.dart';
import 'voice_rehearsal_live_bindings.dart';
import 'voice_rehearsal_live_cockpit.dart';
import 'voice_rehearsal_live_context.dart';

class VoiceRehearsalLiveVisualLayout extends StatelessWidget {
  final VoiceRehearsalProvider provider;
  final VoiceRehearsalLiveBindings bindings;
  final VoiceImprovementInsight? topInsight;

  const VoiceRehearsalLiveVisualLayout({
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
          builder: (context, _) => _MetricsBlock(
            provider: provider,
            bindings: bindings,
          ),
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

class _MetricsBlock extends StatelessWidget {
  final VoiceRehearsalProvider provider;
  final VoiceRehearsalLiveBindings bindings;

  const _MetricsBlock({
    required this.provider,
    required this.bindings,
  });

  @override
  Widget build(BuildContext context) {
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

    if (focusLive) {
      return RepaintBoundary(
        child: VoiceRehearsalFocusLayout(
          ctx: ctx,
          onScrollToInsight: ctx.onScrollToFirstInsight,
        ),
      );
    }

    if (ctx.summary != null) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ctx.isAnalyzingRecording) const VoiceRehearsalAnalyzingBanner(),
            Expanded(child: _buildFeed(ctx)),
          ],
        ),
      );
    }

    return Expanded(
      child: _LiveTabbedContent(ctx: ctx),
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

class _LiveTabbedContent extends StatelessWidget {
  final VoiceRehearsalLiveContext ctx;

  const _LiveTabbedContent({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final tabCount = ctx.isTrainingMode ? 3 : 2;

    return DefaultTabController(
      length: tabCount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const VoiceRehearsalWarmupBanner(),
          const VoiceRehearsalSessionBanner(),
          const VoiceRehearsalTeleprompterStrip(),
          if (ctx.isPaused)
            _PausedBanner(recordingMode: !ctx.isTrainingMode),
          VoiceRehearsalCharacteristicPills(
            items: ctx.characteristicItems,
            onShowAll: ctx.characteristicItems.length > 3
                ? () => VoiceRehearsalCharacteristicPills.showAllBottomSheet(
                      context,
                      items: ctx.characteristicItems,
                    )
                : null,
          ),
          if (ctx.isAnalyzingRecording) const VoiceRehearsalAnalyzingBanner(),
          Material(
            color: AppTheme.surfaceColor,
            child: TabBar(
              isScrollable: tabCount > 2,
              tabAlignment: TabAlignment.fill,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: [
                const Tab(text: 'Métricas'),
                const Tab(text: 'Dicas'),
                if (ctx.isTrainingMode) const Tab(text: 'Transcrição'),
              ],
            ),
          ),
          if (ctx.isRecording && ctx.topInsight != null)
            VoiceCoachingFocusBanner(
              topInsight: ctx.topInsight,
              carryOverLabel: ctx.carryOverLabel,
              onTap: ctx.onScrollToFirstInsight,
            ),
          Expanded(
            child: TabBarView(
              children: [
                _MetricsTab(ctx: ctx),
                _DicasTab(ctx: ctx),
                if (ctx.isTrainingMode) _TranscriptTab(ctx: ctx),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsTab extends StatelessWidget {
  final VoiceRehearsalLiveContext ctx;

  const _MetricsTab({required this.ctx});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              VoiceRehearsalMetricTile(
                icon: Icons.speed,
                value: ctx.metrics.wpm > 0
                    ? ctx.metrics.wpm.toStringAsFixed(0)
                    : '—',
                label: 'WPM',
                accentColor: Colors.teal,
              ),
              VoiceRehearsalMetricTile(
                icon: Icons.chat_bubble_outline,
                value: '${ctx.metrics.fillerCount}',
                label: 'Muletas',
                accentColor: AppTheme.warningColor,
              ),
              VoiceRehearsalMetricTile(
                icon: Icons.pause_circle_outline,
                value: '${ctx.metrics.longPauseCount}',
                label: 'Pausas longas',
                accentColor: AppTheme.secondaryColor,
              ),
              VoiceRehearsalMetricTile(
                icon: Icons.text_fields,
                value: '${ctx.metrics.wordCount}',
                label: 'Palavras',
                accentColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VolumeIndicator(
            db: ctx.metrics.avgAmplitudeDb,
            isRecording: ctx.isRecording && !ctx.isPaused,
          ),
          if (ctx.speechStructureJson != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Estrutura da fala',
              child: VoiceRehearsalStructureBar(
                structureJson: ctx.speechStructureJson,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Características be-T',
            child: VoiceRehearsalCharacteristicBars(
              items: ctx.characteristicItems,
              maxItems: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DicasTab extends StatelessWidget {
  final VoiceRehearsalLiveContext ctx;

  const _DicasTab({required this.ctx});

  @override
  Widget build(BuildContext context) {
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
      showSessionFooter: false,
    );
  }
}

class _TranscriptTab extends StatelessWidget {
  final VoiceRehearsalLiveContext ctx;

  const _TranscriptTab({required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        margin: EdgeInsets.zero,
        child: VoiceLiveTranscriptPanel(
          transcript: ctx.fullTranscript,
          isRecording: ctx.isRecording,
          elapsedSeconds: ctx.elapsedSeconds,
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _VolumeIndicator extends StatelessWidget {
  final double db;
  final bool isRecording;

  const _VolumeIndicator({
    required this.db,
    required this.isRecording,
  });

  Color _volumeColor(double value) {
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
    final color = _volumeColor(db);
    final fill = isRecording ? ((db + 60) / 50).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Volume',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isRecording ? fill.clamp(0.0, 1.0) : 0.0,
            minHeight: 4,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

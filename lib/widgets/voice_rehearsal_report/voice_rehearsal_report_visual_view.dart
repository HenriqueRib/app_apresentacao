import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../voice_coaching_tip_card.dart';
import '../voice_online_analysis_section.dart';
import '../voice_rehearsal_report_section.dart';
import '../voice_s315_feedback_section.dart';
import 'voice_rehearsal_characteristic_bars.dart';
import 'voice_rehearsal_metric_tile.dart';
import 'voice_rehearsal_report_context.dart';
import 'voice_rehearsal_score_gauge.dart';
import 'voice_rehearsal_structure_bar.dart';

class VoiceRehearsalReportVisualView extends StatefulWidget {
  final VoiceRehearsalReportContext ctx;

  const VoiceRehearsalReportVisualView({
    super.key,
    required this.ctx,
  });

  @override
  State<VoiceRehearsalReportVisualView> createState() =>
      _VoiceRehearsalReportVisualViewState();
}

class _VoiceRehearsalReportVisualViewState
    extends State<VoiceRehearsalReportVisualView> {
  bool _s315Expanded = false;
  bool _onlineExpanded = false;
  bool _transcriptExpanded = false;
  bool _betExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final attempt = ctx.attempt;
    final metrics = attempt.summary.metrics;
    final transcript = attempt.summary.fullTranscript.trim();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroHeader(ctx: ctx),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              VoiceRehearsalMetricTile(
                icon: Icons.speed,
                value: metrics.wpm.toStringAsFixed(0),
                label: 'WPM',
                accentColor: Colors.teal,
              ),
              VoiceRehearsalMetricTile(
                icon: Icons.chat_bubble_outline,
                value: '${metrics.fillerCount}',
                label: 'Muletas',
                accentColor: AppTheme.warningColor,
              ),
              VoiceRehearsalMetricTile(
                icon: Icons.pause_circle_outline,
                value: '${metrics.longPauseCount}',
                label: 'Pausas longas',
                accentColor: AppTheme.secondaryColor,
              ),
              VoiceRehearsalMetricTile(
                icon: Icons.text_fields,
                value: '${metrics.wordCount}',
                label: 'Palavras',
                accentColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
        _SectionCard(
          title: 'Estrutura da fala',
          child: VoiceRehearsalStructureBar(
            structureJson: attempt.summary.speechStructureJson,
          ),
        ),
        _SectionCard(
          title: 'Características be-T',
          child: VoiceRehearsalCharacteristicBars(
            items: ctx.characteristicItems,
          ),
        ),
        if (attempt.summary.insights.isNotEmpty)
          _SectionCard(
            title: 'O que melhorar',
            child: Column(
              children: attempt.summary.insights
                  .take(4)
                  .map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: VoiceCoachingTipCard(insight: i),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (ctx.hasRecording)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed: ctx.onPlayRecording,
              icon: Icon(ctx.isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(
                ctx.isPlaying ? 'Parar gravação' : 'Ouvir gravação',
              ),
            ),
          ),
        _ExpandablePanel(
          title: 'Relatório be-T completo',
          expanded: _betExpanded,
          onToggle: () => setState(() => _betExpanded = !_betExpanded),
          child: VoiceRehearsalReportSection(
            summary: attempt.summary,
            showTranscript: false,
          ),
        ),
        _ExpandablePanel(
          title: 'Feedback S-315',
          expanded: _s315Expanded,
          onToggle: () => setState(() => _s315Expanded = !_s315Expanded),
          child: VoiceS315FeedbackSection(
            summary: attempt.summary,
            topic: attempt.topic,
            durationSeconds: attempt.durationSeconds,
            hasRecording: ctx.hasRecording,
            onlineS315: attempt.onlineAnalysis?.s315Enriquecido,
            dense: true,
          ),
        ),
        if (ctx.hasOnlineAnalysis)
          _ExpandablePanel(
            title: 'Análise online',
            expanded: _onlineExpanded,
            onToggle: () => setState(() => _onlineExpanded = !_onlineExpanded),
            child: VoiceOnlineAnalysisSection(
              analysis: attempt.onlineAnalysis!,
              dense: true,
            ),
          ),
        if (transcript.isNotEmpty)
          _ExpandablePanel(
            title: 'Transcrição',
            expanded: _transcriptExpanded,
            onToggle: () =>
                setState(() => _transcriptExpanded = !_transcriptExpanded),
            child: Text(
              attempt.summary.formattedTranscript.isNotEmpty
                  ? attempt.summary.formattedTranscript
                  : transcript,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const _HeroHeader({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final attempt = ctx.attempt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppTheme.shellBackgroundGradient,
      ),
      child: Column(
        children: [
          VoiceRehearsalScoreGauge(
            score: ctx.score,
            color: ctx.scoreColor,
          ),
          const SizedBox(height: 16),
          Text(
            attempt.listTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ctx.formattedDate,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${attempt.modeLabel} · ${ctx.formatDuration(attempt.durationSeconds)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (attempt.topic != null && attempt.topic!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              attempt.topic!.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.shellAccentTeal.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ExpandablePanel extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandablePanel({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}

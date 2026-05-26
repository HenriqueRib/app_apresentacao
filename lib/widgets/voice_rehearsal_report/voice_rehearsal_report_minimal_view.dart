import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/voice_rehearsal_online_payload_builder.dart';
import '../voice_coaching_tip_card.dart';
import '../voice_online_analysis_section.dart';
import '../voice_rehearsal_report_section.dart';
import '../voice_s315_feedback_section.dart';
import 'voice_rehearsal_report_context.dart';

class VoiceRehearsalReportMinimalView extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const VoiceRehearsalReportMinimalView({
    super.key,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderStrip(ctx: ctx),
          Material(
            color: AppTheme.surfaceColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: 'Resumo'),
                Tab(text: 'be-T'),
                Tab(text: 'S-315'),
                Tab(text: 'Mais'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ResumoTab(ctx: ctx),
                _BetTab(ctx: ctx),
                _S315Tab(ctx: ctx),
                _MaisTab(ctx: ctx),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStrip extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const _HeaderStrip({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final attempt = ctx.attempt;
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attempt.listTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            ctx.formattedDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(label: attempt.modeLabel),
              _MetaChip(label: ctx.formatDuration(attempt.durationSeconds)),
              _MetaChip(
                label: '${attempt.finalScore.toStringAsFixed(1)}/10',
                highlighted: true,
                color: ctx.scoreColor,
              ),
              if (attempt.topic != null && attempt.topic!.trim().isNotEmpty)
                _MetaChip(label: attempt.topic!.trim()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  final Color? color;

  const _MetaChip({
    required this.label,
    this.highlighted = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted
            ? accent.withValues(alpha: 0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? accent.withValues(alpha: 0.3)
              : AppTheme.textLight.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
          color: highlighted ? accent : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _ResumoTab extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const _ResumoTab({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final attempt = ctx.attempt;
    final insights = attempt.summary.insights.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Assunto falado',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          attempt.subjectPreview,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        if (ctx.hasRecording) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: ctx.onPlayRecording,
            icon: Icon(ctx.isPlaying ? Icons.stop : Icons.play_arrow),
            label: Text(ctx.isPlaying ? 'Parar gravação' : 'Ouvir gravação'),
          ),
        ],
        if (ctx.onlineHelpEnabled && !ctx.canAnalyzeOnline) ...[
          const SizedBox(height: 16),
          Text(
            'Análise online disponível com transcrição de pelo menos '
            '${VoiceRehearsalOnlinePayloadBuilder.minWordCount} palavras.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
        if (insights.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text(
            'Prioridades',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          ...insights.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VoiceCoachingTipCard(insight: i),
              )),
        ],
      ],
    );
  }
}

class _BetTab extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const _BetTab({required this.ctx});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        VoiceRehearsalReportSection(
          summary: ctx.attempt.summary,
          showTranscript: true,
        ),
      ],
    );
  }
}

class _S315Tab extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const _S315Tab({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final attempt = ctx.attempt;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        VoiceS315FeedbackSection(
          summary: attempt.summary,
          topic: attempt.topic,
          durationSeconds: attempt.durationSeconds,
          hasRecording: ctx.hasRecording,
          onlineS315: attempt.onlineAnalysis?.s315Enriquecido,
          dense: true,
        ),
      ],
    );
  }
}

class _MaisTab extends StatelessWidget {
  final VoiceRehearsalReportContext ctx;

  const _MaisTab({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final attempt = ctx.attempt;
  final transcript = attempt.summary.fullTranscript.trim();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (ctx.hasOnlineAnalysis) ...[
          VoiceOnlineAnalysisSection(
            analysis: attempt.onlineAnalysis!,
            dense: true,
          ),
          const SizedBox(height: 20),
        ] else if (ctx.onlineHelpEnabled) ...[
          Text(
            'Nenhuma análise online ainda. Use o botão na barra superior.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
        ],
        if (transcript.isNotEmpty) ...[
          Text(
            'Transcrição completa',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            attempt.summary.formattedTranscript.isNotEmpty
                ? attempt.summary.formattedTranscript
                : transcript,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ],
    );
  }
}

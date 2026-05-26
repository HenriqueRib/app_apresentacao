import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/s315_speaker_feedback.dart';
import '../models/voice_rehearsal.dart';
import '../models/voice_rehearsal_online_analysis.dart';
import '../services/s315_speaker_feedback_builder.dart';

/// Seção complementar de feedback inspirado no S-315 (histórico de ensaios).
class VoiceS315FeedbackSection extends StatelessWidget {
  final VoiceRehearsalSummary summary;
  final String? topic;
  final int durationSeconds;
  final bool hasRecording;
  final VoiceRehearsalOnlineS315Enriched? onlineS315;
  final bool dense;

  const VoiceS315FeedbackSection({
    super.key,
    required this.summary,
    this.topic,
    required this.durationSeconds,
    this.hasRecording = false,
    this.onlineS315,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final feedback = S315SpeakerFeedbackBuilder.build(
      summary: summary,
      topic: topic,
      durationSeconds: durationSeconds,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!dense)
          Text(
            'Feedback orientado S-315',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        if (!dense) const SizedBox(height: 8),
        _DisclaimerBanner(text: feedback.disclaimer, compact: dense),
        const SizedBox(height: 12),
            if (!feedback.hasSufficientData) ...[
              Text(
                feedback.habilidadeOrador,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (hasRecording) ...[
                const SizedBox(height: 8),
                Text(
                  'Use a tela de Gravações para transcrever e analisar o áudio.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ] else ...[
              _CategoryRow(disGrade: feedback.disGrade, entGrade: feedback.entGrade),
              const SizedBox(height: 16),
              _SubsectionTitle('Habilidade como orador (item 9)'),
              const SizedBox(height: 6),
              Text(
                feedback.habilidadeOrador,
                style: const TextStyle(fontSize: 13, height: 1.45),
              ),
              if (feedback.aspectNotes.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...feedback.aspectNotes.map((n) => _AspectRow(note: n)),
              ],
              const SizedBox(height: 16),
              _SubsectionTitle('Personalidade (item 10)'),
              const SizedBox(height: 6),
              Text(
                feedback.personalidade,
                style: const TextStyle(fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 8),
              Text(
                'ENT (discursos com entrevistas): ${feedback.entGrade} — '
                'não aplicável a ensaio individual.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (onlineS315 != null) ...[
                const SizedBox(height: 16),
                const _SubsectionTitle('Observações enriquecidas (online)'),
                const SizedBox(height: 6),
                Text(
                  onlineS315!.habilidadeOrador,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
                if (onlineS315!.aspectos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...onlineS315!.aspectos.map((n) => _AspectRow(note: n)),
                ],
                const SizedBox(height: 12),
                Text(
                  onlineS315!.personalidade,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
              ],
            ],
          ],
    );

    if (dense) {
      return content;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  final String text;
  final bool compact;

  const _DisclaimerBanner({required this.text, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppTheme.warningColor.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String disGrade;
  final String entGrade;

  const _CategoryRow({
    required this.disGrade,
    required this.entGrade,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Categorias sugeridas:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        _GradeChip(label: 'DIS', grade: disGrade),
        _GradeChip(label: 'ENT', grade: entGrade, muted: true),
      ],
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String label;
  final String grade;
  final bool muted;

  const _GradeChip({
    required this.label,
    required this.grade,
    this.muted = false,
  });

  Color _gradeColor() {
    if (muted || grade == 'NR') return AppTheme.textSecondary;
    if (grade.startsWith('A')) return AppTheme.successColor;
    if (grade.startsWith('B')) return AppTheme.primaryColor;
    return AppTheme.warningColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _gradeColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gradeColor().withValues(alpha: 0.35)),
      ),
      child: Text(
        '$label: $grade',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _gradeColor(),
        ),
      ),
    );
  }
}

class _SubsectionTitle extends StatelessWidget {
  final String text;

  const _SubsectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _AspectRow extends StatelessWidget {
  final S315AspectNote note;

  const _AspectRow({required this.note});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (note.status) {
      S315AspectStatus.ok => (Icons.check_circle_outline, AppTheme.successColor),
      S315AspectStatus.atencao => (Icons.warning_amber_outlined, AppTheme.warningColor),
      S315AspectStatus.falta => (Icons.cancel_outlined, AppTheme.errorColor),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (note.detail != null)
                  Text(
                    note.detail!,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal_session_prefs.dart';
import '../models/speech.dart';
import '../providers/speech_provider.dart';
import '../providers/voice_rehearsal_provider.dart';
import '../utils/voice_rehearsal_navigation.dart';
import 'voice_rehearsal_smart_flags_panel.dart';

/// Painel único antes do ensaio: metas, foco, volume e tema.
class VoiceRehearsalPrepareCard extends StatelessWidget {
  final TextEditingController topicController;
  final TextEditingController? seriesController;
  final TextEditingController? speakerController;
  final double? bestScore;
  final ValueChanged<String>? onTopicChanged;

  const VoiceRehearsalPrepareCard({
    super.key,
    required this.topicController,
    this.seriesController,
    this.speakerController,
    this.bestScore,
    this.onTopicChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        if (provider.isRecording || provider.summary != null) {
          return const SizedBox.shrink();
        }

        final prefs = provider.sessionPrefs;
        final needsVolume = !provider.hasVolumeCalibration;
        final needsGoal = prefs.durationGoalSeconds == null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Preparar ensaio',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (bestScore != null) ...[
                        const Spacer(),
                        Icon(Icons.emoji_events_outlined,
                            size: 16, color: AppTheme.warningColor),
                        const SizedBox(width: 4),
                        Text(
                          'Recorde ${bestScore!.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Meta de tempo',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        VoiceRehearsalSessionPrefs.durationGoalOptions.map(
                      (opt) {
                        return ChoiceChip(
                          label: Text(opt.label),
                          selected: prefs.durationGoalSeconds == opt.seconds,
                          onSelected: (_) =>
                              provider.setDurationGoalSeconds(opt.seconds),
                          visualDensity: VisualDensity.compact,
                          labelStyle: const TextStyle(fontSize: 12),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Modo foco',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Nota, tempo e dica principal — menos distrações.',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: prefs.focusMode,
                    onChanged: provider.setFocusMode,
                  ),
                  if (needsVolume || needsGoal) ...[
                    const Divider(height: 20),
                    if (needsVolume)
                      _HintRow(
                        icon: Icons.graphic_eq,
                        color: AppTheme.warningColor,
                        text: 'Calibre o volume para alertas mais precisos.',
                        action: 'Testar',
                        onAction: () => openVoiceVolumeTest(context),
                      ),
                    if (needsGoal)
                      const _HintRow(
                        icon: Icons.timer_outlined,
                        color: AppTheme.textSecondary,
                        text:
                            'Escolha uma meta de tempo para treinar o ritmo da parte.',
                      ),
                  ],
                  const VoiceRehearsalSmartFlagsPanel(),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickSpeech(context, provider),
                    icon: const Icon(Icons.auto_stories_outlined, size: 18),
                    label: Text(
                      provider.linkedSpeechId != null
                          ? 'Discurso vinculado'
                          : 'Vincular discurso / esboço',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (provider.linkedSpeechId != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => provider.linkSpeech(null),
                        child: const Text('Desvincular', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  if (seriesController != null) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: seriesController,
                      onChanged: provider.setSeriesName,
                      decoration: const InputDecoration(
                        labelText: 'Série / pasta (opcional)',
                        hintText: 'Ex.: Parte março',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                  if (speakerController != null) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: speakerController,
                      onChanged: provider.setSpeakerName,
                      decoration: const InputDecoration(
                        labelText: 'Quem está falando (opcional)',
                        hintText: 'Ex.: Irmão João / Irmã Maria',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: topicController,
                    onChanged: onTopicChanged,
                    decoration: const InputDecoration(
                      labelText: 'Tema do ensaio (opcional)',
                      hintText: 'Ex.: Parte sobre fé…',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickSpeech(
    BuildContext context,
    VoiceRehearsalProvider provider,
  ) async {
    final speeches = context.read<SpeechProvider>().speeches;
    if (speeches.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum discurso no planejamento. Crie um esboço primeiro.'),
          ),
        );
      }
      return;
    }

    final picked = await showModalBottomSheet<Speech>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: speeches
              .map(
                (s) => ListTile(
                  title: Text(s.title),
                  subtitle: s.theme.isNotEmpty ? Text(s.theme) : null,
                  onTap: () => Navigator.pop(context, s),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (picked != null) {
      await provider.linkSpeech(picked);
    }
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  const _HintRow({
    required this.icon,
    required this.color,
    required this.text,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ),
          if (action != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(action!, style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

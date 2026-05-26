import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/voice_recording.dart';
import '../../../models/voice_rehearsal.dart';
import '../../../providers/voice_recordings_provider.dart';
import '../../../widgets/voice_rehearsal_report_section.dart';

class VoiceRecordingsScreen extends StatefulWidget {
  const VoiceRecordingsScreen({super.key});

  @override
  State<VoiceRecordingsScreen> createState() => _VoiceRecordingsScreenState();
}

class _VoiceRecordingsScreenState extends State<VoiceRecordingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceRecordingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravações de ensaio'),
      ),
      body: Consumer<VoiceRecordingsProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.recordings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhuma gravação salva.\nUse "Gravar ensaio" no Ensaio be-T.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.recordings.length,
            itemBuilder: (context, index) {
              final recording = provider.recordings[index];
              final isPlaying = provider.playingId == recording.id;
              final isAnalyzing = provider.analyzingId == recording.id;
              final needsTranscript = provider.needsAnalysis(recording);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _scoreColor(recording.finalScore),
                    child: Text(
                      recording.finalScore.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(recording.displayTitle),
                  subtitle: Text(
                    '${_formatDate(recording.createdAt)} · '
                    '${_formatTime(recording.durationSeconds)} · '
                    'Nota ${recording.finalScore.toStringAsFixed(1)}'
                    '${needsTranscript ? ' · sem transcrição' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAnalyzing)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (needsTranscript)
                        IconButton(
                          icon: const Icon(Icons.transcribe),
                          tooltip: 'Transcrever e analisar',
                          onPressed: () => _analyzeRecording(context, recording),
                        ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                        onPressed: () => provider.play(recording),
                      ),
                      IconButton(
                        icon: const Icon(Icons.summarize_outlined),
                        onPressed: () => _showSummary(context, recording),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, recording),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score < 5) return AppTheme.errorColor;
    if (score < 7) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  Future<void> _analyzeRecording(
    BuildContext context,
    VoiceRecording recording,
  ) async {
    final provider = context.read<VoiceRecordingsProvider>();
    final summary = await provider.analyzeRecording(recording);
    if (!context.mounted) return;
    if (summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível transcrever. Tente em ambiente silencioso.',
          ),
        ),
      );
      return;
    }
    _showSummary(context, recording.copyWith(summary: summary));
  }

  void _showSummary(BuildContext context, VoiceRecording recording) {
    final summary = recording.summary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                recording.displayTitle,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (summary == null)
                const Text('Resumo não disponível para esta gravação.')
              else
                VoiceRehearsalReportSection(summary: summary),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VoiceRecording recording,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir gravação?'),
        content: Text('Remover "${recording.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<VoiceRecordingsProvider>().delete(recording.id);
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

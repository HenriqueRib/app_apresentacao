import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/voice_rehearsal_attempt.dart';
import '../../../models/voice_rehearsal_report_view_mode.dart';
import '../../../providers/voice_rehearsal_history_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/voice_rehearsal_online_payload_builder.dart';
import '../../../services/voice_rehearsal_online_service.dart';
import '../../../services/voice_rehearsal_report_exporter.dart';
import '../../../widgets/voice_rehearsal_report/voice_rehearsal_report_context.dart';
import '../../../widgets/voice_rehearsal_report/voice_rehearsal_report_minimal_view.dart';
import '../../../widgets/voice_rehearsal_report/voice_rehearsal_report_visual_view.dart';

class VoiceRehearsalHistoryDetailScreen extends StatefulWidget {
  final String attemptId;

  const VoiceRehearsalHistoryDetailScreen({
    super.key,
    required this.attemptId,
  });

  @override
  State<VoiceRehearsalHistoryDetailScreen> createState() =>
      _VoiceRehearsalHistoryDetailScreenState();
}

class _VoiceRehearsalHistoryDetailScreenState
    extends State<VoiceRehearsalHistoryDetailScreen> {
  VoiceRehearsalAttempt? _attempt;
  bool _loading = true;
  bool _onlineHelpEnabled = false;
  bool _analyzingOnline = false;
  VoiceRehearsalReportViewMode _viewMode = VoiceRehearsalReportViewMode.minimal;
  final _onlineService = VoiceRehearsalOnlineService();

  @override
  void initState() {
    super.initState();
    _loadAttempt();
  }

  Future<void> _loadAttempt() async {
    final storage = await StorageService.getInstance();
    final attempt = await storage.getVoiceRehearsalAttemptById(widget.attemptId);
    final onlineHelp = await storage.getVoiceRehearsalOnlineHelpEnabled();
    final viewMode = await storage.getVoiceRehearsalReportViewMode();
    if (mounted) {
      setState(() {
        _attempt = attempt;
        _onlineHelpEnabled = onlineHelp;
        _viewMode = viewMode;
        _loading = false;
      });
    }
  }

  VoiceRehearsalReportContext _buildContext(
    VoiceRehearsalAttempt attempt,
    VoiceRehearsalHistoryProvider provider,
  ) {
    final hasRecording = attempt.recordingFilePath != null &&
        File(attempt.recordingFilePath!).existsSync();

    return VoiceRehearsalReportContext.fromAttempt(
      attempt: attempt,
      hasRecording: hasRecording,
      isPlaying: provider.playingId == attempt.id,
      onlineHelpEnabled: _onlineHelpEnabled,
      canAnalyzeOnline: VoiceRehearsalOnlinePayloadBuilder.canAnalyze(attempt),
      isAnalyzingOnline: _analyzingOnline,
      onPlayRecording:
          hasRecording ? () => provider.playRecording(attempt) : null,
      onOnlineAnalysis: _runOnlineAnalysis,
    );
  }

  Future<void> _runOnlineAnalysis() async {
    final attempt = _attempt;
    if (attempt == null || _analyzingOnline) return;

    if (!VoiceRehearsalOnlinePayloadBuilder.canAnalyze(attempt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transcrição insuficiente. Use o modo Treino ou transcreva a gravação.',
          ),
        ),
      );
      return;
    }

    setState(() => _analyzingOnline = true);
    try {
      final analysis = await _onlineService.analyze(attempt);
      final updated = attempt.copyWith(onlineAnalysis: analysis);
      final storage = await StorageService.getInstance();
      await storage.updateVoiceRehearsalAttempt(updated);
      if (mounted) {
        context.read<VoiceRehearsalHistoryProvider>().refreshAttempt(updated);
        setState(() => _attempt = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Análise online concluída.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(VoiceRehearsalOnlineService.userMessageFor(e)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _analyzingOnline = false);
    }
  }

  Future<void> _setViewMode(VoiceRehearsalReportViewMode mode) async {
    if (_viewMode == mode) return;
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalReportViewMode(mode);
    if (mounted) setState(() => _viewMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relatório do ensaio')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final attempt = _attempt;
    if (attempt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relatório do ensaio')),
        body: const Center(child: Text('Ensaio não encontrado.')),
      );
    }

    final canAnalyze = VoiceRehearsalOnlinePayloadBuilder.canAnalyze(attempt);
    final hasOnlineAnalysis = attempt.onlineAnalysis != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório do ensaio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Exportar relatório',
            onPressed: () {
              Share.share(
                VoiceRehearsalReportExporter.toPlainText(attempt),
                subject: 'Ensaio be-T — ${attempt.listTitle}',
              );
            },
          ),
          if (_onlineHelpEnabled)
            IconButton(
              onPressed: (_analyzingOnline || !canAnalyze)
                  ? null
                  : _runOnlineAnalysis,
              tooltip: hasOnlineAnalysis ? 'Reanalisar online' : 'Análise online',
              icon: _analyzingOnline
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      hasOnlineAnalysis
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_outlined,
                    ),
            ),
          PopupMenuButton<VoiceRehearsalReportViewMode>(
            icon: const Icon(Icons.view_comfy_alt_outlined),
            tooltip: 'Modo de visualização',
            onSelected: _setViewMode,
            itemBuilder: (context) => VoiceRehearsalReportViewMode.values
                .map(
                  (mode) => PopupMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        if (_viewMode == mode)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(mode.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Consumer<VoiceRehearsalHistoryProvider>(
        builder: (context, provider, _) {
          final ctx = _buildContext(attempt, provider);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _viewMode == VoiceRehearsalReportViewMode.minimal
                ? VoiceRehearsalReportMinimalView(
                    key: const ValueKey('minimal'),
                    ctx: ctx,
                  )
                : VoiceRehearsalReportVisualView(
                    key: const ValueKey('visual'),
                    ctx: ctx,
                  ),
          );
        },
      ),
    );
  }
}

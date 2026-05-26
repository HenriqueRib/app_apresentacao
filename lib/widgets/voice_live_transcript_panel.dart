import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/voice_speech_structure_analyzer.dart';

/// Painel compacto de transcrição ao vivo durante o ensaio.
class VoiceLiveTranscriptPanel extends StatefulWidget {
  final String transcript;
  final bool isRecording;
  final int elapsedSeconds;
  final bool expanded;

  const VoiceLiveTranscriptPanel({
    super.key,
    required this.transcript,
    required this.isRecording,
    required this.elapsedSeconds,
    this.expanded = false,
  });

  @override
  State<VoiceLiveTranscriptPanel> createState() =>
      _VoiceLiveTranscriptPanelState();
}

class _VoiceLiveTranscriptPanelState extends State<VoiceLiveTranscriptPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _collapsed = !widget.expanded;
  }

  @override
  void didUpdateWidget(covariant VoiceLiveTranscriptPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transcript != oldWidget.transcript && widget.isRecording) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  SpeechPhase get _phase =>
      VoiceSpeechStructureAnalyzer.currentPhaseByElapsedOnly(
        widget.elapsedSeconds,
      );

  Color get _phaseColor {
    switch (_phase) {
      case SpeechPhase.intro:
        return Colors.blue.shade700;
      case SpeechPhase.body:
        return AppTheme.primaryColor;
      case SpeechPhase.conclusion:
        return Colors.deepOrange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording && widget.transcript.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final text = widget.transcript.trim();
    final preview = text.isEmpty
        ? 'Ouvindo… fale naturalmente.'
        : (text.length > 120 ? '…${text.substring(text.length - 120)}' : text);

    return Material(
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _collapsed = !_collapsed),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _collapsed ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Transcrição ao vivo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (widget.isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _phaseColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _phase.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _phaseColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!_collapsed)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Text(
                      preview,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: text.isEmpty
                            ? AppTheme.textSecondary
                            : Colors.black87,
                        fontStyle:
                            text.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

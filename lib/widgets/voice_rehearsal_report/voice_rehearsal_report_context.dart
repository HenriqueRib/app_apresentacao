import 'package:flutter/material.dart';

import '../../models/voice_rehearsal_attempt.dart';
import '../../services/characteristics_service.dart';
import '../../utils/voice_rehearsal_ui.dart';

@immutable
class VoiceRehearsalReportContext {
  final VoiceRehearsalAttempt attempt;
  final bool hasRecording;
  final bool isPlaying;
  final bool onlineHelpEnabled;
  final bool canAnalyzeOnline;
  final bool isAnalyzingOnline;
  final VoidCallback? onPlayRecording;
  final VoidCallback? onOnlineAnalysis;
  final DateTime createdAt;
  final String formattedDate;

  const VoiceRehearsalReportContext({
    required this.attempt,
    required this.hasRecording,
    this.isPlaying = false,
    this.onlineHelpEnabled = false,
    this.canAnalyzeOnline = false,
    this.isAnalyzingOnline = false,
    this.onPlayRecording,
    this.onOnlineAnalysis,
    required this.createdAt,
    required this.formattedDate,
  });

  factory VoiceRehearsalReportContext.fromAttempt({
    required VoiceRehearsalAttempt attempt,
    required bool hasRecording,
    bool isPlaying = false,
    bool onlineHelpEnabled = false,
    bool canAnalyzeOnline = false,
    bool isAnalyzingOnline = false,
    VoidCallback? onPlayRecording,
    VoidCallback? onOnlineAnalysis,
  }) {
    return VoiceRehearsalReportContext(
      attempt: attempt,
      hasRecording: hasRecording,
      isPlaying: isPlaying,
      onlineHelpEnabled: onlineHelpEnabled,
      canAnalyzeOnline: canAnalyzeOnline,
      isAnalyzingOnline: isAnalyzingOnline,
      onPlayRecording: onPlayRecording,
      onOnlineAnalysis: onOnlineAnalysis,
      createdAt: attempt.createdAt,
      formattedDate: formatVoiceRehearsalDateTime(attempt.createdAt),
    );
  }

  double get score => attempt.finalScore;
  Color get scoreColor => voiceRehearsalScoreColor(score);

  String formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<CharacteristicStripItem> get characteristicItems =>
      buildCharacteristicStripItems(
        events: attempt.summary.events,
        summary: attempt.summary,
        resolveTitle: (id) =>
            CharacteristicsService.instance.getCharacteristicById(id)?.title,
      );

  bool get hasOnlineAnalysis => attempt.onlineAnalysis != null;
}

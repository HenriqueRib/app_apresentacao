import 'package:flutter/material.dart';

import '../../models/voice_rehearsal.dart';
import '../../providers/voice_rehearsal_provider.dart';
import '../../services/characteristics_service.dart';
import '../../utils/voice_rehearsal_ui.dart';
import '../voice_coaching_feed.dart';
import 'voice_rehearsal_live_bindings.dart';

/// Estado de UI ao vivo para layouts Minimalista e Dinâmico.
class VoiceRehearsalLiveContext {
  final double score;
  final int elapsedSeconds;
  final VoiceRehearsalMetrics metrics;
  final bool isRecording;
  final bool isTrainingMode;
  final bool speechAvailable;
  final bool isAnalyzingRecording;
  final List<VoiceImprovementInsight> insights;
  final List<VoiceFeedbackEvent> liveEvents;
  final VoiceRehearsalSummary? summary;
  final String fullTranscript;
  final String? scoreDeltaLabel;
  final Color? scoreDeltaColor;
  final VoiceImprovementInsight? topInsight;
  final CoachingCategoryFilter selectedFilter;
  final ValueChanged<CoachingCategoryFilter>? onFilterChanged;
  final ScrollController? feedScrollController;
  final GlobalKey? firstInsightKey;
  final VoidCallback? onScrollToFirstInsight;
  final List<CharacteristicStripItem> characteristicItems;
  final int? durationGoalSeconds;
  final bool focusMode;
  final bool isPaused;
  final bool isWarmupPhase;
  final bool hideScore;

  const VoiceRehearsalLiveContext({
    required this.score,
    required this.elapsedSeconds,
    required this.metrics,
    required this.isRecording,
    required this.isTrainingMode,
    required this.speechAvailable,
    required this.isAnalyzingRecording,
    required this.insights,
    required this.liveEvents,
    required this.summary,
    required this.fullTranscript,
    this.scoreDeltaLabel,
    this.scoreDeltaColor,
    this.topInsight,
    required this.selectedFilter,
    this.onFilterChanged,
    this.feedScrollController,
    this.firstInsightKey,
    this.onScrollToFirstInsight,
    required this.characteristicItems,
    this.durationGoalSeconds,
    this.focusMode = false,
    this.isPaused = false,
    this.isWarmupPhase = false,
    this.hideScore = false,
  });

  factory VoiceRehearsalLiveContext.fromProvider({
    required VoiceRehearsalProvider provider,
    required VoiceRehearsalLiveBindings bindings,
    VoiceImprovementInsight? topInsight,
  }) {
    final score = provider.displayScore ??
        (provider.isRecording || provider.summary != null
            ? (provider.summary?.metrics.liveScore ?? provider.liveScore)
            : provider.liveScore);

    String? scoreDeltaLabel;
    Color? scoreDeltaColor;
    if (provider.summary != null) {
      scoreDeltaLabel = bindings.postScoreDeltaLabel;
      scoreDeltaColor = bindings.postScoreDeltaColor;
    } else if (provider.isRecording && bindings.baselineBestScore != null) {
      final live = liveScoreVsBestLabel(
        liveScore: provider.liveScore,
        bestScore: bindings.baselineBestScore,
      );
      scoreDeltaLabel = live.label;
      scoreDeltaColor = live.color;
    }

    return VoiceRehearsalLiveContext(
      score: score,
      elapsedSeconds: provider.elapsedSeconds,
      metrics: provider.metrics,
      isRecording: provider.isRecording,
      isTrainingMode: provider.isTrainingMode,
      speechAvailable: provider.speechAvailable,
      isAnalyzingRecording: provider.isAnalyzingRecording,
      insights: provider.insights,
      liveEvents: provider.filteredLiveEvents,
      summary: provider.summary,
      fullTranscript: provider.fullTranscript,
      scoreDeltaLabel: scoreDeltaLabel,
      scoreDeltaColor: scoreDeltaColor,
      topInsight: topInsight,
      selectedFilter: bindings.selectedFilter,
      onFilterChanged: bindings.onFilterChanged,
      feedScrollController: bindings.feedScrollController,
      firstInsightKey: bindings.firstInsightKey,
      onScrollToFirstInsight: bindings.onScrollToFirstInsight,
      characteristicItems: buildCharacteristicStripItems(
        events: provider.summary?.events ?? provider.liveEvents,
        summary: provider.summary,
        resolveTitle: (id) =>
            CharacteristicsService.instance.getCharacteristicById(id)?.title,
      ),
      durationGoalSeconds: provider.durationGoalSeconds,
      focusMode: provider.focusMode,
      isPaused: provider.isPaused,
      isWarmupPhase: provider.isWarmupPhase,
      hideScore: provider.isWarmupPhase,
    );
  }

  Color get scoreColor => voiceRehearsalScoreColor(score);

  Map<String, dynamic>? get speechStructureJson =>
      summary?.speechStructureJson;
}

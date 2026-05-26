import 'package:flutter/material.dart';

import '../voice_coaching_feed.dart';

/// Estado da tela que não vive no [VoiceRehearsalProvider].
class VoiceRehearsalLiveBindings {
  final CoachingCategoryFilter selectedFilter;
  final ValueChanged<CoachingCategoryFilter>? onFilterChanged;
  final ScrollController? feedScrollController;
  final GlobalKey? firstInsightKey;
  final VoidCallback? onScrollToFirstInsight;
  final String? postScoreDeltaLabel;
  final Color? postScoreDeltaColor;
  final double? baselineBestScore;

  const VoiceRehearsalLiveBindings({
    required this.selectedFilter,
    this.onFilterChanged,
    this.feedScrollController,
    this.firstInsightKey,
    this.onScrollToFirstInsight,
    this.postScoreDeltaLabel,
    this.postScoreDeltaColor,
    this.baselineBestScore,
  });
}

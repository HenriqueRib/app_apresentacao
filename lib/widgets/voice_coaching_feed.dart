import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/oratory_characteristic.dart';
import '../models/voice_rehearsal.dart';
import '../screens/tools/bet_guide/characteristic_detail_screen.dart';
import '../services/characteristics_service.dart';
import 'voice_coaching_tip_card.dart';
import 'voice_session_end_summary.dart';

enum CoachingCategoryFilter { all, ritmo, muletas, volume, positivos }

extension CoachingCategoryFilterX on CoachingCategoryFilter {
  String get label {
    switch (this) {
      case CoachingCategoryFilter.all:
        return 'Todas';
      case CoachingCategoryFilter.ritmo:
        return 'Ritmo';
      case CoachingCategoryFilter.muletas:
        return 'Muletas';
      case CoachingCategoryFilter.volume:
        return 'Volume';
      case CoachingCategoryFilter.positivos:
        return 'Positivos';
    }
  }
}

bool insightMatchesFilter(VoiceImprovementInsight insight, CoachingCategoryFilter filter) {
  switch (filter) {
    case CoachingCategoryFilter.all:
      return true;
    case CoachingCategoryFilter.ritmo:
      return insight.category == 'ritmo' || insight.category == 'pausas';
    case CoachingCategoryFilter.muletas:
      return insight.category == 'muleta' ||
          insight.category == 'repeticao' ||
          insight.category == 'vaga';
    case CoachingCategoryFilter.volume:
      return insight.category == 'volume' || insight.category == 'modulacao';
    case CoachingCategoryFilter.positivos:
      return false;
  }
}

bool eventMatchesFilter(VoiceFeedbackEvent event, CoachingCategoryFilter filter) {
  switch (filter) {
    case CoachingCategoryFilter.positivos:
      return event.severity == VoiceFeedbackSeverity.positive;
    case CoachingCategoryFilter.all:
      return event.severity != VoiceFeedbackSeverity.positive;
    case CoachingCategoryFilter.ritmo:
      return event.characteristicId == 28 || event.characteristicId == 29;
    case CoachingCategoryFilter.muletas:
      return event.characteristicId == 4 || event.characteristicId == 24;
    case CoachingCategoryFilter.volume:
      return event.characteristicId == 26 || event.characteristicId == 27;
  }
}

bool _insightCoversEvent(
  VoiceImprovementInsight insight,
  VoiceFeedbackEvent event,
) {
  if (insight.characteristicId != null &&
      insight.characteristicId == event.characteristicId) {
    return true;
  }
  return false;
}

/// Feed unificado de dicas de coaching + alertas ao vivo.
class VoiceCoachingFeed extends StatelessWidget {
  final List<VoiceImprovementInsight> insights;
  final List<VoiceFeedbackEvent> liveEvents;
  final CoachingCategoryFilter selectedFilter;
  final ValueChanged<CoachingCategoryFilter>? onFilterChanged;
  final bool isRecording;
  final bool isTrainingMode;
  final bool speechAvailable;
  final ScrollController? scrollController;
  final GlobalKey? firstInsightKey;
  final VoiceRehearsalSummary? sessionSummary;
  final bool showSessionFooter;

  const VoiceCoachingFeed({
    super.key,
    required this.insights,
    required this.liveEvents,
    required this.selectedFilter,
    this.onFilterChanged,
    this.isRecording = false,
    this.isTrainingMode = true,
    this.speechAvailable = true,
    this.scrollController,
    this.firstInsightKey,
    this.sessionSummary,
    this.showSessionFooter = false,
  });

  List<VoiceImprovementInsight> get _sortedInsights {
    final source = sessionSummary?.insights ?? insights;
    final copy = List<VoiceImprovementInsight>.from(source)
      ..sort((a, b) => b.severityRank.compareTo(a.severityRank));
    return copy
        .where((i) => insightMatchesFilter(i, selectedFilter))
        .toList();
  }

  List<VoiceFeedbackEvent> get _filteredEvents {
    final eventSource = sessionSummary?.events ?? liveEvents;
    final insightSource = sessionSummary?.insights ?? insights;
    final coveredCharIds = insightSource
        .where((i) => i.characteristicId != null)
        .map((i) => i.characteristicId!)
        .toSet();

    return eventSource.where((event) {
      if (!eventMatchesFilter(event, selectedFilter)) return false;
      if (coveredCharIds.contains(event.characteristicId)) {
        final hasInsight =
            insightSource.any((i) => _insightCoversEvent(i, event));
        if (hasInsight) return false;
      }
      return true;
    }).toList();
  }

  bool get _hasFilterableContent {
    final eventSource = sessionSummary?.events ?? liveEvents;
    final insightSource = sessionSummary?.insights ?? insights;
    return insightSource.isNotEmpty || eventSource.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedInsights;
    final events = _filteredEvents;
    final hasContent =
        sorted.isNotEmpty || events.isNotEmpty || showSessionFooter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasFilterableContent && onFilterChanged != null)
          _CategoryFilterBar(
            selected: selectedFilter,
            onSelected: onFilterChanged!,
          ),
        Expanded(
          child: hasContent
              ? ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  children: [
                    if (sorted.isNotEmpty)
                      Text(
                        showSessionFooter
                            ? 'Feedback da sessão'
                            : 'Dicas para subir sua nota',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ...sorted.asMap().entries.map((entry) {
                      final index = entry.key;
                      final insight = entry.value;
                      return VoiceCoachingTipCard(
                        key: index == 0 ? firstInsightKey : null,
                        insight: insight,
                        showActions: true,
                      );
                    }),
                    if (events.isNotEmpty) ...[
                      if (sorted.isNotEmpty) const SizedBox(height: 8),
                      Text(
                        'Alertas ao vivo',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      ...events.map(
                        (e) => _LiveAlertCard(
                          event: e,
                          onOpenCharacteristic: (char) =>
                              _openCharacteristic(context, char),
                        ),
                      ),
                    ],
                    if (showSessionFooter && sessionSummary != null) ...[
                      const SizedBox(height: 8),
                      VoiceSessionEndSummary(
                        summary: sessionSummary!,
                        includeTipCards: false,
                      ),
                    ],
                  ],
                )
              : _EmptyFeedState(
                  isRecording: isRecording,
                  isTrainingMode: isTrainingMode,
                  speechAvailable: speechAvailable,
                  filter: selectedFilter,
                ),
        ),
      ],
    );
  }

  void _openCharacteristic(BuildContext context, OratoryCharacteristic char) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacteristicDetailScreen(characteristic: char),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final CoachingCategoryFilter selected;
  final ValueChanged<CoachingCategoryFilter> onSelected;

  const _CategoryFilterBar({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: CoachingCategoryFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.grey.shade100,
              checkmarkColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LiveAlertCard extends StatelessWidget {
  final VoiceFeedbackEvent event;
  final void Function(OratoryCharacteristic char) onOpenCharacteristic;

  const _LiveAlertCard({
    required this.event,
    required this.onOpenCharacteristic,
  });

  @override
  Widget build(BuildContext context) {
    final char = CharacteristicsService.instance.getCharacteristicById(
      event.characteristicId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _severityIcon(event.severity),
        title: Text(
          char != null ? '#${char.id} ${char.title}' : event.message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: char != null
            ? Text(event.message, style: const TextStyle(fontSize: 12))
            : null,
        dense: true,
        onTap: char != null ? () => onOpenCharacteristic(char) : null,
      ),
    );
  }

  Widget _severityIcon(VoiceFeedbackSeverity severity) {
    switch (severity) {
      case VoiceFeedbackSeverity.positive:
        return const Icon(Icons.check_circle, color: AppTheme.successColor, size: 22);
      case VoiceFeedbackSeverity.warning:
        return const Icon(Icons.warning_amber, color: AppTheme.warningColor, size: 22);
      case VoiceFeedbackSeverity.info:
        return const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 22);
    }
  }
}

class _EmptyFeedState extends StatelessWidget {
  final bool isRecording;
  final bool isTrainingMode;
  final bool speechAvailable;
  final CoachingCategoryFilter filter;

  const _EmptyFeedState({
    required this.isRecording,
    required this.isTrainingMode,
    required this.speechAvailable,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    if (filter != CoachingCategoryFilter.all) {
      message = 'Nenhuma dica nesta categoria ainda.';
    } else if (!isRecording) {
      message =
          'Escolha Treino para receber dicas automáticas enquanto você fala.';
    } else if (!isTrainingMode) {
      message =
          'Modo gravar: alertas de volume e ritmo. Use Treino para análise de palavras e muletas.';
    } else if (!speechAvailable) {
      message =
          'Transcrição indisponível — volume e pausas continuam sendo analisados.';
    } else {
      message =
          'Continue falando — as dicas aparecerão em cerca de 10 segundos.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

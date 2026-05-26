import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal.dart';

/// Data e hora do ensaio (dia/mês/ano + hora:minuto em 24h).
String formatVoiceRehearsalDateTime(DateTime dateTime) =>
    DateFormat('dd/MM/yyyy · HH:mm', 'pt_BR').format(dateTime);

/// Comparativo da nota ao vivo com o recorde (durante o ensaio).
({String? label, Color? color}) liveScoreVsBestLabel({
  required double liveScore,
  required double? bestScore,
}) {
  if (bestScore == null) return (label: null, color: null);
  final delta = liveScore - bestScore;
  if (delta >= 0.05) {
    return (label: '↑ recorde', color: AppTheme.successColor);
  }
  if (delta <= -0.05) {
    return (
      label: '${delta.toStringAsFixed(1)} p/ rec',
      color: AppTheme.warningColor,
    );
  }
  return (label: '= recorde', color: AppTheme.textSecondary);
}

Color voiceRehearsalScoreColor(double score) {
  if (score < 5) return AppTheme.errorColor;
  if (score < 7) return AppTheme.warningColor;
  return AppTheme.successColor;
}

/// 0=ruim, 1=atenção, 2=bom, 3=ótimo — alinhado ao motor de análise.
Color characteristicScoreColor(int score) {
  switch (score) {
    case 3:
      return Colors.blue;
    case 2:
      return AppTheme.successColor;
    case 1:
      return AppTheme.warningColor;
    case 0:
      return AppTheme.errorColor;
    default:
      return AppTheme.textSecondary;
  }
}

String characteristicScoreShortLabel(int score) {
  switch (score) {
    case 3:
      return 'Ótimo';
    case 2:
      return 'Bom';
    case 1:
      return 'Atenção';
    case 0:
      return 'Ruim';
    default:
      return '';
  }
}

int scoreFromCharacteristicEvents(List<VoiceFeedbackEvent> charEvents) {
  if (charEvents.isEmpty) return 2;
  final warnings = charEvents
      .where((e) => e.severity == VoiceFeedbackSeverity.warning)
      .length;
  final positives = charEvents
      .where((e) => e.severity == VoiceFeedbackSeverity.positive)
      .length;
  if (warnings == 0 && positives > 0) return 3;
  if (warnings <= 1) return 2;
  if (warnings <= 2) return 1;
  return 0;
}

class CharacteristicStripItem {
  final int id;
  final String title;
  final int score;

  const CharacteristicStripItem({
    required this.id,
    required this.title,
    required this.score,
  });
}

List<CharacteristicStripItem> buildCharacteristicStripItems({
  required List<VoiceFeedbackEvent> events,
  VoiceRehearsalSummary? summary,
  required String? Function(int id) resolveTitle,
}) {
  if (summary != null) {
    final triggered = summary.characteristicScores.entries
        .where((e) {
          final hasEvents =
              summary.events.any((ev) => ev.characteristicId == e.key);
          final isStructure = kStructureCharacteristicIds.contains(e.key);
          return hasEvents || e.value != 2 || isStructure;
        })
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return triggered.map((entry) {
      final title = resolveTitle(entry.key) ?? 'Char ${entry.key}';
      return CharacteristicStripItem(
        id: entry.key,
        title: title,
        score: entry.value,
      );
    }).toList();
  }

  final grouped = <int, List<VoiceFeedbackEvent>>{};
  for (final event in events) {
    grouped.putIfAbsent(event.characteristicId, () => []).add(event);
  }
  if (grouped.isEmpty) return const [];

  final items = grouped.entries.map((entry) {
    final title = resolveTitle(entry.key) ?? 'Char ${entry.key}';
    return CharacteristicStripItem(
      id: entry.key,
      title: title,
      score: scoreFromCharacteristicEvents(entry.value),
    );
  }).toList()
    ..sort((a, b) => a.score.compareTo(b.score));

  return items;
}

/// Nota mínima para sugerir Modo Palco após ensaio com discurso vinculado.
const kStageModeSuggestMinScore = 7.0;

/// IDs das características be-T mais fracas no resumo (para autoavaliação).
List<int> weakestCharacteristicIds(
  VoiceRehearsalSummary summary, {
  int count = 2,
}) {
  final items = buildCharacteristicStripItems(
    events: summary.events,
    summary: summary,
    resolveTitle: (_) => '',
  );
  if (items.isNotEmpty) {
    return items.take(count).map((i) => i.id).toList();
  }

  final fromInsights = <int>[];
  for (final insight in summary.insights) {
    final id = insight.characteristicId;
    if (id != null && !fromInsights.contains(id)) {
      fromInsights.add(id);
    }
    if (fromInsights.length >= count) break;
  }
  return fromInsights;
}

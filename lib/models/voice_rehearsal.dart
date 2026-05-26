import 'package:flutter/foundation.dart';

enum VoiceFeedbackSeverity { info, warning, positive }

enum VoiceSessionMode { training, recording }

@immutable
class VoiceFeedbackEvent {
  final int characteristicId;
  final String message;
  final VoiceFeedbackSeverity severity;
  final DateTime timestamp;

  const VoiceFeedbackEvent({
    required this.characteristicId,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'characteristicId': characteristicId,
        'message': message,
        'severity': severity.index,
        'timestamp': timestamp.toIso8601String(),
      };

  factory VoiceFeedbackEvent.fromJson(Map<String, dynamic> json) {
    return VoiceFeedbackEvent(
      characteristicId: json['characteristicId'] as int? ?? 0,
      message: json['message']?.toString() ?? '',
      severity: VoiceFeedbackSeverity
          .values[(json['severity'] as int? ?? 0).clamp(0, 2)],
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

@immutable
class WordStat {
  final String word;
  final int count;

  const WordStat({required this.word, required this.count});

  double ratio(int totalWords) =>
      totalWords > 0 ? count / totalWords : 0;
}

@immutable
class VoiceImprovementInsight {
  final String category;
  final String message;
  final String suggestion;
  final int? characteristicId;
  final int severityRank;
  final String? observed;
  final String? avoid;
  final String? tryInstead;
  final String? beforeExample;
  final String? afterExample;

  const VoiceImprovementInsight({
    required this.category,
    required this.message,
    required this.suggestion,
    this.characteristicId,
    this.severityRank = 1,
    this.observed,
    this.avoid,
    this.tryInstead,
    this.beforeExample,
    this.afterExample,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'message': message,
        'suggestion': suggestion,
        'characteristicId': characteristicId,
        'severityRank': severityRank,
        if (observed != null) 'observed': observed,
        if (avoid != null) 'avoid': avoid,
        if (tryInstead != null) 'tryInstead': tryInstead,
        if (beforeExample != null) 'beforeExample': beforeExample,
        if (afterExample != null) 'afterExample': afterExample,
      };

  factory VoiceImprovementInsight.fromJson(Map<String, dynamic> json) {
    return VoiceImprovementInsight(
      category: json['category']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      suggestion: json['suggestion']?.toString() ?? '',
      characteristicId: json['characteristicId'] as int?,
      severityRank: json['severityRank'] as int? ?? 1,
      observed: json['observed']?.toString(),
      avoid: json['avoid']?.toString(),
      tryInstead: json['tryInstead']?.toString(),
      beforeExample: json['beforeExample']?.toString(),
      afterExample: json['afterExample']?.toString(),
    );
  }
}

@immutable
class ScoreBreakdownItem {
  final String label;
  final double points;

  const ScoreBreakdownItem({required this.label, required this.points});
}

@immutable
class VoiceRehearsalMetrics {
  final int elapsedSeconds;
  final int wordCount;
  final double wpm;
  final int fillerCount;
  final int longPauseCount;
  final double avgAmplitudeDb;
  final double amplitudeVariance;
  final int vagueWordCount;
  final double liveScore;

  const VoiceRehearsalMetrics({
    this.elapsedSeconds = 0,
    this.wordCount = 0,
    this.wpm = 0,
    this.fillerCount = 0,
    this.longPauseCount = 0,
    this.avgAmplitudeDb = 0,
    this.amplitudeVariance = 0,
    this.vagueWordCount = 0,
    this.liveScore = 0,
  });

  VoiceRehearsalMetrics copyWith({
    int? elapsedSeconds,
    int? wordCount,
    double? wpm,
    int? fillerCount,
    int? longPauseCount,
    double? avgAmplitudeDb,
    double? amplitudeVariance,
    int? vagueWordCount,
    double? liveScore,
  }) {
    return VoiceRehearsalMetrics(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      wordCount: wordCount ?? this.wordCount,
      wpm: wpm ?? this.wpm,
      fillerCount: fillerCount ?? this.fillerCount,
      longPauseCount: longPauseCount ?? this.longPauseCount,
      avgAmplitudeDb: avgAmplitudeDb ?? this.avgAmplitudeDb,
      amplitudeVariance: amplitudeVariance ?? this.amplitudeVariance,
      vagueWordCount: vagueWordCount ?? this.vagueWordCount,
      liveScore: liveScore ?? this.liveScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'elapsedSeconds': elapsedSeconds,
        'wordCount': wordCount,
        'wpm': wpm,
        'fillerCount': fillerCount,
        'longPauseCount': longPauseCount,
        'avgAmplitudeDb': avgAmplitudeDb,
        'amplitudeVariance': amplitudeVariance,
        'vagueWordCount': vagueWordCount,
        'liveScore': liveScore,
      };

  factory VoiceRehearsalMetrics.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalMetrics(
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      wordCount: json['wordCount'] as int? ?? 0,
      wpm: (json['wpm'] as num?)?.toDouble() ?? 0,
      fillerCount: json['fillerCount'] as int? ?? 0,
      longPauseCount: json['longPauseCount'] as int? ?? 0,
      avgAmplitudeDb: (json['avgAmplitudeDb'] as num?)?.toDouble() ?? 0,
      amplitudeVariance: (json['amplitudeVariance'] as num?)?.toDouble() ?? 0,
      vagueWordCount: json['vagueWordCount'] as int? ?? 0,
      liveScore: (json['liveScore'] as num?)?.toDouble() ?? 0,
    );
  }
}

@immutable
class VoiceRehearsalSummary {
  final VoiceRehearsalMetrics metrics;
  final List<VoiceFeedbackEvent> events;
  final Map<int, int> characteristicScores;
  final List<WordStat> topRepeatedWords;
  final List<VoiceImprovementInsight> insights;
  final List<ScoreBreakdownItem> scoreBreakdown;
  final String fullTranscript;
  final String formattedTranscript;
  final Map<String, dynamic>? speechStructureJson;

  const VoiceRehearsalSummary({
    required this.metrics,
    required this.events,
    required this.characteristicScores,
    this.topRepeatedWords = const [],
    this.insights = const [],
    this.scoreBreakdown = const [],
    this.fullTranscript = '',
    this.formattedTranscript = '',
    this.speechStructureJson,
  });

  Map<String, dynamic> toJson() => {
        'metrics': metrics.toJson(),
        'events': events.map((e) => e.toJson()).toList(),
        'characteristicScores':
            characteristicScores.map((k, v) => MapEntry(k.toString(), v)),
        'topRepeatedWords':
            topRepeatedWords.map((w) => {'word': w.word, 'count': w.count}).toList(),
        'insights': insights.map((i) => i.toJson()).toList(),
        'scoreBreakdown':
            scoreBreakdown.map((s) => {'label': s.label, 'points': s.points}).toList(),
        'fullTranscript': fullTranscript,
        if (formattedTranscript.isNotEmpty)
          'formattedTranscript': formattedTranscript,
        if (speechStructureJson != null)
          'speechStructure': speechStructureJson,
      };

  factory VoiceRehearsalSummary.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalSummary(
      metrics: VoiceRehearsalMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>? ?? {},
      ),
      events: (json['events'] as List?)
              ?.map((e) => VoiceFeedbackEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      characteristicScores: (json['characteristicScores'] as Map?)?.map(
            (k, v) => MapEntry(int.parse(k.toString()), v as int),
          ) ??
          {},
      topRepeatedWords: (json['topRepeatedWords'] as List?)
              ?.map((w) => WordStat(
                    word: w['word']?.toString() ?? '',
                    count: w['count'] as int? ?? 0,
                  ))
              .toList() ??
          const [],
      insights: (json['insights'] as List?)
              ?.map((i) => VoiceImprovementInsight.fromJson(
                    i as Map<String, dynamic>,
                  ))
              .toList() ??
          const [],
      scoreBreakdown: (json['scoreBreakdown'] as List?)
              ?.map((s) => ScoreBreakdownItem(
                    label: s['label']?.toString() ?? '',
                    points: (s['points'] as num?)?.toDouble() ?? 0,
                  ))
              .toList() ??
          const [],
      fullTranscript: json['fullTranscript']?.toString() ?? '',
      formattedTranscript: json['formattedTranscript']?.toString() ?? '',
      speechStructureJson: json['speechStructure'] is Map
          ? Map<String, dynamic>.from(json['speechStructure'] as Map)
          : null,
    );
  }
}

/// IDs be-T monitorados na Fase A (análise local de voz).
const kMonitoredVoiceCharacteristicIds = [2, 4, 5, 8, 9, 24, 28, 29];

/// IDs be-T de estrutura (intro, conclusão, tempo).
const kStructureCharacteristicIds = [38, 39, 51];

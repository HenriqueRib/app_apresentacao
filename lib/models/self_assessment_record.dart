import 'package:flutter/foundation.dart';

enum AssessmentLevel { notYet, partial, yes }

@immutable
class CharacteristicScore {
  final int characteristicId;
  final AssessmentLevel level;

  const CharacteristicScore({
    required this.characteristicId,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
        'characteristicId': characteristicId,
        'level': level.index,
      };

  factory CharacteristicScore.fromJson(Map<String, dynamic> json) {
    final levelIndex = json['level'] is int
        ? json['level'] as int
        : int.tryParse(json['level']?.toString() ?? '0') ?? 0;
    return CharacteristicScore(
      characteristicId: json['characteristicId'] is int
          ? json['characteristicId'] as int
          : int.tryParse(json['characteristicId']?.toString() ?? '0') ?? 0,
      level: AssessmentLevel.values[levelIndex.clamp(0, 2)],
    );
  }
}

@immutable
class SelfAssessmentRecord {
  final String id;
  final DateTime completedAt;
  final String? speechTitle;
  final List<CharacteristicScore> scores;

  const SelfAssessmentRecord({
    required this.id,
    required this.completedAt,
    this.speechTitle,
    this.scores = const [],
  });

  int countLevel(AssessmentLevel level) =>
      scores.where((s) => s.level == level).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toIso8601String(),
        'speechTitle': speechTitle,
        'scores': scores.map((s) => s.toJson()).toList(),
      };

  factory SelfAssessmentRecord.fromJson(Map<String, dynamic> json) {
    return SelfAssessmentRecord(
      id: (json['id'] ?? '').toString(),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
      speechTitle: json['speechTitle']?.toString(),
      scores: (json['scores'] as List?)
              ?.map((e) =>
                  CharacteristicScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

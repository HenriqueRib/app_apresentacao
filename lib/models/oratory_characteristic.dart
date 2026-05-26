import 'package:flutter/foundation.dart';

@immutable
class EvaluationRubricItem {
  final String id;
  final String label;
  final bool auto;

  const EvaluationRubricItem({
    required this.id,
    required this.label,
    this.auto = false,
  });

  factory EvaluationRubricItem.fromJson(Map<String, dynamic> json) {
    return EvaluationRubricItem(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      auto: json['auto'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'auto': auto,
      };
}

@immutable
class TimeGuidance {
  final int? introPctMin;
  final int? introPctMax;
  final int? conclusionPctMin;
  final int? conclusionPctMax;
  final int? bodyPctMin;

  const TimeGuidance({
    this.introPctMin,
    this.introPctMax,
    this.conclusionPctMin,
    this.conclusionPctMax,
    this.bodyPctMin,
  });

  factory TimeGuidance.fromJson(Map<String, dynamic> json) {
    return TimeGuidance(
      introPctMin: json['intro_pct_min'] as int?,
      introPctMax: json['intro_pct_max'] as int?,
      conclusionPctMin: json['conclusion_pct_min'] as int?,
      conclusionPctMax: json['conclusion_pct_max'] as int?,
      bodyPctMin: json['body_pct_min'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (introPctMin != null) 'intro_pct_min': introPctMin,
        if (introPctMax != null) 'intro_pct_max': introPctMax,
        if (conclusionPctMin != null) 'conclusion_pct_min': conclusionPctMin,
        if (conclusionPctMax != null) 'conclusion_pct_max': conclusionPctMax,
        if (bodyPctMin != null) 'body_pct_min': bodyPctMin,
      };
}

@immutable
class OratoryCharacteristic {
  final int id;
  final String title;
  final int pageReference;
  final String category;
  final String action;
  final String importance;
  final List<EvaluationRubricItem> evaluationRubric;
  final TimeGuidance? timeGuidance;

  const OratoryCharacteristic({
    required this.id,
    required this.title,
    required this.pageReference,
    required this.category,
    required this.action,
    required this.importance,
    this.evaluationRubric = const [],
    this.timeGuidance,
  });

  factory OratoryCharacteristic.fromJson(Map<String, dynamic> json) {
    return OratoryCharacteristic(
      id: json['id'],
      title: json['title'],
      pageReference: json['page_reference'],
      category: json['category'],
      action: json['action'],
      importance: json['importance'],
      evaluationRubric: (json['evaluation_rubric'] as List?)
              ?.map((e) =>
                  EvaluationRubricItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      timeGuidance: json['time_guidance'] is Map
          ? TimeGuidance.fromJson(
              Map<String, dynamic>.from(json['time_guidance'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'page_reference': pageReference,
      'category': category,
      'action': action,
      'importance': importance,
      if (evaluationRubric.isNotEmpty)
        'evaluation_rubric':
            evaluationRubric.map((e) => e.toJson()).toList(),
      if (timeGuidance != null) 'time_guidance': timeGuidance!.toJson(),
    };
  }
}

@immutable
class CharacteristicCategory {
  final String id;
  final String name;
  final List<int> characteristicsIds;

  const CharacteristicCategory({
    required this.id,
    required this.name,
    required this.characteristicsIds,
  });

  factory CharacteristicCategory.fromJson(Map<String, dynamic> json) {
    return CharacteristicCategory(
      id: json['id'],
      name: json['name'],
      characteristicsIds: List<int>.from(json['characteristics_ids']),
    );
  }
}

@immutable
class CompetencyFeedback {
  final String id;
  final String name;
  final double weight;
  final String description;

  const CompetencyFeedback({
    required this.id,
    required this.name,
    required this.weight,
    required this.description,
  });

  factory CompetencyFeedback.fromJson(Map<String, dynamic> json) {
    return CompetencyFeedback(
      id: json['id'],
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      description: json['description'],
    );
  }
}

@immutable
class ShinyashikiPillar {
  final String id;
  final String name;
  final String description;
  final String kpiReference;

  const ShinyashikiPillar({
    required this.id,
    required this.name,
    required this.description,
    required this.kpiReference,
  });

  factory ShinyashikiPillar.fromJson(Map<String, dynamic> json) {
    return ShinyashikiPillar(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      kpiReference: json['kpi_reference'],
    );
  }
}

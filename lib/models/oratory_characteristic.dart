import 'package:flutter/foundation.dart';

@immutable
class OratoryCharacteristic {
  final int id;
  final String title;
  final int pageReference;
  final String category;
  final String action;
  final String importance;

  const OratoryCharacteristic({
    required this.id,
    required this.title,
    required this.pageReference,
    required this.category,
    required this.action,
    required this.importance,
  });

  factory OratoryCharacteristic.fromJson(Map<String, dynamic> json) {
    return OratoryCharacteristic(
      id: json['id'],
      title: json['title'],
      pageReference: json['page_reference'],
      category: json['category'],
      action: json['action'],
      importance: json['importance'],
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

import 'package:flutter/foundation.dart';

@immutable
class StudyTopic {
  final String id;
  final String shortIdea;
  final String bibleReference;
  final String optionalNote;

  const StudyTopic({
    required this.id,
    required this.shortIdea,
    this.bibleReference = '',
    this.optionalNote = '',
  });

  StudyTopic copyWith({
    String? id,
    String? shortIdea,
    String? bibleReference,
    String? optionalNote,
  }) {
    return StudyTopic(
      id: id ?? this.id,
      shortIdea: shortIdea ?? this.shortIdea,
      bibleReference: bibleReference ?? this.bibleReference,
      optionalNote: optionalNote ?? this.optionalNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shortIdea': shortIdea,
        'bibleReference': bibleReference,
        'optionalNote': optionalNote,
      };

  factory StudyTopic.fromJson(Map<String, dynamic> json) {
    return StudyTopic(
      id: (json['id'] ?? '').toString(),
      shortIdea: (json['shortIdea'] ?? '').toString(),
      bibleReference: (json['bibleReference'] ?? '').toString(),
      optionalNote: (json['optionalNote'] ?? '').toString(),
    );
  }
}

@immutable
class StudyOutline {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StudyTopic> topics;

  const StudyOutline({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.topics = const [],
  });

  StudyOutline copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<StudyTopic>? topics,
  }) {
    return StudyOutline(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'topics': topics.map((t) => t.toJson()).toList(),
      };

  factory StudyOutline.fromJson(Map<String, dynamic> json) {
    return StudyOutline(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      topics: (json['topics'] as List?)
              ?.map((e) => StudyTopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

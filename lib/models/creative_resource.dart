import 'package:flutter/foundation.dart';

enum ResourceType {
  strongTitle,
  illustrativeCase,
  connectionRepertoire,
  multimediaAsset,
}

@immutable
class CreativeResource {
  final String id;
  final ResourceType type;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mediaPath;
  final bool isOriginal;

  const CreativeResource({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.mediaPath,
    this.isOriginal = true,
  });

  CreativeResource copyWith({
    String? id,
    ResourceType? type,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mediaPath,
    bool? isOriginal,
  }) {
    return CreativeResource(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      mediaPath: mediaPath ?? this.mediaPath,
      isOriginal: isOriginal ?? this.isOriginal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'mediaPath': mediaPath,
      'isOriginal': isOriginal,
    };
  }

  factory CreativeResource.fromJson(Map<String, dynamic> json) {
    return CreativeResource(
      id: json['id'],
      type: ResourceType.values[json['type']],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      mediaPath: json['mediaPath'],
      isOriginal: json['isOriginal'] ?? true,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case ResourceType.strongTitle:
        return 'Título Forte';
      case ResourceType.illustrativeCase:
        return 'Caso Ilustrativo';
      case ResourceType.connectionRepertoire:
        return 'Repertório de Conexão';
      case ResourceType.multimediaAsset:
        return 'Asset Multimídia';
    }
  }
}

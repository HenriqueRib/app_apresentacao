import 'package:flutter/foundation.dart';

import 'voice_rehearsal.dart';

@immutable
class VoiceRecording {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final int durationSeconds;
  final double finalScore;
  final String? title;
  final VoiceRehearsalSummary? summary;

  const VoiceRecording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.durationSeconds,
    required this.finalScore,
    this.title,
    this.summary,
  });

  String get displayTitle =>
      title ?? 'Ensaio ${createdAt.day}/${createdAt.month}/${createdAt.year}';

  VoiceRecording copyWith({
    String? id,
    String? filePath,
    DateTime? createdAt,
    int? durationSeconds,
    double? finalScore,
    String? title,
    VoiceRehearsalSummary? summary,
  }) {
    return VoiceRecording(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      finalScore: finalScore ?? this.finalScore,
      title: title ?? this.title,
      summary: summary ?? this.summary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'finalScore': finalScore,
        'title': title,
        'summary': summary?.toJson(),
      };

  factory VoiceRecording.fromJson(Map<String, dynamic> json) {
    return VoiceRecording(
      id: json['id']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      finalScore: (json['finalScore'] as num?)?.toDouble() ?? 0,
      title: json['title']?.toString(),
      summary: json['summary'] != null
          ? VoiceRehearsalSummary.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

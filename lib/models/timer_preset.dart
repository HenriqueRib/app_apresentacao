import 'package:flutter/foundation.dart';

@immutable
class TimerSegment {
  final String name;
  final int durationSeconds;

  const TimerSegment({
    required this.name,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationSeconds': durationSeconds,
      };

  factory TimerSegment.fromJson(Map<String, dynamic> json) {
    return TimerSegment(
      name: (json['name'] ?? '').toString(),
      durationSeconds: json['durationSeconds'] is int
          ? json['durationSeconds'] as int
          : int.tryParse(json['durationSeconds']?.toString() ?? '60') ?? 60,
    );
  }
}

@immutable
class TimerPreset {
  final String id;
  final String name;
  final int? totalTargetSeconds;
  final List<TimerSegment> segments;

  const TimerPreset({
    required this.id,
    required this.name,
    this.totalTargetSeconds,
    this.segments = const [],
  });

  bool get hasSplit => segments.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalTargetSeconds': totalTargetSeconds,
        'segments': segments.map((s) => s.toJson()).toList(),
      };

  factory TimerPreset.fromJson(Map<String, dynamic> json) {
    return TimerPreset(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      totalTargetSeconds: json['totalTargetSeconds'] as int?,
      segments: (json['segments'] as List?)
              ?.map((e) => TimerSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static TimerPreset defaultPart10Min() {
    return const TimerPreset(
      id: 'preset_10min_split',
      name: 'Parte 10 min (1+7+2)',
      totalTargetSeconds: 600,
      segments: [
        TimerSegment(name: 'Introdução', durationSeconds: 60),
        TimerSegment(name: 'Corpo', durationSeconds: 420),
        TimerSegment(name: 'Conclusão', durationSeconds: 120),
      ],
    );
  }
}

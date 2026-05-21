import 'package:flutter/foundation.dart';

@immutable
class MasterclassStep {
  final int stepNumber;
  final String title;
  final String iconName;
  final String summary;
  final List<String> tips;
  final bool hasVoiceTrainer;

  const MasterclassStep({
    required this.stepNumber,
    required this.title,
    required this.iconName,
    required this.summary,
    this.tips = const [],
    this.hasVoiceTrainer = false,
  });

  factory MasterclassStep.fromJson(Map<String, dynamic> json) {
    return MasterclassStep(
      stepNumber: json['step_number'] is int
          ? json['step_number'] as int
          : int.tryParse(json['step_number']?.toString() ?? '1') ?? 1,
      title: (json['title'] ?? '').toString(),
      iconName: (json['icon'] ?? 'school').toString(),
      summary: (json['summary'] ?? '').toString(),
      tips: (json['tips'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      hasVoiceTrainer: json['has_voice_trainer'] == true,
    );
  }
}

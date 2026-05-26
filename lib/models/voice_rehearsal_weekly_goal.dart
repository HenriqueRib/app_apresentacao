class VoiceRehearsalWeeklyGoal {
  final bool enabled;
  final int targetCount;

  const VoiceRehearsalWeeklyGoal({
    this.enabled = false,
    this.targetCount = 3,
  });

  static const VoiceRehearsalWeeklyGoal defaults = VoiceRehearsalWeeklyGoal();

  VoiceRehearsalWeeklyGoal copyWith({
    bool? enabled,
    int? targetCount,
  }) {
    return VoiceRehearsalWeeklyGoal(
      enabled: enabled ?? this.enabled,
      targetCount: targetCount ?? this.targetCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'targetCount': targetCount,
      };

  factory VoiceRehearsalWeeklyGoal.fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaults;
    return VoiceRehearsalWeeklyGoal(
      enabled: json['enabled'] as bool? ?? false,
      targetCount: (json['targetCount'] as int? ?? 3).clamp(1, 14),
    );
  }
}

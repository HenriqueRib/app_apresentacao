import 'package:flutter/foundation.dart';

@immutable
class VoiceRehearsalStreak {
  final int consecutiveDays;
  final DateTime? lastRehearsalDay;

  const VoiceRehearsalStreak({
    this.consecutiveDays = 0,
    this.lastRehearsalDay,
  });

  bool get isActive => consecutiveDays >= 2;

  Map<String, dynamic> toJson() => {
        'consecutiveDays': consecutiveDays,
        if (lastRehearsalDay != null)
          'lastRehearsalDay': lastRehearsalDay!.toIso8601String(),
      };

  factory VoiceRehearsalStreak.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VoiceRehearsalStreak();
    return VoiceRehearsalStreak(
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      lastRehearsalDay: DateTime.tryParse(
        json['lastRehearsalDay']?.toString() ?? '',
      ),
    );
  }

  /// Registra ensaio ≥ 2 min no dia [day] (só data local).
  VoiceRehearsalStreak recordSession(DateTime day, {required int minSeconds}) {
    if (minSeconds < 120) return this;

    final today = DateTime(day.year, day.month, day.day);
    final last = lastRehearsalDay == null
        ? null
        : DateTime(
            lastRehearsalDay!.year,
            lastRehearsalDay!.month,
            lastRehearsalDay!.day,
          );

    if (last != null && _sameDay(last, today)) {
      return this;
    }

    if (last != null && today.difference(last).inDays == 1) {
      return VoiceRehearsalStreak(
        consecutiveDays: consecutiveDays + 1,
        lastRehearsalDay: today,
      );
    }

    return VoiceRehearsalStreak(
      consecutiveDays: 1,
      lastRehearsalDay: today,
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

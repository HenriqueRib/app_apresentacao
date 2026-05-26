import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/voice_rehearsal.dart';

String _encodeCheckpointJson(Map<String, dynamic> json) => jsonEncode(json);

class VoiceSessionCheckpoint {
  static const _key = 'voice_rehearsal_checkpoint';
  static const maxAge = Duration(hours: 2);
  static const saveInterval = Duration(seconds: 30);
  static const maxCheckpointEvents = 15;

  final int elapsedSeconds;
  final String transcript;
  final double liveScore;
  final VoiceSessionMode mode;
  final List<VoiceFeedbackEvent> events;
  final DateTime savedAt;

  const VoiceSessionCheckpoint({
    required this.elapsedSeconds,
    required this.transcript,
    required this.liveScore,
    required this.mode,
    required this.events,
    required this.savedAt,
  });

  bool get isExpired => DateTime.now().difference(savedAt) > maxAge;

  Map<String, dynamic> toJson() => {
        'elapsedSeconds': elapsedSeconds,
        'transcript': transcript,
        'liveScore': liveScore,
        'mode': mode.index,
        'events': events.map((e) => e.toJson()).toList(),
        'savedAt': savedAt.toIso8601String(),
      };

  factory VoiceSessionCheckpoint.fromJson(Map<String, dynamic> json) {
    return VoiceSessionCheckpoint(
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      transcript: json['transcript']?.toString() ?? '',
      liveScore: (json['liveScore'] as num?)?.toDouble() ?? 0,
      mode: VoiceSessionMode.values[
          (json['mode'] as int? ?? 0).clamp(0, VoiceSessionMode.values.length - 1)],
      events: (json['events'] as List?)
              ?.map((e) => VoiceFeedbackEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static Future<VoiceSessionCheckpoint?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final checkpoint =
          VoiceSessionCheckpoint.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (checkpoint.isExpired) {
        await clear();
        return null;
      }
      return checkpoint;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(VoiceSessionCheckpoint checkpoint) async {
    final encoded = await compute(_encodeCheckpointJson, checkpoint.toJson());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, encoded);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

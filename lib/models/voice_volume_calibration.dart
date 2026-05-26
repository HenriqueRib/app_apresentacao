import 'package:flutter/foundation.dart';

@immutable
class VoiceVolumeCalibration {
  final double referenceDb;
  final double offsetDb;
  final DateTime calibratedAt;

  const VoiceVolumeCalibration({
    required this.referenceDb,
    required this.offsetDb,
    required this.calibratedAt,
  });

  Map<String, dynamic> toJson() => {
        'referenceDb': referenceDb,
        'offsetDb': offsetDb,
        'calibratedAt': calibratedAt.toIso8601String(),
      };

  factory VoiceVolumeCalibration.fromJson(Map<String, dynamic> json) {
    return VoiceVolumeCalibration(
      referenceDb: (json['referenceDb'] as num?)?.toDouble() ?? 0,
      offsetDb: (json['offsetDb'] as num?)?.toDouble() ?? 0,
      calibratedAt: DateTime.tryParse(json['calibratedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

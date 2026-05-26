import 'package:flutter/foundation.dart';

import 'voice_rehearsal.dart';
import 'voice_rehearsal_online_analysis.dart';

@immutable
class VoiceRehearsalAttempt {
  final String id;
  final DateTime createdAt;
  final VoiceSessionMode mode;
  final int durationSeconds;
  final double finalScore;
  final String? topic;
  final String subjectPreview;
  final VoiceRehearsalSummary summary;
  final String? recordingFilePath;
  final VoiceRehearsalOnlineAnalysis? onlineAnalysis;
  final String? seriesName;
  final String? linkedSpeechId;
  final String? userNote;
  final String? speakerName;

  const VoiceRehearsalAttempt({
    required this.id,
    required this.createdAt,
    required this.mode,
    required this.durationSeconds,
    required this.finalScore,
    this.topic,
    required this.subjectPreview,
    required this.summary,
    this.recordingFilePath,
    this.onlineAnalysis,
    this.seriesName,
    this.linkedSpeechId,
    this.userNote,
    this.speakerName,
  });

  String get listTitle {
    final t = topic?.trim();
    if (t != null && t.isNotEmpty) return t;
    return subjectPreview;
  }

  String get modeLabel =>
      mode == VoiceSessionMode.training ? 'Treino' : 'Gravação';

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'mode': mode.index,
        'durationSeconds': durationSeconds,
        'finalScore': finalScore,
        'topic': topic,
        'subjectPreview': subjectPreview,
        'summary': summary.toJson(),
        'recordingFilePath': recordingFilePath,
        if (onlineAnalysis != null) 'onlineAnalysis': onlineAnalysis!.toJson(),
        if (seriesName != null) 'seriesName': seriesName,
        if (linkedSpeechId != null) 'linkedSpeechId': linkedSpeechId,
        if (userNote != null) 'userNote': userNote,
        if (speakerName != null) 'speakerName': speakerName,
      };

  VoiceRehearsalAttempt copyWith({
    VoiceRehearsalOnlineAnalysis? onlineAnalysis,
    String? seriesName,
    String? linkedSpeechId,
    String? userNote,
    bool clearUserNote = false,
    VoiceRehearsalSummary? summary,
    double? finalScore,
    String? subjectPreview,
    String? speakerName,
    bool clearSpeakerName = false,
  }) {
    return VoiceRehearsalAttempt(
      id: id,
      createdAt: createdAt,
      mode: mode,
      durationSeconds: durationSeconds,
      finalScore: finalScore ?? this.finalScore,
      topic: topic,
      subjectPreview: subjectPreview ?? this.subjectPreview,
      summary: summary ?? this.summary,
      recordingFilePath: recordingFilePath,
      onlineAnalysis: onlineAnalysis ?? this.onlineAnalysis,
      seriesName: seriesName ?? this.seriesName,
      linkedSpeechId: linkedSpeechId ?? this.linkedSpeechId,
      userNote: clearUserNote ? null : (userNote ?? this.userNote),
      speakerName:
          clearSpeakerName ? null : (speakerName ?? this.speakerName),
    );
  }

  factory VoiceRehearsalAttempt.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalAttempt(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      mode: VoiceSessionMode.values[
          (json['mode'] as int? ?? 0).clamp(0, VoiceSessionMode.values.length - 1)],
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      finalScore: (json['finalScore'] as num?)?.toDouble() ?? 0,
      topic: json['topic']?.toString(),
      subjectPreview: json['subjectPreview']?.toString() ?? '',
      summary: VoiceRehearsalSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
      recordingFilePath: json['recordingFilePath']?.toString(),
      onlineAnalysis: json['onlineAnalysis'] is Map
          ? VoiceRehearsalOnlineAnalysis.fromJson(
              Map<String, dynamic>.from(json['onlineAnalysis'] as Map),
            )
          : null,
      seriesName: json['seriesName']?.toString(),
      linkedSpeechId: json['linkedSpeechId']?.toString(),
      userNote: json['userNote']?.toString(),
      speakerName: json['speakerName']?.toString(),
    );
  }
}

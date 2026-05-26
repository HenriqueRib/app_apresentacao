class VoiceRehearsalNextFocus {
  final int characteristicId;
  final String label;
  final DateTime savedAt;

  const VoiceRehearsalNextFocus({
    required this.characteristicId,
    required this.label,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'characteristicId': characteristicId,
        'label': label,
        'savedAt': savedAt.toIso8601String(),
      };

  factory VoiceRehearsalNextFocus.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalNextFocus(
      characteristicId: json['characteristicId'] as int? ?? 0,
      label: json['label']?.toString() ?? '',
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

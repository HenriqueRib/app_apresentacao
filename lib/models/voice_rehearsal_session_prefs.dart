/// Metas e preferências da sessão ao vivo (Ensaio be-T).
class VoiceRehearsalSessionPrefs {
  /// Segundos alvo (null = sem meta). Valores comuns: 240, 360, 600.
  final int? durationGoalSeconds;

  /// Esconde feed e características; mantém nota, tempo e dica principal.
  final bool focusMode;

  const VoiceRehearsalSessionPrefs({
    this.durationGoalSeconds,
    this.focusMode = false,
  });

  static const VoiceRehearsalSessionPrefs defaults =
      VoiceRehearsalSessionPrefs();

  static const List<({int? seconds, String label})> durationGoalOptions = [
    (seconds: null, label: 'Livre'),
    (seconds: 240, label: '4 min'),
    (seconds: 360, label: '6 min'),
    (seconds: 600, label: '10 min'),
  ];

  VoiceRehearsalSessionPrefs copyWith({
    int? Function()? durationGoalSeconds,
    bool? focusMode,
  }) {
    return VoiceRehearsalSessionPrefs(
      durationGoalSeconds: durationGoalSeconds != null
          ? durationGoalSeconds()
          : this.durationGoalSeconds,
      focusMode: focusMode ?? this.focusMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'durationGoalSeconds': durationGoalSeconds,
        'focusMode': focusMode,
      };

  factory VoiceRehearsalSessionPrefs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaults;
    final goal = json['durationGoalSeconds'];
    return VoiceRehearsalSessionPrefs(
      durationGoalSeconds: goal == null ? null : goal as int,
      focusMode: json['focusMode'] as bool? ?? false,
    );
  }
}

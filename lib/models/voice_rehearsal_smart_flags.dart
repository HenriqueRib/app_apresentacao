/// Flags do Modo inteligente (Ensaio be-T) — todas opt-in por padrão.
enum CoachFocusMode {
  all,
  muletas,
  ritmo,
  volume,
  modulacao,
  estrutura,
}

extension CoachFocusModeLabel on CoachFocusMode {
  String get label => switch (this) {
        CoachFocusMode.all => 'Tudo',
        CoachFocusMode.muletas => 'Muletas',
        CoachFocusMode.ritmo => 'Ritmo',
        CoachFocusMode.volume => 'Volume',
        CoachFocusMode.modulacao => 'Modulação',
        CoachFocusMode.estrutura => 'Estrutura',
      };
}

class VoiceRehearsalSmartFlags {
  final bool warmupEnabled;
  final bool countdownEnabled;
  final bool hapticEnabled;
  final bool timeMilestonesEnabled;
  final bool smartPauseEnabled;
  final bool carryOverFocusEnabled;
  final bool coachFocusEnabled;
  final CoachFocusMode coachFocusMode;
  final bool minimalCoachEnabled;
  final bool listenBackEnabled;
  final bool weeklyGoalEnabled;
  final bool autoScrollTeleprompter;
  final bool silentCoachEnabled;
  final bool blockPracticeEnabled;

  const VoiceRehearsalSmartFlags({
    this.warmupEnabled = false,
    this.countdownEnabled = false,
    this.hapticEnabled = false,
    this.timeMilestonesEnabled = false,
    this.smartPauseEnabled = false,
    this.carryOverFocusEnabled = false,
    this.coachFocusEnabled = false,
    this.coachFocusMode = CoachFocusMode.all,
    this.minimalCoachEnabled = false,
    this.listenBackEnabled = false,
    this.weeklyGoalEnabled = false,
    this.autoScrollTeleprompter = false,
    this.silentCoachEnabled = false,
    this.blockPracticeEnabled = false,
  });

  static const VoiceRehearsalSmartFlags defaults = VoiceRehearsalSmartFlags();

  VoiceRehearsalSmartFlags copyWith({
    bool? warmupEnabled,
    bool? countdownEnabled,
    bool? hapticEnabled,
    bool? timeMilestonesEnabled,
    bool? smartPauseEnabled,
    bool? carryOverFocusEnabled,
    bool? coachFocusEnabled,
    CoachFocusMode? coachFocusMode,
    bool? minimalCoachEnabled,
    bool? listenBackEnabled,
    bool? weeklyGoalEnabled,
    bool? autoScrollTeleprompter,
    bool? silentCoachEnabled,
    bool? blockPracticeEnabled,
  }) {
    return VoiceRehearsalSmartFlags(
      warmupEnabled: warmupEnabled ?? this.warmupEnabled,
      countdownEnabled: countdownEnabled ?? this.countdownEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      timeMilestonesEnabled:
          timeMilestonesEnabled ?? this.timeMilestonesEnabled,
      smartPauseEnabled: smartPauseEnabled ?? this.smartPauseEnabled,
      carryOverFocusEnabled:
          carryOverFocusEnabled ?? this.carryOverFocusEnabled,
      coachFocusEnabled: coachFocusEnabled ?? this.coachFocusEnabled,
      coachFocusMode: coachFocusMode ?? this.coachFocusMode,
      minimalCoachEnabled: minimalCoachEnabled ?? this.minimalCoachEnabled,
      listenBackEnabled: listenBackEnabled ?? this.listenBackEnabled,
      weeklyGoalEnabled: weeklyGoalEnabled ?? this.weeklyGoalEnabled,
      autoScrollTeleprompter:
          autoScrollTeleprompter ?? this.autoScrollTeleprompter,
      silentCoachEnabled: silentCoachEnabled ?? this.silentCoachEnabled,
      blockPracticeEnabled: blockPracticeEnabled ?? this.blockPracticeEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'warmupEnabled': warmupEnabled,
        'countdownEnabled': countdownEnabled,
        'hapticEnabled': hapticEnabled,
        'timeMilestonesEnabled': timeMilestonesEnabled,
        'smartPauseEnabled': smartPauseEnabled,
        'carryOverFocusEnabled': carryOverFocusEnabled,
        'coachFocusEnabled': coachFocusEnabled,
        'coachFocusMode': coachFocusMode.index,
        'minimalCoachEnabled': minimalCoachEnabled,
        'listenBackEnabled': listenBackEnabled,
        'weeklyGoalEnabled': weeklyGoalEnabled,
        'autoScrollTeleprompter': autoScrollTeleprompter,
        'silentCoachEnabled': silentCoachEnabled,
        'blockPracticeEnabled': blockPracticeEnabled,
      };

  /// Poucos recursos: countdown, marcos e carry-over.
  static const VoiceRehearsalSmartFlags presetBeginner = VoiceRehearsalSmartFlags(
    countdownEnabled: true,
    timeMilestonesEnabled: true,
    carryOverFocusEnabled: true,
  );

  /// Conjunto amplo para quem quer o coach completo.
  static const VoiceRehearsalSmartFlags presetComplete = VoiceRehearsalSmartFlags(
    countdownEnabled: true,
    warmupEnabled: true,
    hapticEnabled: true,
    timeMilestonesEnabled: true,
    smartPauseEnabled: true,
    carryOverFocusEnabled: true,
    coachFocusEnabled: true,
    coachFocusMode: CoachFocusMode.all,
    listenBackEnabled: true,
    weeklyGoalEnabled: true,
  );

  factory VoiceRehearsalSmartFlags.fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaults;
    final modeIndex = json['coachFocusMode'] as int? ?? 0;
    return VoiceRehearsalSmartFlags(
      warmupEnabled: json['warmupEnabled'] as bool? ?? false,
      countdownEnabled: json['countdownEnabled'] as bool? ?? false,
      hapticEnabled: json['hapticEnabled'] as bool? ?? false,
      timeMilestonesEnabled: json['timeMilestonesEnabled'] as bool? ?? false,
      smartPauseEnabled: json['smartPauseEnabled'] as bool? ?? false,
      carryOverFocusEnabled: json['carryOverFocusEnabled'] as bool? ?? false,
      coachFocusEnabled: json['coachFocusEnabled'] as bool? ?? false,
      coachFocusMode: CoachFocusMode
          .values[modeIndex.clamp(0, CoachFocusMode.values.length - 1)],
      minimalCoachEnabled: json['minimalCoachEnabled'] as bool? ?? false,
      listenBackEnabled: json['listenBackEnabled'] as bool? ?? false,
      weeklyGoalEnabled: json['weeklyGoalEnabled'] as bool? ?? false,
      autoScrollTeleprompter:
          json['autoScrollTeleprompter'] as bool? ?? false,
      silentCoachEnabled: json['silentCoachEnabled'] as bool? ?? false,
      blockPracticeEnabled: json['blockPracticeEnabled'] as bool? ?? false,
    );
  }
}

enum VoiceRehearsalReportViewMode {
  minimal,
  visual;

  String get label => switch (this) {
        VoiceRehearsalReportViewMode.minimal => 'Minimalista',
        VoiceRehearsalReportViewMode.visual => 'Dinâmico e visual',
      };

  String get storageKey => name;

  static VoiceRehearsalReportViewMode fromStorage(String? value) {
    return VoiceRehearsalReportViewMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => VoiceRehearsalReportViewMode.minimal,
    );
  }
}

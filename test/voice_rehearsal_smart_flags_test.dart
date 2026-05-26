import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal_smart_flags.dart';

void main() {
  test('roundtrip json', () {
    const flags = VoiceRehearsalSmartFlags(
      warmupEnabled: true,
      countdownEnabled: true,
      coachFocusEnabled: true,
      coachFocusMode: CoachFocusMode.muletas,
    );
    final restored =
        VoiceRehearsalSmartFlags.fromJson(flags.toJson());
    expect(restored.warmupEnabled, true);
    expect(restored.countdownEnabled, true);
    expect(restored.coachFocusMode, CoachFocusMode.muletas);
  });

  test('defaults are opt-in', () {
    expect(VoiceRehearsalSmartFlags.defaults.warmupEnabled, false);
    expect(VoiceRehearsalSmartFlags.defaults.weeklyGoalEnabled, false);
  });

  test('preset beginner enables countdown and carry-over only', () {
    const p = VoiceRehearsalSmartFlags.presetBeginner;
    expect(p.countdownEnabled, true);
    expect(p.carryOverFocusEnabled, true);
    expect(p.warmupEnabled, false);
    expect(p.listenBackEnabled, false);
  });

  test('preset complete enables broad coach set', () {
    const p = VoiceRehearsalSmartFlags.presetComplete;
    expect(p.warmupEnabled, true);
    expect(p.coachFocusEnabled, true);
    expect(p.weeklyGoalEnabled, true);
    expect(p.minimalCoachEnabled, false);
  });
}

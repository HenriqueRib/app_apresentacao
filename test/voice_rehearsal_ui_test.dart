import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/utils/voice_rehearsal_ui.dart';

void main() {
  test('weakestCharacteristicIds returns lowest scores first', () {
    final summary = VoiceRehearsalSummary(
      metrics: const VoiceRehearsalMetrics(elapsedSeconds: 60),
      events: const [],
      characteristicScores: {2: 0, 4: 2, 8: 1},
    );

    final ids = weakestCharacteristicIds(summary, count: 2);
    expect(ids.length, 2);
    expect(ids.first, 2);
    expect(ids.contains(8), true);
  });
}

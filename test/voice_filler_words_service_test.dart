import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/services/voice_filler_words_service.dart';

void main() {
  test('effectiveFillers une padrão e custom', () {
    final set = VoiceFillerWordsService.effectiveFillers({'basicamente'});
    expect(set.contains('então'), isTrue);
    expect(set.contains('basicamente'), isTrue);
  });

  test('addCustom ignora duplicatas e padrão', () {
    final list = VoiceFillerWordsService.addCustom([], 'tipo');
    expect(list, isEmpty);
    final added = VoiceFillerWordsService.addCustom([], 'olha');
    expect(added, ['olha']);
    final dup = VoiceFillerWordsService.addCustom(added, 'olha');
    expect(dup.length, 1);
  });

  test('removeCustom remove palavra', () {
    final list = VoiceFillerWordsService.removeCustom(['olha', 'assim'], 'olha');
    expect(list, ['assim']);
  });
}

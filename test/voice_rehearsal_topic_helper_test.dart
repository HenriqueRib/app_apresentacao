import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/services/voice_rehearsal_topic_helper.dart';

void main() {
  test('lista usa tema do usuário quando informado', () {
    final title = VoiceRehearsalTopicHelper.buildListTitle(
      userTopic: 'Parte sobre fé',
      transcript: 'texto qualquer',
    );
    expect(title, 'Parte sobre fé');
  });

  test('preview usa transcrição quando sem tema', () {
    final preview = VoiceRehearsalTopicHelper.buildSubjectPreview(
      transcript: 'Jeová nos ama e quer o nosso bem',
    );
    expect(preview, contains('Jeová'));
  });

  test('transcrição vazia retorna mensagem padrão', () {
    final preview = VoiceRehearsalTopicHelper.buildSubjectPreview(
      transcript: '   ',
    );
    expect(preview, 'Ensaio sem transcrição');
  });

  test('topKeywords ignora stopwords', () {
    final keys = VoiceRehearsalTopicHelper.topKeywords(
      'jeová jeová amor amor amor fé fé',
    );
    expect(keys, isNotEmpty);
    expect(keys.contains('jeová') || keys.contains('amor'), isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/speech.dart';
import 'package:palestrante_de_sucesso/services/voice_outline_teleprompter_builder.dart';

void main() {
  test('builds sections from outline', () {
    const outline = SpeechOutline(
      introduction: 'Intro text',
      mainPoints: [
        MainPoint(id: 'p1', title: 'Ponto 1', content: 'Body one'),
      ],
      conclusion: 'End text',
    );

    final sections = VoiceOutlineTeleprompterBuilder.fromOutline(outline);
    expect(sections.length, 3);
    expect(sections.first.title, 'Introdução');
    expect(sections[1].title, 'Ponto 1');
    expect(sections.last.title, 'Conclusão');
  });
}

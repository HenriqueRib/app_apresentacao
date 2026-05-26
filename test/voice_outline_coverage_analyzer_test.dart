import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_teleprompter_section.dart';
import 'package:palestrante_de_sucesso/services/voice_outline_coverage_analyzer.dart';

void main() {
  test('returns zero when sections empty', () {
    final r = VoiceOutlineCoverageAnalyzer.analyze(
      sections: const [],
      transcript: 'texto qualquer',
    );
    expect(r.percent, 0);
    expect(r.total, 0);
  });

  test('matches title and body keywords', () {
    const sections = [
      VoiceTeleprompterSection(
        title: 'Introdução',
        body: 'Hoje falaremos sobre gratidão e esperança.',
      ),
      VoiceTeleprompterSection(
        title: 'Ponto 1',
        body: 'Devemos cultivar paciência diariamente.',
      ),
    ];

    final r = VoiceOutlineCoverageAnalyzer.analyze(
      sections: sections,
      transcript:
          'Bom dia. Hoje falaremos sobre gratidão. '
          'Precisamos cultivar paciência no dia a dia.',
    );

    expect(r.total, greaterThan(0));
    expect(r.matched, greaterThan(0));
    expect(r.percent, greaterThan(0));
  });

  test('lists missing keywords', () {
    const sections = [
      VoiceTeleprompterSection(
        title: 'Conclusão',
        body: 'Lembre-se da perseverança constante.',
      ),
    ];

    final r = VoiceOutlineCoverageAnalyzer.analyze(
      sections: sections,
      transcript: 'Obrigado pela atenção.',
    );

    expect(r.matched, lessThan(r.total));
    expect(r.missing, isNotEmpty);
  });
}

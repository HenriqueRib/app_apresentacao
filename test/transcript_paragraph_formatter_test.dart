import 'package:flutter_test/flutter_test.dart';

import 'package:palestrante_de_sucesso/services/transcript_paragraph_formatter.dart';

void main() {
  group('TranscriptParagraphFormatter', () {
    test('formata parágrafos por pontuação', () {
      final result = TranscriptParagraphFormatter.format(
        'Primeira frase completa com conteúdo suficiente para formar um parágrafo '
        'interessante sobre a matéria bíblica do dia. '
        'Segunda frase também traz ideias importantes para a assistência ouvir. '
        'Terceira frase longa que continua o raciocínio sobre a matéria designada.',
      );
      expect(result, contains('\n\n'));
      expect(result.split('\n\n').length, greaterThanOrEqualTo(2));
    });

    test('retorna vazio para texto vazio', () {
      expect(TranscriptParagraphFormatter.format(''), '');
      expect(TranscriptParagraphFormatter.format('   '), '');
    });

    test('quebra texto longo sem pontuação', () {
      final long = List.filled(40, 'palavra').join(' ');
      final result = TranscriptParagraphFormatter.format(long);
      expect(result.isNotEmpty, true);
    });
  });
}

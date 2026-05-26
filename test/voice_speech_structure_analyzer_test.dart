import 'package:flutter_test/flutter_test.dart';

import 'package:palestrante_de_sucesso/services/voice_speech_structure_analyzer.dart';

void main() {
  group('VoiceSpeechStructureAnalyzer', () {
    test('detecta pergunta na introdução', () {
      final transcript = '''
        Você já se sentiu ansioso com o futuro? Hoje vamos ver como a Bíblia
        ajuda pessoas a encontrar paz. Este assunto é importante para nossa vida.
        Jeová promete um futuro melhor. Precisamos confiar nele todos os dias.
        Portanto, aplique o que aprendeu esta semana. Faça uma decisão concreta.
        A esperança trará paz ao seu coração.
      ''';

      final analysis = VoiceSpeechStructureAnalyzer.analyze(
        transcript: transcript,
        totalDurationSeconds: 600,
        topic: 'paz',
      );

      expect(analysis.intro.text, isNotEmpty);
      expect(analysis.conclusion.text, isNotEmpty);
      expect(
        analysis.introChecks.any(
          (c) => c.id == 'pergunta_instigante' && c.status == RubricStatus.ok,
        ),
        true,
      );
    });

    test('identifica falta de chamada à ação na conclusão', () {
      final transcript = '''
        Hoje falaremos sobre fé. A fé é essencial para agradar a Deus.
        Sem fé é impossível agradar a ele. Abraão teve fé e foi recompensado.
        Moisés teve fé e viu o mar se abrir. Davi teve fé e venceu Golias.
        E assim vimos muitos exemplos de fé na Bíblia ao longo da história.
        Obrigado pela atenção de todos nesta noite especial.
      ''';

      final analysis = VoiceSpeechStructureAnalyzer.analyze(
        transcript: transcript,
        totalDurationSeconds: 480,
      );

      expect(
        analysis.conclusionChecks.any(
          (c) => c.id == 'chamada_acao' && c.status == RubricStatus.falta,
        ),
        true,
      );
      expect(analysis.conclusionScore, lessThan(3));
    });

    test('conclusão com CTA recebe score melhor', () {
      final transcript = '''
        Imagine um mundo sem violência. Hoje veremos a esperança bíblica.
        Deus prometeu um paraíso na terra para os justos que o servem.
        Isaías descreveu esse tempo de paz. Apocalipse confirma essa promessa.
        Daniel também profetizou sobre o Reino de Deus estabelecido na terra.
        Portanto, confie na promessa de Deus. Busque conhecer mais sobre ela.
        Faça isso lendo a Bíblia diariamente e ore com fé a Jeová.
      ''';

      final analysis = VoiceSpeechStructureAnalyzer.analyze(
        transcript: transcript,
        totalDurationSeconds: 600,
        topic: 'esperança',
      );

      expect(
        analysis.conclusionChecks.any(
          (c) => c.id == 'chamada_acao' && c.status == RubricStatus.ok,
        ),
        true,
      );
      expect(analysis.conclusionScore, greaterThanOrEqualTo(2));
    });

    test('currentPhase identifica fases por tempo', () {
      expect(
        VoiceSpeechStructureAnalyzer.currentPhase(
          elapsedSeconds: 30,
          totalDurationSeconds: 600,
        ),
        SpeechPhase.intro,
      );
      expect(
        VoiceSpeechStructureAnalyzer.currentPhase(
          elapsedSeconds: 550,
          totalDurationSeconds: 600,
        ),
        SpeechPhase.conclusion,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/services/s315_speaker_feedback_builder.dart';
import 'package:palestrante_de_sucesso/services/voice_speech_structure_analyzer.dart';

VoiceRehearsalSummary _strongSummary() {
  const transcript = '''
    Você já se sentiu ansioso com o futuro? Hoje veremos como a Bíblia
    em Salmos nos ajuda a encontrar paz. Jeová promete um futuro melhor
    para quem confia nele. Isaías também confirma essa esperança maravilhosa.
    Apocalipse descreve a vida eterna na terra. Daniel profetizou o Reino.
    Portanto confie na promessa de Deus. Faça isso lendo a Bíblia diariamente.
    A esperança trará paz duradoura ao seu coração grato a Jeová.
  ''';

  final structure = VoiceSpeechStructureAnalyzer.analyze(
    transcript: transcript,
    totalDurationSeconds: 600,
    topic: 'esperança',
    endingAmplitudeVariance: 3.5,
  );

  final structureJson = Map<String, dynamic>.from(structure.toJson())
    ..['introScore'] = 3
    ..['conclusionScore'] = 3
    ..['timeScore'] = 2;

  return VoiceRehearsalSummary(
    metrics: const VoiceRehearsalMetrics(
      elapsedSeconds: 600,
      wordCount: 80,
      wpm: 120,
      fillerCount: 2,
      avgAmplitudeDb: -25,
      amplitudeVariance: 3.5,
      liveScore: 8.5,
    ),
    events: const [],
    characteristicScores: const {38: 3, 39: 3, 51: 2, 4: 3, 9: 3},
    fullTranscript: transcript,
    speechStructureJson: structureJson,
  );
}

VoiceRehearsalSummary _weakConclusionSummary() {
  const transcript = '''
    Hoje falaremos sobre fé. A fé é essencial para agradar a Deus sem dúvida.
    Abraão teve fé e foi recompensado por Jeová. Moisés teve fé e viu o mar abrir.
    Davi teve fé e venceu Golias com coragem. Pedro teve fé e caminhou sobre água.
    Paulo teve fé e pregou em muitas cidades. Tiago escreveu sobre fé e obras.
    E assim vimos muitos exemplos de fé na Bíblia ao longo de toda a história.
    Obrigado pela atenção de todos nesta noite especial do congresso.
  ''';

  final structure = VoiceSpeechStructureAnalyzer.analyze(
    transcript: transcript,
    totalDurationSeconds: 480,
  );

  return VoiceRehearsalSummary(
    metrics: const VoiceRehearsalMetrics(
      elapsedSeconds: 480,
      wordCount: 90,
      wpm: 110,
      fillerCount: 8,
      liveScore: 5.5,
    ),
    events: const [],
    characteristicScores: const {38: 1, 39: 0, 51: 2},
    fullTranscript: transcript,
    insights: const [
      VoiceImprovementInsight(
        category: 'conclusao',
        message: 'Conclusão precisa de chamada à ação clara',
        suggestion: 'Indique o que fazer.',
        characteristicId: 39,
        severityRank: 4,
      ),
    ],
    speechStructureJson: structure.toJson(),
  );
}

void main() {
  group('S315SpeakerFeedbackBuilder', () {
    test('ensaio forte recebe DIS A ou B+', () {
      final feedback = S315SpeakerFeedbackBuilder.build(
        summary: _strongSummary(),
        topic: 'esperança',
        durationSeconds: 600,
      );

      expect(feedback.hasSufficientData, true);
      expect(feedback.disGrade.startsWith('A') || feedback.disGrade.startsWith('B'),
          true);
      expect(feedback.entGrade, 'NR');
      expect(feedback.habilidadeOrador, isNotEmpty);
      expect(feedback.aspectNotes, isNotEmpty);
    });

    test('conclusão fraca reduz DIS e menciona chamada à ação', () {
      final feedback = S315SpeakerFeedbackBuilder.build(
        summary: _weakConclusionSummary(),
        durationSeconds: 480,
      );

      expect(feedback.disGrade, isNot(equals('A+')));
      expect(
        feedback.habilidadeOrador.toLowerCase(),
        anyOf(
          contains('conclusão'),
          contains('conclusao'),
          contains('chamada'),
        ),
      );
    });

    test('transcrição vazia retorna DIS NR', () {
      final feedback = S315SpeakerFeedbackBuilder.build(
        summary: const VoiceRehearsalSummary(
          metrics: VoiceRehearsalMetrics(elapsedSeconds: 30),
          events: [],
          characteristicScores: {},
        ),
        durationSeconds: 30,
      );

      expect(feedback.disGrade, 'NR');
      expect(feedback.hasSufficientData, false);
      expect(feedback.habilidadeOrador, contains('insuficientes'));
    });

    test('ENT sempre NR', () {
      final feedback = S315SpeakerFeedbackBuilder.build(
        summary: _strongSummary(),
        durationSeconds: 600,
      );
      expect(feedback.entGrade, 'NR');
    });

    test('personalidade inclui aviso sobre anciãos', () {
      final feedback = S315SpeakerFeedbackBuilder.build(
        summary: _strongSummary(),
        durationSeconds: 600,
      );
      expect(feedback.personalidade.toLowerCase(), contains('anciãos'));
    });
  });
}

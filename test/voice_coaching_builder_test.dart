import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/services/voice_analysis_engine.dart';
import 'package:palestrante_de_sucesso/services/voice_coaching_builder.dart';
import 'package:palestrante_de_sucesso/services/voice_speech_structure_analyzer.dart';

void main() {
  test('muleta gera trecho observado e avoid/tryInstead', () {
    const transcript =
        'Então eu acho que então a fé então é importante então tipo assim';
    final insights = VoiceCoachingBuilder.build(
      transcript: transcript,
      metrics: const VoiceRehearsalMetrics(
        wordCount: 12,
        fillerCount: 4,
      ),
      fillerByWord: {'então': 4, 'tipo': 1},
      vagueByWord: const {},
      repetitionOffenders: const [],
      lowConfidenceSegments: 0,
      recentLongPauses: 0,
      amplitudeSampleCount: 0,
    );

    final muleta = insights.firstWhere((i) => i.category == 'muleta');
    expect(muleta.observed, isNotNull);
    expect(muleta.observed, contains('então'));
    expect(muleta.avoid, isNotNull);
    expect(muleta.tryInstead, isNotNull);
    expect(muleta.characteristicId, 4);
    expect(muleta.beforeExample, isNotNull);
    expect(muleta.afterExample, isNotNull);
  });

  test('articulação referencia char #2 com baixa confiança', () {
    final insights = VoiceCoachingBuilder.build(
      transcript: 'texto curto',
      metrics: const VoiceRehearsalMetrics(wordCount: 2),
      fillerByWord: const {},
      vagueByWord: const {},
      repetitionOffenders: const [],
      lowConfidenceSegments: 3,
      recentLongPauses: 0,
      amplitudeSampleCount: 0,
    );

    final art = insights.firstWhere((i) => i.category == 'articulacao');
    expect(art.characteristicId, 2);
    expect(art.observed, contains('3 trechos'));
    expect(art.avoid, isNotNull);
    expect(art.tryInstead, isNotNull);
  });

  test('volume baixo referencia dB e char #8', () {
    final insights = VoiceCoachingBuilder.build(
      transcript: '',
      metrics: const VoiceRehearsalMetrics(
        avgAmplitudeDb: -42,
      ),
      fillerByWord: const {},
      vagueByWord: const {},
      repetitionOffenders: const [],
      lowConfidenceSegments: 0,
      recentLongPauses: 0,
      amplitudeSampleCount: 15,
    );

    final vol = insights.firstWhere((i) => i.category == 'volume');
    expect(vol.characteristicId, 8);
    expect(vol.observed, contains('-42'));
    expect(vol.avoid, isNotNull);
    expect(vol.tryInstead, isNotNull);
  });

  test('extractSnippet retorna trecho ao redor da palavra', () {
    const text =
        'Jeová nos ama muito e quer o nosso bem espiritual todos os dias';
  final snippet = VoiceCoachingBuilder.extractSnippet(text, 'ama');
    expect(snippet, isNotNull);
    expect(snippet, contains('ama'));
  });

  test('fromJson antigo sem campos novos continua legível', () {
    final insight = VoiceImprovementInsight.fromJson({
      'category': 'muleta',
      'message': 'Muleta tipo',
      'suggestion': 'Pause',
      'characteristicId': 4,
      'severityRank': 2,
    });
    expect(insight.observed, isNull);
    expect(insight.avoid, isNull);
    expect(insight.message, 'Muleta tipo');
  });

  test('estrutura gera insights de intro e conclusão (#38/#39)', () {
    const transcript = '''
      Você já pensou no futuro? Hoje falaremos sobre esperança bíblica.
      Deus prometeu um paraíso na terra para os justos que o servem fielmente.
      Isaías descreveu esse tempo de paz eterna para toda a humanidade obediente.
      Apocalipse confirma essa promessa maravilhosa de vida sem sofrimento algum.
      Portanto confie na promessa divina. Faça isso lendo a Bíblia todos os dias.
      A esperança trará paz duradoura ao seu coração grato a Jeová.
    ''';

    final structure = VoiceSpeechStructureAnalyzer.analyze(
      transcript: transcript,
      totalDurationSeconds: 600,
      topic: 'esperança',
    );

    final insights = VoiceCoachingBuilder.build(
      transcript: transcript,
      metrics: const VoiceRehearsalMetrics(
        wordCount: 60,
        elapsedSeconds: 600,
      ),
      fillerByWord: const {},
      vagueByWord: const {},
      repetitionOffenders: const [],
      lowConfidenceSegments: 0,
      recentLongPauses: 0,
      amplitudeSampleCount: 0,
      structure: structure,
      topic: 'esperança',
    );

    expect(
      insights.any((i) => i.characteristicId == 38 || i.characteristicId == 39),
      true,
    );
  });

  test('muleta custom detectada pelo engine', () {
    final engine = VoiceAnalysisEngine();
    engine.setFillerWords({'basicamente', 'é'});
    engine.onTranscript(
      'basicamente basicamente basicamente basicamente basicamente',
    );
    expect(
      engine.insights.any((i) => i.category == 'muleta'),
      isTrue,
    );
  });
}

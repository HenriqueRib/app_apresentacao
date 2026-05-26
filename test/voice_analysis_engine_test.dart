import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/services/voice_analysis_engine.dart';

void main() {
  late VoiceAnalysisEngine engine;

  setUp(() {
    engine = VoiceAnalysisEngine();
  });

  test('contagem de palavras com transcript simulado', () {
    engine.onTranscript(
      'palavra um dois três quatro cinco seis sete oito nove dez',
    );
    expect(engine.metrics.wordCount, greaterThanOrEqualTo(10));
  });

  test('detecção de muletas dispara evento característica 4', () {
    engine.onTranscript(
      'é então tipo né aí é então tipo né aí hum ah',
    );
    final fluencyEvents =
        engine.events.where((e) => e.characteristicId == 4).toList();
    expect(fluencyEvents, isNotEmpty);
    expect(
      fluencyEvents.any((e) => e.severity == VoiceFeedbackSeverity.warning),
      isTrue,
    );
  });

  test('muleta específica aparece na mensagem', () {
    engine.onTranscript('tipo tipo tipo tipo tipo tipo tipo tipo');
    final named = engine.events
        .where((e) => e.message.contains('tipo'))
        .toList();
    expect(named, isNotEmpty);
  });

  test('repetição de palavra gera insight', () {
    engine.onTranscript(
      'jeová jeová jeová jeová jeová jeová jeová jeová jeová jeová jeová jeová',
    );
    expect(
      engine.insights.any((i) => i.category == 'repeticao'),
      isTrue,
    );
  });

  test('nota começa em zero após reset', () {
    expect(engine.liveScore, 0);
  });

  test('nota sobe com bom desempenho vocal', () {
    for (var i = 0; i < 15; i++) {
      engine.onAmplitude(-25);
    }
    engine.tick(const Duration(seconds: 15));
    engine.onTranscript(
      'palavra um dois três quatro cinco seis sete oito nove dez onze doze',
    );
    expect(engine.liveScore, greaterThan(0));
  });

  test('nota permanece baixa com muitas muletas', () {
    engine.onTranscript(
      'é é é é é é é é é é é é é é é é é é é é é é é é',
    );
    expect(engine.liveScore, lessThan(3));
  });

  test('amplitude baixa dispara evento característica 8', () {
    for (var i = 0; i < 15; i++) {
      engine.onAmplitude(-40);
    }
    final volumeEvents =
        engine.events.where((e) => e.characteristicId == 8).toList();
    expect(volumeEvents, isNotEmpty);
  });

  test('variância baixa dispara evento característica 9', () {
    for (var i = 0; i < 35; i++) {
      engine.onAmplitude(-20);
    }
    final modulationEvents =
        engine.events.where((e) => e.characteristicId == 9).toList();
    expect(modulationEvents, isNotEmpty);
  });

  test('debounce impede alertas duplicados do mesmo ID', () {
    for (var i = 0; i < 15; i++) {
      engine.onAmplitude(-40);
    }
    final firstCount =
        engine.events.where((e) => e.characteristicId == 8).length;
    for (var i = 0; i < 15; i++) {
      engine.onAmplitude(-40);
    }
    final secondCount =
        engine.events.where((e) => e.characteristicId == 8).length;
    expect(secondCount, firstCount);
  });

  test('buildSummary retorna scores e breakdown', () {
    engine.onTranscript('é é é é é é é é é é é é é é é é');
    final summary = engine.buildSummary();
    expect(summary.characteristicScores.length,
        kMonitoredVoiceCharacteristicIds.length);
    expect(summary.insights, isNotEmpty);
  });

  test('reset limpa estado', () {
    engine.onTranscript('é então tipo né aí');
    engine.reset();
    expect(engine.events, isEmpty);
    expect(engine.metrics.wordCount, 0);
    expect(engine.liveScore, 0);
  });
}

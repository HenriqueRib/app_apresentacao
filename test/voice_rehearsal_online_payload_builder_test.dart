import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal_attempt.dart';
import 'package:palestrante_de_sucesso/services/voice_rehearsal_online_payload_builder.dart';

VoiceRehearsalAttempt _attempt({
  String transcript = '',
  int wordCount = 0,
}) {
  return VoiceRehearsalAttempt(
    id: 'test-id',
    createdAt: DateTime(2026, 5, 25),
    mode: VoiceSessionMode.training,
    durationSeconds: 300,
    finalScore: 7.5,
    topic: 'esperança',
    subjectPreview: 'Resumo do assunto',
    summary: VoiceRehearsalSummary(
      metrics: VoiceRehearsalMetrics(
        elapsedSeconds: 300,
        wordCount: wordCount,
        wpm: 120,
        fillerCount: 3,
        liveScore: 7.5,
      ),
      events: const [],
      characteristicScores: const {38: 2, 39: 2},
      fullTranscript: transcript,
      insights: const [
        VoiceImprovementInsight(
          category: 'ritmo',
          message: 'Ritmo adequado',
          suggestion: 'Mantenha o ritmo.',
          characteristicId: 4,
        ),
      ],
    ),
  );
}

void main() {
  group('VoiceRehearsalOnlinePayloadBuilder', () {
    test('canAnalyze false quando transcrição vazia', () {
      final attempt = _attempt(transcript: '', wordCount: 0);
      expect(VoiceRehearsalOnlinePayloadBuilder.canAnalyze(attempt), isFalse);
    });

    test('canAnalyze false quando poucas palavras', () {
      final attempt = _attempt(transcript: 'olá mundo', wordCount: 2);
      expect(VoiceRehearsalOnlinePayloadBuilder.canAnalyze(attempt), isFalse);
    });

    test('validate lança exceção sem transcrição', () {
      final attempt = _attempt();
      expect(
        () => VoiceRehearsalOnlinePayloadBuilder.validate(attempt),
        throwsA(isA<VoiceRehearsalOnlinePayloadException>()),
      );
    });

    test('build monta payload com campos obrigatórios', () {
      const transcript =
          'Jeová nos ama profundamente e a Bíblia confirma essa verdade '
          'maravilhosa todos os dias da nossa vida de serviço fiel a ele.';
      final attempt = _attempt(transcript: transcript, wordCount: 25);

      final payload = VoiceRehearsalOnlinePayloadBuilder.build(attempt);

      expect(payload['ensaio_id'], 'test-id');
      expect(payload['modo'], 'treino');
      expect(payload['topico'], 'esperança');
      expect(payload['duracao_segundos'], 300);
      expect(payload['nota_local'], 7.5);
      expect(payload['idioma'], 'pt-BR');

      final transcricao = payload['transcricao'] as Map<String, dynamic>;
      expect(transcricao['texto'], transcript);

      final metricas = payload['metricas_locais'] as Map<String, dynamic>;
      expect(metricas['word_count'], 25);
      expect(metricas['filler_count'], 3);

      final s315 = payload['s315_local'] as Map<String, dynamic>;
      expect(s315['notas'], isA<Map>());
      expect(s315['bullets'], isA<List>());

      final insights = payload['insights_locais'] as List;
      expect(insights, isNotEmpty);
      expect(insights.first['category'], 'ritmo');
    });
  });
}

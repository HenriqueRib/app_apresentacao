import '../models/voice_rehearsal.dart';
import '../models/voice_rehearsal_attempt.dart';
import 's315_speaker_feedback_builder.dart';

class VoiceRehearsalOnlinePayloadException implements Exception {
  final String message;
  const VoiceRehearsalOnlinePayloadException(this.message);

  @override
  String toString() => message;
}

class VoiceRehearsalOnlinePayloadBuilder {
  static const minWordCount = 20;

  static bool canAnalyze(VoiceRehearsalAttempt attempt) {
    final transcript = attempt.summary.fullTranscript.trim();
    return transcript.isNotEmpty &&
        attempt.summary.metrics.wordCount >= minWordCount;
  }

  static void validate(VoiceRehearsalAttempt attempt) {
    final transcript = attempt.summary.fullTranscript.trim();
    if (transcript.isEmpty) {
      throw const VoiceRehearsalOnlinePayloadException(
        'Transcrição vazia. Use o modo Treino ou transcreva a gravação antes.',
      );
    }
    if (attempt.summary.metrics.wordCount < minWordCount) {
      throw VoiceRehearsalOnlinePayloadException(
        'Transcrição muito curta para análise online (mínimo $minWordCount palavras).',
      );
    }
  }

  static Map<String, dynamic> build(VoiceRehearsalAttempt attempt) {
    validate(attempt);

    final summary = attempt.summary;
    final s315 = S315SpeakerFeedbackBuilder.build(
      summary: summary,
      topic: attempt.topic,
      durationSeconds: attempt.durationSeconds,
    );

    final bullets = <String>[
      ...s315.aspectNotes.map((n) => n.label),
      if (s315.habilidadeOrador.isNotEmpty) 'habilidade: resumo local',
      if (s315.personalidade.isNotEmpty) 'personalidade: resumo local',
    ];

    final structure = summary.speechStructureJson ?? {};

    return {
      'ensaio_id': attempt.id,
      'modo': attempt.mode == VoiceSessionMode.training ? 'treino' : 'gravacao',
      if (attempt.topic != null && attempt.topic!.trim().isNotEmpty)
        'topico': attempt.topic!.trim(),
      'duracao_segundos': attempt.durationSeconds,
      'nota_local': attempt.finalScore,
      'transcricao': {
        'texto': summary.fullTranscript,
        if (summary.formattedTranscript.isNotEmpty)
          'texto_formatado': summary.formattedTranscript,
      },
      'metricas_locais': {
        'wpm': summary.metrics.wpm,
        'word_count': summary.metrics.wordCount,
        'filler_count': summary.metrics.fillerCount,
        'long_pause_count': summary.metrics.longPauseCount,
        'vague_word_count': summary.metrics.vagueWordCount,
        'avg_amplitude_db': summary.metrics.avgAmplitudeDb,
        'amplitude_variance': summary.metrics.amplitudeVariance,
        'live_score': summary.metrics.liveScore,
      },
      if (structure.isNotEmpty) 'estrutura_local': structure,
      'caracteristicas_be_t': summary.characteristicScores.entries
          .map(
            (e) => {
              'id': e.key,
              'score': e.value,
            },
          )
          .toList(),
      'insights_locais': summary.insights
          .map(
            (i) => {
              'category': i.category,
              'message': i.message,
              'suggestion': i.suggestion,
              if (i.characteristicId != null)
                'characteristic_id': i.characteristicId,
              'severity_rank': i.severityRank,
            },
          )
          .toList(),
      's315_local': {
        'notas': {
          'DIS': s315.disGrade,
          'ENT': s315.entGrade,
        },
        'bullets': bullets,
      },
      'idioma': 'pt-BR',
    };
  }
}

import '../models/s315_speaker_feedback.dart';
import '../models/voice_rehearsal.dart';
import 'voice_analysis_engine.dart';
import 'voice_speech_structure_analyzer.dart';

/// Gera rascunho de feedback inspirado no S-315 a partir do resumo do ensaio.
class S315SpeakerFeedbackBuilder {
  static const _disclaimer =
      'Rascunho auxiliar inspirado nas orientações S-315. '
      'Não substitui a avaliação do corpo de anciãos.';

  static const _emotionalWords = {
    'amor', 'coração', 'coracao', 'esperança', 'esperanca', 'alegria',
    'paz', 'gratidão', 'gratidao', 'bondade', 'compaixão', 'compaixao',
    'feliz', 'triste', 'medo', 'ansiedade',
  };

  static const _abstractWords = {
    'princípio', 'principio', 'conceito', 'doctrina', 'teoria',
    'argumento', 'lógica', 'logica', 'análise', 'analise', 'estrutura',
  };

  static const _bibleMarkers = {
    'bíblia', 'biblia', 'escritura', 'escrituras', 'versículo', 'versiculo',
    'jeová', 'jeova', 'deus', 'criador', 'salmos', 'provérbios', 'proverbios',
    'mateus', 'joão', 'joao', 'atos', 'romanos', 'gênesis', 'genesis',
  };

  static S315SpeakerFeedback build({
    required VoiceRehearsalSummary summary,
    String? topic,
    required int durationSeconds,
  }) {
    final transcript = summary.fullTranscript.trim();
    final hasData =
        transcript.isNotEmpty && durationSeconds >= 60 && summary.metrics.wordCount >= 20;

    if (!hasData) {
      return const S315SpeakerFeedback(
        disGrade: 'NR',
        habilidadeOrador:
            'Dados insuficientes para gerar observações. '
            'Transcreva o ensaio (modo Treino ou análise da gravação) '
            'com pelo menos 1 minuto de fala.',
        personalidade:
            'Humildade, equilíbrio e zelo na pregação devem ser '
            'confirmados pelo corpo de anciãos.',
        hasSufficientData: false,
      );
    }

    final structure = summary.speechStructureJson != null
        ? SpeechStructureAnalysis.fromJson(summary.speechStructureJson!)
        : VoiceSpeechStructureAnalyzer.analyze(
            transcript: transcript,
            totalDurationSeconds: durationSeconds,
            topic: topic,
            endingAmplitudeVariance: summary.metrics.amplitudeVariance,
          );

    final introScore = structure.introScore;
    final conclusionScore = structure.conclusionScore;
    final timeScore = structure.timeScore;
    final liveScore = summary.metrics.liveScore;
    final criticalInsights = summary.insights.where((i) => i.severityRank >= 3).length;

    final disGrade = _computeDisGrade(
      liveScore: liveScore,
      introScore: introScore,
      conclusionScore: conclusionScore,
      timeScore: timeScore,
      criticalInsights: criticalInsights,
      fillerCount: summary.metrics.fillerCount,
      wordCount: summary.metrics.wordCount,
    );

    final aspectNotes = _buildAspectNotes(summary, structure, transcript);
    final habilidade = _buildHabilidadeOrador(summary, structure, transcript, topic);
    final personalidade = _buildPersonalidade(summary);

    return S315SpeakerFeedback(
      disGrade: disGrade,
      entGrade: 'NR',
      habilidadeOrador: habilidade,
      personalidade: personalidade,
      aspectNotes: aspectNotes,
      disclaimer: _disclaimer,
    );
  }

  static String _computeDisGrade({
    required double liveScore,
    required int introScore,
    required int conclusionScore,
    required int timeScore,
    required int criticalInsights,
    required int fillerCount,
    required int wordCount,
  }) {
    String base;
    if (liveScore >= 8.0 &&
        introScore >= 2 &&
        conclusionScore >= 2 &&
        timeScore >= 2 &&
        criticalInsights <= 1) {
      base = 'A';
    } else if (liveScore >= 6.5 && (introScore >= 2 || conclusionScore >= 2)) {
      base = 'B';
    } else if (liveScore >= 4.5) {
      base = 'C';
    } else {
      return 'C-';
    }

    var modifier = '';
    final structureAvg = (introScore + conclusionScore + timeScore) / 3;
    if (structureAvg >= 2.5 && liveScore >= 7.5 && criticalInsights == 0) {
      modifier = '+';
    } else if (structureAvg < 1.5 ||
        criticalInsights >= 3 ||
        (wordCount > 0 && fillerCount / wordCount > 0.1)) {
      modifier = '-';
    }

    return '$base$modifier';
  }

  static List<S315AspectNote> _buildAspectNotes(
    VoiceRehearsalSummary summary,
    SpeechStructureAnalysis structure,
    String transcript,
  ) {
    final notes = <S315AspectNote>[];
    final m = summary.metrics;
    final lower = transcript.toLowerCase();

    notes.add(S315AspectNote(
      label: 'Tom da voz',
      status: _voiceToneStatus(m),
      detail: m.amplitudeVariance >= VoiceAnalysisThresholds.modulationMinVariance
          ? 'Modulação adequada durante o ensaio.'
          : 'Voz tendeu a monotonia — varie tom conforme o sentido.',
    ));

    notes.add(S315AspectNote(
      label: 'Fluência e expressão',
      status: _fluencyStatus(m),
      detail: m.wpm >= VoiceAnalysisThresholds.wpmLow &&
              m.wpm <= VoiceAnalysisThresholds.wpmHigh
          ? 'Ritmo conversante (${m.wpm.toStringAsFixed(0)} WPM).'
          : 'Ritmo fora do ideal (${m.wpm.toStringAsFixed(0)} WPM).',
    ));

    notes.add(S315AspectNote(
      label: 'Linha de raciocínio coerente',
      status: _structureStatus(structure),
      detail: structure.introScore >= 2 && structure.conclusionScore >= 2
          ? 'Introdução e conclusão identificáveis com boa estrutura.'
          : 'Estrutura intro/corpo/conclusão pode ser reforçada.',
    ));

    final hasBible = _bibleMarkers.any(lower.contains);
    notes.add(S315AspectNote(
      label: 'Clareza na exposição bíblica',
      status: hasBible ? S315AspectStatus.ok : S315AspectStatus.atencao,
      detail: hasBible
          ? 'Referências bíblicas detectadas na transcrição.'
          : 'Poucas ou nenhuma referência bíblica explícita no trecho analisado.',
    ));

    final emotional = _emotionalWords.where(lower.contains).length;
    final abstract = _abstractWords.where(lower.contains).length;
    final styleLabel = emotional > abstract
        ? 'Estilo mais voltado à expressão de sentimento.'
        : abstract > emotional
            ? 'Estilo mais intelectual/analítico.'
            : 'Equilíbrio entre ideias e sentimento.';
    notes.add(S315AspectNote(
      label: 'Estilo de apresentação',
      status: S315AspectStatus.ok,
      detail: styleLabel,
    ));

    return notes;
  }

  static S315AspectStatus _voiceToneStatus(VoiceRehearsalMetrics m) {
    if (m.amplitudeVariance >= VoiceAnalysisThresholds.modulationMinVariance &&
        m.avgAmplitudeDb >= VoiceAnalysisThresholds.volumeLowDb &&
        m.avgAmplitudeDb <= VoiceAnalysisThresholds.volumeHighDb) {
      return S315AspectStatus.ok;
    }
    if (m.amplitudeVariance < VoiceAnalysisThresholds.modulationMinVariance ||
        m.avgAmplitudeDb < VoiceAnalysisThresholds.volumeLowDb) {
      return S315AspectStatus.atencao;
    }
    return S315AspectStatus.ok;
  }

  static S315AspectStatus _fluencyStatus(VoiceRehearsalMetrics m) {
    if (m.wpm >= VoiceAnalysisThresholds.wpmLow &&
        m.wpm <= VoiceAnalysisThresholds.wpmHigh &&
        m.fillerCount <= m.wordCount * 0.06) {
      return S315AspectStatus.ok;
    }
    if (m.fillerCount > m.wordCount * 0.1) return S315AspectStatus.falta;
    return S315AspectStatus.atencao;
  }

  static S315AspectStatus _structureStatus(SpeechStructureAnalysis structure) {
    final avg = (structure.introScore + structure.conclusionScore) / 2;
    if (avg >= 2.5) return S315AspectStatus.ok;
    if (avg >= 1.5) return S315AspectStatus.atencao;
    return S315AspectStatus.falta;
  }

  static String _buildHabilidadeOrador(
    VoiceRehearsalSummary summary,
    SpeechStructureAnalysis structure,
    String transcript,
    String? topic,
  ) {
    final m = summary.metrics;
    final parts = <String>[];

    if (m.amplitudeVariance >= VoiceAnalysisThresholds.modulationMinVariance) {
      parts.add(
        'O tom da voz variou conforme o sentido da matéria, '
        'o que ajuda a manter o interesse da assistência.',
      );
    } else {
      parts.add(
        'O tom da voz manteve-se relativamente uniforme; '
        'variar intensidade pode tornar o discurso mais envolvente.',
      );
    }

    if (m.wpm >= VoiceAnalysisThresholds.wpmLow &&
        m.wpm <= VoiceAnalysisThresholds.wpmHigh) {
      parts.add(
        'A fluência foi conversante (${m.wpm.toStringAsFixed(0)} palavras/min), '
        'facilitando o acompanhamento das ideias.',
      );
    } else {
      parts.add(
        'O ritmo (${m.wpm.toStringAsFixed(0)} WPM) pode ser ajustado '
        'para dar mais clareza aos pontos principais.',
      );
    }

    if (structure.introScore >= 2) {
      parts.add(
        'A introdução despertou interesse ou identificou o assunto '
        'de forma adequada.',
      );
    } else {
      parts.add(
        'A introdução pode ser reforçada com pergunta instigante '
        'ou cenário que mostre a relevância do tema.',
      );
    }

    if (structure.conclusionScore >= 2) {
      parts.add(
        'A conclusão indicou encerramento lógico e orientação prática.',
      );
    } else {
      parts.add(
        'A conclusão precisa de chamada à ação mais clara — '
        'indique o que a assistência deve fazer com a matéria.',
      );
    }

    if (topic != null && topic.trim().isNotEmpty) {
      parts.add('Tema ensaiado: «${topic.trim()}».');
    }

    final lower = transcript.toLowerCase();
    if (_bibleMarkers.any(lower.contains)) {
      parts.add(
        'Houve menção a conteúdo bíblico, o que favorece a clareza '
        'do ensino teocrático.',
      );
    }

    return parts.join(' ');
  }

  static String _buildPersonalidade(VoiceRehearsalSummary summary) {
    final m = summary.metrics;
    final parts = <String>[];

    if (m.amplitudeVariance >= VoiceAnalysisThresholds.modulationMinVariance &&
        m.wpm >= VoiceAnalysisThresholds.wpmLow) {
      parts.add(
        'Durante o ensaio, a voz transmitiu vivacidade e convicção, '
        'sugerindo tom bondoso e animado na entrega.',
      );
    } else {
      parts.add(
        'A entrega pode refletir mais entusiasmo e cordialidade '
        'com modulação e ritmo mais vivos.',
      );
    }

    parts.add(
      'Humildade, equilíbrio e zelo na pregação devem ser confirmados '
      'pelo corpo de anciãos — aspectos que não podem ser avaliados '
      'apenas por um ensaio de voz.',
    );

    return parts.join(' ');
  }
}

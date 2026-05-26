import '../models/voice_rehearsal.dart';
import 'characteristics_service.dart';
import 'voice_analysis_engine.dart';
import 'voice_speech_structure_analyzer.dart';

/// Monta dicas de coaching no formato observado / evite / faça assim.
class VoiceCoachingBuilder {
  static const _synonymHints = {
    'amor': 'afeto, carinho, bondade',
    'jeová': 'nosso Pai, o Criador, Deus',
    'fé': 'confiança, convicção, certeza',
    'vida': 'existência, caminho, jornada',
    'pessoas': 'indivíduos, irmãos, ouvintes',
    'importante': 'essencial, fundamental, decisivo',
  };

  static List<VoiceImprovementInsight> build({
    required String transcript,
    required VoiceRehearsalMetrics metrics,
    required Map<String, int> fillerByWord,
    required Map<String, int> vagueByWord,
    required List<WordStat> repetitionOffenders,
    required int lowConfidenceSegments,
    required int recentLongPauses,
    required int amplitudeSampleCount,
    SpeechStructureAnalysis? structure,
    String? topic,
  }) {
    final list = <VoiceImprovementInsight>[];
    final wordCount = metrics.wordCount;

    for (final entry in repetitionOffenders) {
      final pct = (entry.ratio(wordCount) * 100).toStringAsFixed(0);
      final snippet = extractSnippet(transcript, entry.word);
      final synonyms = _synonymHints[entry.word] ?? 'outras palavras equivalentes';
      list.add(VoiceImprovementInsight(
        category: 'repeticao',
        message: "Repetiu '${entry.word}' ${entry.count} vezes ($pct%)",
        suggestion: 'Varie a formulação para manter o interesse.',
        characteristicId: 4,
        severityRank: entry.count,
        observed:
            "Você repetiu '${entry.word}' ${entry.count} vezes ($pct% das palavras)."
            '${snippet != null ? " Trecho: «$snippet»" : ''}',
        avoid:
            "Não repita '${entry.word}' várias vezes seguidas — isso cansa quem ouve.",
        tryInstead:
            'Reformule com sinônimos ($synonyms) ou resuma a ideia em uma frase nova.',
        beforeExample: snippet,
        afterExample: snippet != null
            ? _repetitionAfterExample(snippet, entry.word, synonyms)
            : null,
      ));
    }

    for (final entry in fillerByWord.entries) {
      if (entry.value < 2) continue;
      final snippet = extractSnippet(transcript, entry.key);
      list.add(VoiceImprovementInsight(
        category: 'muleta',
        message: "Muleta '${entry.key}' usada ${entry.value} vezes",
        suggestion: 'Substitua por uma pausa curta e retome com confiança.',
        characteristicId: 4,
        severityRank: entry.value,
        observed:
            "A muleta '${entry.key}' apareceu ${entry.value} vezes no seu discurso."
            '${snippet != null ? " Exemplo: «$snippet»" : ''}',
        avoid:
            "Não encha o discurso com '${entry.key}' — isso não acrescenta sentido.",
        tryInstead:
            'Quando sentir vontade de dizer "${entry.key}", pare 1 segundo, respire e continue com a próxima ideia. '
            '${_charAction(4)}',
        beforeExample: snippet,
        afterExample: snippet != null
            ? _stripFillers(snippet, fillerByWord.keys.toSet())
            : null,
      ));
    }

    for (final entry in vagueByWord.entries) {
      if (entry.value < 2) continue;
      final snippet = extractSnippet(transcript, entry.key);
      list.add(VoiceImprovementInsight(
        category: 'vaga',
        message: "Palavra vaga '${entry.key}' repetida ${entry.value} vezes",
        suggestion: 'Nomeie o conceito com precisão — evite termos genéricos.',
        characteristicId: 24,
        severityRank: entry.value,
        observed:
            "Você usou '${entry.key}' ${entry.value} vezes de forma genérica."
            '${snippet != null ? " Trecho: «$snippet»" : ''}',
        avoid:
            "Não diga '${entry.key}' quando puder ser específico — o ouvinte fica sem clareza.",
        tryInstead:
            'Substitua por um substantivo concreto: diga exatamente o que quer dizer '
            '(ex.: princípio, experiência, ensinamento). ${_charAction(24)}',
        beforeExample: snippet,
        afterExample: snippet != null
            ? snippet.replaceAll(
                RegExp(entry.key, caseSensitive: false),
                '[conceito específico]',
              )
            : null,
      ));
    }

    if (metrics.wpm > 0 && metrics.wpm < VoiceAnalysisThresholds.wpmLow) {
      list.add(VoiceImprovementInsight(
        category: 'ritmo',
        message: 'Ritmo lento: ${metrics.wpm.toStringAsFixed(0)} WPM',
        suggestion: 'Mantenha fluidez conversante sem correr.',
        characteristicId: 28,
        severityRank: 3,
        observed:
            'Seu ritmo ficou em ${metrics.wpm.toStringAsFixed(0)} palavras por minuto '
            '(ideal: ${VoiceAnalysisThresholds.wpmLow.toInt()}–${VoiceAnalysisThresholds.wpmHigh.toInt()} WPM).',
        avoid:
            'Não fale tão devagar que pareça hesitação ou falta de preparo.',
        tryInstead:
            'Agrupe palavras por ideia e avance com fluidez — como numa conversa clara. '
            '${_charAction(28)}',
        beforeExample:
            '“Esta… ideia… é… muito… importante… para… nós…” (hesitação)',
        afterExample:
            '“Esta ideia é importante para nós e merece nossa atenção.” (fluidez)',
      ));
    } else if (metrics.wpm > VoiceAnalysisThresholds.wpmHigh) {
      list.add(VoiceImprovementInsight(
        category: 'ritmo',
        message: 'Ritmo acelerado: ${metrics.wpm.toStringAsFixed(0)} WPM',
        suggestion: 'Desacelere para dar clareza às ideias principais.',
        characteristicId: 28,
        severityRank: 3,
        observed:
            'Seu ritmo ficou em ${metrics.wpm.toStringAsFixed(0)} palavras por minuto '
            '(ideal: ${VoiceAnalysisThresholds.wpmLow.toInt()}–${VoiceAnalysisThresholds.wpmHigh.toInt()} WPM).',
        avoid:
            'Não acelere tanto — a assistência perde detalhes importantes.',
        tryInstead:
            'Faça pausas curtas entre ideias e pronuncie as palavras-chave com calma. '
            '${_charAction(28)}',
        beforeExample:
            '“Jeová nos ama Jeová quer o nosso bem Jeová é bondoso…” (correndo)',
        afterExample:
            '“Jeová nos ama. Ele quer o nosso bem. Jeová é bondoso.” (pausas curtas)',
      ));
    }

    if (metrics.avgAmplitudeDb < VoiceAnalysisThresholds.volumeLowDb &&
        amplitudeSampleCount >= 10) {
      list.add(VoiceImprovementInsight(
        category: 'volume',
        message: 'Volume baixo (${metrics.avgAmplitudeDb.toStringAsFixed(0)} dB)',
        suggestion: 'Projete a voz para que todos ouçam com clareza.',
        characteristicId: 8,
        severityRank: 2,
        observed:
            'Seu volume médio ficou em ${metrics.avgAmplitudeDb.toStringAsFixed(0)} dB '
            '(abaixo do ideal: ${VoiceAnalysisThresholds.volumeLowDb.toInt()} a '
            '${VoiceAnalysisThresholds.volumeHighDb.toInt()} dB).',
        avoid:
            'Não sussurre nem fale só para quem está perto — quem está longe não ouve.',
        tryInstead:
            'Projete a voz como se estivesse falando com alguém na última fila. '
            '${_charAction(8)}',
        beforeExample: '“…precisamos confiar…” (sussurro, difícil de ouvir)',
        afterExample: '“Precisamos confiar em Jeová.” (voz projetada)',
      ));
    } else if (metrics.avgAmplitudeDb > VoiceAnalysisThresholds.volumeHighDb &&
        amplitudeSampleCount >= 10) {
      list.add(VoiceImprovementInsight(
        category: 'volume',
        message: 'Volume alto (${metrics.avgAmplitudeDb.toStringAsFixed(0)} dB)',
        suggestion: 'Modere a intensidade para não soar agressivo.',
        characteristicId: 8,
        severityRank: 2,
        observed:
            'Seu volume médio ficou em ${metrics.avgAmplitudeDb.toStringAsFixed(0)} dB '
            '(acima do ideal: ${VoiceAnalysisThresholds.volumeLowDb.toInt()} a '
            '${VoiceAnalysisThresholds.volumeHighDb.toInt()} dB).',
        avoid:
            'Não grite nem force demais a garganta — cansa você e distrai quem ouve.',
        tryInstead:
            'Mantenha firmeza sem exagero: volume constante e controlado. '
            '${_charAction(8)}',
        beforeExample: '“JEová NOS Ama!” (gritando, forçado)',
        afterExample: '“Jeová nos ama.” (firme, sem exagero)',
      ));
    }

    if (metrics.amplitudeVariance > 0 &&
        metrics.amplitudeVariance <
            VoiceAnalysisThresholds.modulationMinVariance &&
        amplitudeSampleCount >= 30) {
      list.add(VoiceImprovementInsight(
        category: 'modulacao',
        message: 'Voz monótona detectada',
        suggestion: 'Varie tom e intensidade conforme o sentido da matéria.',
        characteristicId: 9,
        severityRank: 2,
        observed:
            'Sua voz manteve tom e intensidade muito parecidos durante o ensaio.',
        avoid:
            'Não fale tudo no mesmo tom — a mensagem parece monótona e perde impacto.',
        tryInstead:
            'Destaque palavras-chave com mais intensidade e suavize transições. '
            '${_charAction(9)}',
        beforeExample: '“jeová nos ama e quer o nosso bem” (tom plano)',
        afterExample: '“Jeová nos ama e quer o nosso bem.” (ênfase em “ama”)',
      ));
    }

    if (lowConfidenceSegments >= 2) {
      list.add(VoiceImprovementInsight(
        category: 'articulacao',
        message: 'Articulação pode melhorar',
        suggestion: 'Abra a boca e pronuncie sílabas distintas.',
        characteristicId: 2,
        severityRank: lowConfidenceSegments,
        observed:
            'O reconhecimento de voz teve dificuldade em $lowConfidenceSegments trechos — '
            'isso costuma indicar articulação fechada ou sílabas fundidas.',
        avoid:
            'Não murmure nem junte palavras — quem ouve precisa entender cada termo.',
        tryInstead: _charAction(2),
        beforeExample: '“prcism confiar” (palavras fundidas)',
        afterExample: '“Precisamos confiar.” (sílabas distintas)',
      ));
    }

    if (recentLongPauses >= VoiceAnalysisThresholds.longPausesPerMinuteWarning) {
      list.add(VoiceImprovementInsight(
        category: 'pausas',
        message: 'Muitas pausas longas ($recentLongPauses no último minuto)',
        suggestion: 'Trabalhe a fluência entre as ideias.',
        characteristicId: 5,
        severityRank: recentLongPauses,
        observed:
            'Foram detectadas $recentLongPauses pausas longas (4+ segundos) no último minuto.',
        avoid:
            'Não fique em silêncio prolongado sem motivo — quebra o ritmo e a atenção.',
        tryInstead:
            'Use pausas curtas e intencionais para destacar ideias; depois retome com segurança. '
            '${_charAction(5)}',
        beforeExample: '“A fé… [silêncio longo]… é importante…”',
        afterExample: '“A fé é importante.” [pausa] “Veja o exemplo.”',
      ));
    }

    if (structure != null) {
      list.addAll(_structureInsights(structure, topic));
    }

    list.sort((a, b) => b.severityRank.compareTo(a.severityRank));
    return list;
  }

  static List<VoiceImprovementInsight> _structureInsights(
    SpeechStructureAnalysis structure,
    String? topic,
  ) {
    final list = <VoiceImprovementInsight>[];

    final introFails = structure.introChecks
        .where((c) => c.status == RubricStatus.falta)
        .toList();
    if (introFails.isNotEmpty) {
      final missing = introFails.map((c) => c.label).join('; ');
      list.add(VoiceImprovementInsight(
        category: 'introducao',
        message: 'Introdução pode despertar mais interesse',
        suggestion:
            'Comece com pergunta instigante ou cenário real ligado ao tema.',
        characteristicId: 38,
        severityRank: introFails.length + 2,
        observed:
            'Na introdução faltou: $missing.${structure.intro.text.isNotEmpty ? " Trecho: «${_snippet(structure.intro.text)}»" : ''}',
        avoid:
            'Não comece direto no corpo do assunto sem captar a atenção.',
        tryInstead:
            'Nas primeiras frases, diga algo que prenda a atenção e mostre '
            'por que o assunto importa. ${_charAction(38)}',
        beforeExample: structure.intro.text.isNotEmpty
            ? structure.intro.text
            : '“Hoje vamos falar sobre o tema…” (genérico)',
        afterExample:
            '“Você já se sentiu ansioso com o futuro? Hoje veremos como a Bíblia ajuda.”',
      ));
    }

    final conclusionFails = structure.conclusionChecks
        .where((c) => c.status == RubricStatus.falta)
        .toList();
    if (conclusionFails.isNotEmpty) {
      final missing = conclusionFails.map((c) => c.label).join('; ');
      list.add(VoiceImprovementInsight(
        category: 'conclusao',
        message: 'Conclusão precisa de chamada à ação clara',
        suggestion:
            'Resuma os pontos e motive a assistência a agir com base no que ouviu.',
        characteristicId: 39,
        severityRank: conclusionFails.length + 2,
        observed:
            'Na conclusão faltou: $missing.${structure.conclusion.text.isNotEmpty ? " Trecho: «${_snippet(structure.conclusion.text)}»" : ''}',
        avoid:
            'Não termine abruptamente sem indicar o que fazer com a matéria.',
        tryInstead:
            'Nas frases finais, diga o que a assistência deve fazer e por quê. '
            '${_charAction(39)}',
        beforeExample: structure.conclusion.text.isNotEmpty
            ? structure.conclusion.text
            : '“…e é isso. Obrigado.” (sem encerramento)',
        afterExample:
            '“Portanto, confie em Jeová esta semana. O benefício será paz de espírito.”',
      ));
    }

    final timeIssues = structure.timeChecks
        .where((c) => c.status != RubricStatus.ok)
        .toList();
    if (timeIssues.isNotEmpty) {
      list.add(VoiceImprovementInsight(
        category: 'tempo',
        message: 'Distribuição de tempo pode melhorar',
        suggestion: 'Reserve 8–15% para intro e conclusão (be-T #51).',
        characteristicId: 51,
        severityRank: timeIssues.length + 1,
        observed: timeIssues.map((c) => c.label).join(' · '),
        avoid: 'Não estenda demais a introdução nem apresse a conclusão.',
        tryInstead: _charAction(51),
      ));
    }

    if (topic != null &&
        topic.trim().isNotEmpty &&
        structure.introScore >= 2 &&
        structure.conclusionScore >= 2) {
      list.add(VoiceImprovementInsight(
        category: 'introducao',
        message: 'Introdução e conclusão alinhadas ao tema',
        suggestion: 'Continue refinando o gancho inicial e a frase final.',
        characteristicId: 38,
        severityRank: 1,
        observed:
            'Tema “$topic”: intro ${structure.intro.pctOfTotal.toStringAsFixed(0)}%, '
            'conclusão ${structure.conclusion.pctOfTotal.toStringAsFixed(0)}%.',
        tryInstead: 'Para uma conclusão inesquecível, termine com uma frase '
            'motivadora que ligue o tema à ação prática.',
      ));
    }

    return list;
  }

  static String _snippet(String text) {
    if (text.length <= 90) return text;
    return '${text.substring(0, 87).trim()}…';
  }

  /// Trecho da transcrição ao redor de [keyword] (~80 chars).
  static String? extractSnippet(String transcript, String keyword) {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty || keyword.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    final key = keyword.toLowerCase();
    final index = lower.indexOf(key);
    if (index == -1) return null;

    const radius = 40;
    var start = index - radius;
    if (start < 0) start = 0;
    var end = index + key.length + radius;
    if (end > trimmed.length) end = trimmed.length;

    var snippet = trimmed.substring(start, end).trim();
    if (start > 0) snippet = '…$snippet';
    if (end < trimmed.length) snippet = '$snippet…';

    if (snippet.length > 90) {
      final cut = snippet.substring(0, 87);
      final lastSpace = cut.lastIndexOf(' ');
      snippet = lastSpace > 30
          ? '${cut.substring(0, lastSpace).trim()}…'
          : '$cut…';
    }
    return snippet;
  }

  static String _stripFillers(String text, Set<String> fillers) {
    var result = text;
    for (final filler in fillers) {
      result = result.replaceAll(
        RegExp('\\b${RegExp.escape(filler)}\\b', caseSensitive: false),
        '',
      );
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _repetitionAfterExample(
    String snippet,
    String word,
    String synonyms,
  ) {
    final firstSynonym = synonyms.split(',').first.trim();
    final pattern = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
  var replaced = false;
    return snippet.replaceAllMapped(pattern, (match) {
      if (replaced) return firstSynonym;
      replaced = true;
      return match.group(0)!;
    });
  }

  static String _charAction(int id) {
    final action =
        CharacteristicsService.instance.getCharacteristicById(id)?.action;
    if (action == null || action.isEmpty) {
      return 'Consulte a característica be-T #$id para orientação completa.';
    }
    if (action.length > 160) {
      return '${action.substring(0, 157).trim()}…';
    }
    return action;
  }
}

import 'dart:math';

import 'package:flutter/foundation.dart';

/// Metas padrão de proporção intro/corpo/conclusão (be-T #51).
class SpeechTimeDefaults {
  static const introPctMin = 8;
  static const introPctMax = 15;
  static const conclusionPctMin = 8;
  static const conclusionPctMax = 15;
}

enum RubricStatus { ok, atencao, falta }

@immutable
class RubricCheckItem {
  final String id;
  final String label;
  final RubricStatus status;
  final String? detail;

  const RubricCheckItem({
    required this.id,
    required this.label,
    required this.status,
    this.detail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'status': status.name,
        if (detail != null) 'detail': detail,
      };

  factory RubricCheckItem.fromJson(Map<String, dynamic> json) {
    final statusName = json['status']?.toString() ?? 'falta';
    return RubricCheckItem(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      status: RubricStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => RubricStatus.falta,
      ),
      detail: json['detail']?.toString(),
    );
  }
}

@immutable
class SpeechSegment {
  final String text;
  final int estimatedDurationSeconds;
  final double pctOfTotal;

  const SpeechSegment({
    required this.text,
    this.estimatedDurationSeconds = 0,
    this.pctOfTotal = 0,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'estimatedDurationSeconds': estimatedDurationSeconds,
        'pctOfTotal': pctOfTotal,
      };

  factory SpeechSegment.fromJson(Map<String, dynamic> json) {
    return SpeechSegment(
      text: json['text']?.toString() ?? '',
      estimatedDurationSeconds:
          json['estimatedDurationSeconds'] as int? ?? 0,
      pctOfTotal: (json['pctOfTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

@immutable
class SpeechStructureAnalysis {
  final SpeechSegment intro;
  final SpeechSegment body;
  final SpeechSegment conclusion;
  final List<RubricCheckItem> introChecks;
  final List<RubricCheckItem> conclusionChecks;
  final List<RubricCheckItem> timeChecks;
  final int introScore;
  final int conclusionScore;
  final int timeScore;

  const SpeechStructureAnalysis({
    required this.intro,
    required this.body,
    required this.conclusion,
    this.introChecks = const [],
    this.conclusionChecks = const [],
    this.timeChecks = const [],
    this.introScore = 2,
    this.conclusionScore = 2,
    this.timeScore = 2,
  });

  Map<String, dynamic> toJson() => {
        'intro': intro.toJson(),
        'body': body.toJson(),
        'conclusion': conclusion.toJson(),
        'introChecks': introChecks.map((c) => c.toJson()).toList(),
        'conclusionChecks': conclusionChecks.map((c) => c.toJson()).toList(),
        'timeChecks': timeChecks.map((c) => c.toJson()).toList(),
        'introScore': introScore,
        'conclusionScore': conclusionScore,
        'timeScore': timeScore,
      };

  factory SpeechStructureAnalysis.fromJson(Map<String, dynamic> json) {
    return SpeechStructureAnalysis(
      intro: SpeechSegment.fromJson(
        json['intro'] as Map<String, dynamic>? ?? {},
      ),
      body: SpeechSegment.fromJson(
        json['body'] as Map<String, dynamic>? ?? {},
      ),
      conclusion: SpeechSegment.fromJson(
        json['conclusion'] as Map<String, dynamic>? ?? {},
      ),
      introChecks: (json['introChecks'] as List?)
              ?.map((c) => RubricCheckItem.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      conclusionChecks: (json['conclusionChecks'] as List?)
              ?.map((c) => RubricCheckItem.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      timeChecks: (json['timeChecks'] as List?)
              ?.map((c) => RubricCheckItem.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      introScore: json['introScore'] as int? ?? 2,
      conclusionScore: json['conclusionScore'] as int? ?? 2,
      timeScore: json['timeScore'] as int? ?? 2,
    );
  }
}

/// Segmenta discurso e avalia intro/conclusão com heurísticas be-T #38/#39/#51.
class VoiceSpeechStructureAnalyzer {
  static const _introPct = 0.12;
  static const _conclusionPct = 0.12;

  static const _attentionHooks = [
    'imagine',
    'hoje',
    'muitas pessoas',
    'você já',
    'será que',
    'já pensou',
    'alguma vez',
    'recentemente',
    'notícia',
  ];

  static const _relevanceWords = [
    'importante',
    'benefício',
    'beneficio',
    'ajuda',
    'ajudará',
    'ajudara',
    'relevante',
    'necessário',
    'necessario',
    'precisamos',
    'proveito',
    'valor',
  ];

  static const _summaryMarkers = [
    'portanto',
    'assim',
    'resumindo',
    'em conclusão',
    'em conclusao',
    'concluindo',
    'vemos então',
    'vemos entao',
    'recapitulando',
    'em suma',
  ];

  static const _actionVerbs = [
    'faça',
    'faca',
    'aplique',
    'decida',
    'comece',
    'tome',
    'busque',
    'esforce',
    'dedique',
    'confie',
    'ore',
    'medite',
    'leia',
    'visite',
    'participe',
    'ajude',
    'mude',
    'mude',
    'escolha',
    'priorize',
  ];

  static const _motivationWords = [
    'benefício',
    'beneficio',
    'esperança',
    'esperanca',
    'motivo',
    'razão',
    'razao',
    'recompensa',
    'bênção',
    'bencao',
    'alegria',
    'paz',
    'vida',
    'futuro',
    'paraíso',
    'paraiso',
  ];

  static SpeechStructureAnalysis analyze({
    required String transcript,
    required int totalDurationSeconds,
    String? topic,
    double? endingAmplitudeVariance,
  }) {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty || totalDurationSeconds <= 0) {
      return const SpeechStructureAnalysis(
        intro: SpeechSegment(text: ''),
        body: SpeechSegment(text: ''),
        conclusion: SpeechSegment(text: ''),
      );
    }

    final words = _tokenize(trimmed);
    final totalWords = words.length;
    if (totalWords < 10) {
      return SpeechStructureAnalysis(
        intro: SpeechSegment(text: trimmed, pctOfTotal: 100),
        body: const SpeechSegment(text: ''),
        conclusion: const SpeechSegment(text: ''),
        introChecks: const [
          RubricCheckItem(
            id: 'discurso_curto',
            label: 'Discurso muito curto para analisar estrutura',
            status: RubricStatus.atencao,
          ),
        ],
      );
    }

    final introWordCount = max(3, (totalWords * _introPct).round());
    final conclusionWordCount = max(3, (totalWords * _conclusionPct).round());
    final bodyStart = introWordCount;
    final bodyEnd = max(bodyStart, totalWords - conclusionWordCount);

    final introText = words.take(introWordCount).join(' ');
    final bodyText = words.sublist(bodyStart, bodyEnd).join(' ');
    final conclusionText = words.sublist(bodyEnd).join(' ');

    final introSec = _estimateSeconds(introWordCount, totalWords, totalDurationSeconds);
    final bodySec = _estimateSeconds(bodyEnd - bodyStart, totalWords, totalDurationSeconds);
    final conclusionSec =
        _estimateSeconds(totalWords - bodyEnd, totalWords, totalDurationSeconds);

    final introPct = introSec / totalDurationSeconds * 100;
    final conclusionPct = conclusionSec / totalDurationSeconds * 100;

    final introChecks = _analyzeIntro(introText, topic);
    final conclusionChecks =
        _analyzeConclusion(conclusionText, topic, endingAmplitudeVariance);
    final timeChecks = _analyzeTime(introPct, conclusionPct);

    return SpeechStructureAnalysis(
      intro: SpeechSegment(
        text: introText,
        estimatedDurationSeconds: introSec,
        pctOfTotal: introPct,
      ),
      body: SpeechSegment(
        text: bodyText,
        estimatedDurationSeconds: bodySec,
        pctOfTotal: 100 - introPct - conclusionPct,
      ),
      conclusion: SpeechSegment(
        text: conclusionText,
        estimatedDurationSeconds: conclusionSec,
        pctOfTotal: conclusionPct,
      ),
      introChecks: introChecks,
      conclusionChecks: conclusionChecks,
      timeChecks: timeChecks,
      introScore: _scoreFromChecks(introChecks),
      conclusionScore: _scoreFromChecks(conclusionChecks),
      timeScore: _scoreFromChecks(timeChecks),
    );
  }

  /// Fase atual estimada com base no tempo decorrido.
  static SpeechPhase currentPhase({
    required int elapsedSeconds,
    required int totalDurationSeconds,
  }) {
    if (totalDurationSeconds <= 0) return SpeechPhase.intro;
    final ratio = elapsedSeconds / totalDurationSeconds;
    if (ratio < _introPct + 0.03) return SpeechPhase.intro;
    if (ratio > 1 - _conclusionPct - 0.03) return SpeechPhase.conclusion;
    return SpeechPhase.body;
  }

  static SpeechPhase currentPhaseByElapsedOnly(int elapsedSeconds) {
    if (elapsedSeconds < 60) return SpeechPhase.intro;
    if (elapsedSeconds % 600 > 480) return SpeechPhase.conclusion;
    return SpeechPhase.body;
  }

  static List<RubricCheckItem> _analyzeIntro(String text, String? topic) {
    final lower = text.toLowerCase();
    final checks = <RubricCheckItem>[];

    final hasQuestion = text.contains('?') ||
        RegExp(r'\b(por que|porque|como|quem|qual|quando|será|sera)\b',
                caseSensitive: false)
            .hasMatch(lower);
    checks.add(RubricCheckItem(
      id: 'pergunta_instigante',
      label: 'Pergunta ou gancho instigante',
      status: hasQuestion || _containsAny(lower, _attentionHooks)
          ? RubricStatus.ok
          : RubricStatus.falta,
      detail: hasQuestion
          ? 'Pergunta detectada na introdução.'
          : 'Tente abrir com uma pergunta que estimule o raciocínio.',
    ));

    checks.add(RubricCheckItem(
      id: 'captar_atencao',
      label: 'Captar a atenção',
      status: _containsAny(lower, _attentionHooks) || hasQuestion
          ? RubricStatus.ok
          : RubricStatus.atencao,
    ));

    final themeMentioned = topic != null &&
        topic.trim().isNotEmpty &&
        _topicMentioned(lower, topic);
    checks.add(RubricCheckItem(
      id: 'identificar_assunto',
      label: 'Identificar o assunto',
      status: themeMentioned || lower.contains('tema') || lower.contains('assunto')
          ? RubricStatus.ok
          : RubricStatus.atencao,
      detail: themeMentioned
          ? 'Tema mencionado na introdução.'
          : 'Mencione o tema nas primeiras frases.',
    ));

    checks.add(RubricCheckItem(
      id: 'mostrar_relevancia',
      label: 'Mostrar relevância para os ouvintes',
      status: _containsAny(lower, _relevanceWords)
          ? RubricStatus.ok
          : RubricStatus.falta,
      detail: 'Mostre como o assunto beneficia a vida de quem ouve.',
    ));

    final hasScenario = RegExp(
      r'\b(exemplo|história|historia|caso|situação|situacao|lembra|aconteceu)\b',
      caseSensitive: false,
    ).hasMatch(lower);
    checks.add(RubricCheckItem(
      id: 'caso_vida_real',
      label: 'Caso da vida real ou cenário',
      status: hasScenario ? RubricStatus.ok : RubricStatus.atencao,
    ));

    return checks;
  }

  static List<RubricCheckItem> _analyzeConclusion(
    String text,
    String? topic,
    double? endingAmplitudeVariance,
  ) {
    if (text.trim().isEmpty) {
      return const [
        RubricCheckItem(
          id: 'conclusao_ausente',
          label: 'Conclusão identificável',
          status: RubricStatus.falta,
          detail: 'Não foi possível identificar um encerramento distinto.',
        ),
      ];
    }

    final lower = text.toLowerCase();
    final checks = <RubricCheckItem>[];

    checks.add(RubricCheckItem(
      id: 'resumir_pontos',
      label: 'Resumir os pontos principais',
      status: _containsAny(lower, _summaryMarkers) ||
              RegExp(r'\b(principal|pontos|vimos|aprendemos)\b',
                      caseSensitive: false)
                  .hasMatch(lower)
          ? RubricStatus.ok
          : RubricStatus.atencao,
    ));

    final hasAction = _containsAny(lower, _actionVerbs) ||
        RegExp(r'\bdeve\b|\bprecisa\b|\bvamos\b', caseSensitive: false)
            .hasMatch(lower);
    checks.add(RubricCheckItem(
      id: 'chamada_acao',
      label: 'Chamada à ação',
      status: hasAction ? RubricStatus.ok : RubricStatus.falta,
      detail: hasAction
          ? null
          : 'Indique claramente o que a assistência deve fazer.',
    ));

    checks.add(RubricCheckItem(
      id: 'motivar',
      label: 'Motivar com razões ou benefícios',
      status: _containsAny(lower, _motivationWords)
          ? RubricStatus.ok
          : RubricStatus.atencao,
    ));

    final themeRepeated = topic != null &&
        topic.trim().isNotEmpty &&
        _topicMentioned(lower, topic);
    checks.add(RubricCheckItem(
      id: 'relacionar_tema',
      label: 'Relacionar-se ao tema',
      status: themeRepeated || _containsAny(lower, _summaryMarkers)
          ? RubricStatus.ok
          : RubricStatus.atencao,
    ));

    final lastSentence = text.split(RegExp(r'[.!?…]')).where((s) => s.trim().isNotEmpty).lastOrNull ?? text;
    checks.add(RubricCheckItem(
      id: 'frase_final',
      label: 'Frase final marcante',
      status: lastSentence.trim().split(RegExp(r'\s+')).length >= 4
          ? RubricStatus.ok
          : RubricStatus.atencao,
      detail: 'Termine com uma sentença clara e bem fraseada.',
    ));

    final tomOk = endingAmplitudeVariance == null ||
        endingAmplitudeVariance >= 1.5;
    checks.add(RubricCheckItem(
      id: 'tom_encerramento',
      label: 'Tom de finalização',
      status: tomOk ? RubricStatus.ok : RubricStatus.atencao,
      detail: tomOk
          ? null
          : 'Evite baixar o volume até desaparecer no final.',
    ));

    return checks;
  }

  static List<RubricCheckItem> _analyzeTime(double introPct, double conclusionPct) {
    RubricStatus introStatus;
    if (introPct >= SpeechTimeDefaults.introPctMin &&
        introPct <= SpeechTimeDefaults.introPctMax) {
      introStatus = RubricStatus.ok;
    } else if (introPct < SpeechTimeDefaults.introPctMin) {
      introStatus = RubricStatus.atencao;
    } else {
      introStatus = RubricStatus.falta;
    }

    RubricStatus conclusionStatus;
    if (conclusionPct >= SpeechTimeDefaults.conclusionPctMin &&
        conclusionPct <= SpeechTimeDefaults.conclusionPctMax) {
      conclusionStatus = RubricStatus.ok;
    } else if (conclusionPct < SpeechTimeDefaults.conclusionPctMin) {
      conclusionStatus = RubricStatus.falta;
    } else {
      conclusionStatus = RubricStatus.atencao;
    }

    return [
      RubricCheckItem(
        id: 'proporcao_intro',
        label: 'Proporção da introdução (${introPct.toStringAsFixed(0)}%)',
        status: introStatus,
        detail:
            'Ideal: ${SpeechTimeDefaults.introPctMin}–${SpeechTimeDefaults.introPctMax}%.',
      ),
      RubricCheckItem(
        id: 'proporcao_conclusao',
        label: 'Proporção da conclusão (${conclusionPct.toStringAsFixed(0)}%)',
        status: conclusionStatus,
        detail:
            'Ideal: ${SpeechTimeDefaults.conclusionPctMin}–${SpeechTimeDefaults.conclusionPctMax}%.',
      ),
    ];
  }

  static int _scoreFromChecks(List<RubricCheckItem> checks) {
    if (checks.isEmpty) return 2;
    var ok = 0;
    var falta = 0;
    for (final c in checks) {
      switch (c.status) {
        case RubricStatus.ok:
          ok++;
        case RubricStatus.falta:
          falta++;
        case RubricStatus.atencao:
          break;
      }
    }
    if (falta >= 2) return 0;
    if (falta == 1) return 1;
    if (ok >= checks.length * 0.6) return 3;
    if (ok >= checks.length * 0.35) return 2;
    return 1;
  }

  static int _estimateSeconds(int segmentWords, int totalWords, int totalSec) {
    if (totalWords == 0) return 0;
    return max(1, (segmentWords / totalWords * totalSec).round());
  }

  static bool _containsAny(String text, List<String> needles) {
    for (final n in needles) {
      if (text.contains(n)) return true;
    }
    return false;
  }

  static bool _topicMentioned(String text, String topic) {
    final topicWords = _tokenize(topic);
    if (topicWords.isEmpty) return false;
    final significant = topicWords.where((w) => w.length > 3).toList();
    if (significant.isEmpty) return text.contains(topic.toLowerCase());
    final matches = significant.where((w) => text.contains(w)).length;
    return matches >= max(1, (significant.length * 0.4).ceil());
  }

  static List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }
}

enum SpeechPhase { intro, body, conclusion }

extension SpeechPhaseLabel on SpeechPhase {
  String get label {
    switch (this) {
      case SpeechPhase.intro:
        return 'Introdução';
      case SpeechPhase.body:
        return 'Corpo';
      case SpeechPhase.conclusion:
        return 'Conclusão';
    }
  }
}

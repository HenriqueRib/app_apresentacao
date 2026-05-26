import 'package:flutter/foundation.dart';

enum S315AspectStatus { ok, atencao, falta }

@immutable
class S315AspectNote {
  final String label;
  final S315AspectStatus status;
  final String? detail;

  const S315AspectNote({
    required this.label,
    required this.status,
    this.detail,
  });
}

@immutable
class S315SpeakerFeedback {
  final String disGrade;
  final String entGrade;
  final String habilidadeOrador;
  final String personalidade;
  final List<S315AspectNote> aspectNotes;
  final String disclaimer;
  final bool hasSufficientData;

  const S315SpeakerFeedback({
    required this.disGrade,
    this.entGrade = 'NR',
    required this.habilidadeOrador,
    required this.personalidade,
    this.aspectNotes = const [],
    this.disclaimer =
        'Rascunho auxiliar inspirado nas orientações S-315. '
        'Não substitui a avaliação do corpo de anciãos.',
    this.hasSufficientData = true,
  });
}

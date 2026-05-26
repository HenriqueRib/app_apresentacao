import 'package:flutter/foundation.dart';

import 's315_speaker_feedback.dart';

@immutable
class VoiceRehearsalOnlineCharacteristic {
  final int id;
  final String? titulo;
  final String nota;
  final String? evidencia;
  final String? sugestao;

  const VoiceRehearsalOnlineCharacteristic({
    required this.id,
    this.titulo,
    required this.nota,
    this.evidencia,
    this.sugestao,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (titulo != null) 'titulo': titulo,
        'nota': nota,
        if (evidencia != null) 'evidencia': evidencia,
        if (sugestao != null) 'sugestao': sugestao,
      };

  factory VoiceRehearsalOnlineCharacteristic.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalOnlineCharacteristic(
      id: json['id'] as int? ?? 0,
      titulo: json['titulo']?.toString(),
      nota: json['nota']?.toString() ?? 'NR',
      evidencia: json['evidencia']?.toString(),
      sugestao: json['sugestao']?.toString(),
    );
  }
}

@immutable
class VoiceRehearsalOnlineStructureComment {
  final String secao;
  final String status;
  final String comentario;

  const VoiceRehearsalOnlineStructureComment({
    required this.secao,
    required this.status,
    required this.comentario,
  });

  Map<String, dynamic> toJson() => {
        'secao': secao,
        'status': status,
        'comentario': comentario,
      };

  factory VoiceRehearsalOnlineStructureComment.fromJson(
    Map<String, dynamic> json,
  ) {
    return VoiceRehearsalOnlineStructureComment(
      secao: json['secao']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ok',
      comentario: json['comentario']?.toString() ?? '',
    );
  }
}

@immutable
class VoiceRehearsalOnlineS315Enriched {
  final String habilidadeOrador;
  final String personalidade;
  final List<S315AspectNote> aspectos;

  const VoiceRehearsalOnlineS315Enriched({
    required this.habilidadeOrador,
    required this.personalidade,
    this.aspectos = const [],
  });

  Map<String, dynamic> toJson() => {
        'habilidade_orador': habilidadeOrador,
        'personalidade': personalidade,
        'aspectos': aspectos
            .map(
              (a) => {
                'label': a.label,
                'status': a.status.name,
                if (a.detail != null) 'detail': a.detail,
              },
            )
            .toList(),
      };

  factory VoiceRehearsalOnlineS315Enriched.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalOnlineS315Enriched(
      habilidadeOrador: json['habilidade_orador']?.toString() ?? '',
      personalidade: json['personalidade']?.toString() ?? '',
      aspectos: (json['aspectos'] as List?)
              ?.map((a) {
                final map = a as Map<String, dynamic>;
                return S315AspectNote(
                  label: map['label']?.toString() ?? '',
                  status: S315AspectStatus.values.firstWhere(
                    (s) => s.name == map['status']?.toString(),
                    orElse: () => S315AspectStatus.atencao,
                  ),
                  detail: map['detail']?.toString(),
                );
              })
              .toList() ??
          const [],
    );
  }
}

@immutable
class VoiceRehearsalOnlineAnalysis {
  final DateTime analyzedAt;
  final List<String> pontosFortes;
  final List<String> pontosMelhorar;
  final List<String> proximosPassos;
  final List<VoiceRehearsalOnlineCharacteristic> caracteristicasBeT;
  final List<VoiceRehearsalOnlineStructureComment> estruturaComentarios;
  final VoiceRehearsalOnlineS315Enriched? s315Enriquecido;
  final String disclaimer;
  final String? backendVersion;

  const VoiceRehearsalOnlineAnalysis({
    required this.analyzedAt,
    this.pontosFortes = const [],
    this.pontosMelhorar = const [],
    this.proximosPassos = const [],
    this.caracteristicasBeT = const [],
    this.estruturaComentarios = const [],
    this.s315Enriquecido,
    this.disclaimer =
        'Análise online auxiliar. Não substitui orientação do corpo de anciãos.',
    this.backendVersion,
  });

  Map<String, dynamic> toJson() => {
        'analyzedAt': analyzedAt.toIso8601String(),
        'pontosFortes': pontosFortes,
        'pontosMelhorar': pontosMelhorar,
        'proximosPassos': proximosPassos,
        'caracteristicasBeT':
            caracteristicasBeT.map((c) => c.toJson()).toList(),
        'estruturaComentarios':
            estruturaComentarios.map((c) => c.toJson()).toList(),
        if (s315Enriquecido != null) 's315Enriquecido': s315Enriquecido!.toJson(),
        'disclaimer': disclaimer,
        if (backendVersion != null) 'backendVersion': backendVersion,
      };

  factory VoiceRehearsalOnlineAnalysis.fromJson(Map<String, dynamic> json) {
    return VoiceRehearsalOnlineAnalysis(
      analyzedAt: DateTime.tryParse(json['analyzedAt']?.toString() ?? '') ??
          DateTime.now(),
      pontosFortes: (json['pontosFortes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      pontosMelhorar: (json['pontosMelhorar'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      proximosPassos: (json['proximosPassos'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      caracteristicasBeT: (json['caracteristicasBeT'] as List?)
              ?.map(
                (c) => VoiceRehearsalOnlineCharacteristic.fromJson(
                  c as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      estruturaComentarios: (json['estruturaComentarios'] as List?)
              ?.map(
                (c) => VoiceRehearsalOnlineStructureComment.fromJson(
                  c as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      s315Enriquecido: json['s315Enriquecido'] is Map
          ? VoiceRehearsalOnlineS315Enriched.fromJson(
              Map<String, dynamic>.from(json['s315Enriquecido'] as Map),
            )
          : null,
      disclaimer: json['disclaimer']?.toString() ??
          'Análise online auxiliar. Não substitui orientação do corpo de anciãos.',
      backendVersion: json['backendVersion']?.toString(),
    );
  }

  /// Parse da resposta HTTP do backend (`data` já desembrulhado).
  factory VoiceRehearsalOnlineAnalysis.fromApiResponse(
    Map<String, dynamic> data,
  ) {
    final s315Raw = data['s315_enriquecido'];
  final estruturaRaw = data['estrutura'] ?? data['estrutura_comentarios'];
    final feedbackRaw = data['feedback_be_t'] ?? data['caracteristicas_be_t'];

    List<VoiceRehearsalOnlineStructureComment> estrutura = const [];
    if (estruturaRaw is List) {
      estrutura = estruturaRaw
          .map(
            (c) => VoiceRehearsalOnlineStructureComment.fromJson(
              Map<String, dynamic>.from(c as Map),
            ),
          )
          .toList();
    } else if (estruturaRaw is Map) {
      estrutura = estruturaRaw.entries
          .where((e) => e.value is Map || e.value is String)
          .map((e) {
            if (e.value is String) {
              return VoiceRehearsalOnlineStructureComment(
                secao: e.key.toString(),
                status: 'ok',
                comentario: e.value as String,
              );
            }
            final map = Map<String, dynamic>.from(e.value as Map);
            return VoiceRehearsalOnlineStructureComment(
              secao: e.key.toString(),
              status: map['status']?.toString() ?? 'ok',
              comentario: map['comentario']?.toString() ??
                  map['observacao']?.toString() ??
                  '',
            );
          })
          .toList();
    }

    List<VoiceRehearsalOnlineCharacteristic> caracteristicas = const [];
    if (feedbackRaw is List) {
      caracteristicas = feedbackRaw
          .map(
            (c) => VoiceRehearsalOnlineCharacteristic.fromJson(
              Map<String, dynamic>.from(c as Map),
            ),
          )
          .toList();
    }

    VoiceRehearsalOnlineS315Enriched? s315;
    if (s315Raw is Map) {
      s315 = VoiceRehearsalOnlineS315Enriched.fromJson(
        Map<String, dynamic>.from(s315Raw),
      );
    }

    return VoiceRehearsalOnlineAnalysis(
      analyzedAt: DateTime.now(),
      pontosFortes: _stringList(data['pontos_fortes'] ?? data['pontosFortes']),
      pontosMelhorar:
          _stringList(data['pontos_melhorar'] ?? data['pontosMelhorar']),
      proximosPassos:
          _stringList(data['proximos_passos'] ?? data['proximosPassos']),
      caracteristicasBeT: caracteristicas,
      estruturaComentarios: estrutura,
      s315Enriquecido: s315,
      disclaimer: data['disclaimer']?.toString() ??
          'Análise online auxiliar. Não substitui orientação do corpo de anciãos.',
      backendVersion: data['backend_version']?.toString() ??
          data['backendVersion']?.toString(),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }
}

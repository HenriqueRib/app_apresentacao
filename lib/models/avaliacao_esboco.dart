import 'package:flutter/foundation.dart';

/// Resposta de `POST /api/v1/avaliar/esboco`.
///
/// Contrato: [doc/mobile/contrato-json-backend-flutter.md]
@immutable
class AvaliacaoEsbocoResponse {
  final String notaGeral;
  final String passoShinyashiki;
  final bool objetivoClaro;
  final ProporcaoTempo? proporcaoTempo;
  final EstruturaBet? estruturaBet;
  final List<LeiaAvaliacao> leia;
  final List<PilarShinyashiki> pilaresShinyashiki;
  final List<CaracteristicaBetAvaliacao> caracteristicasBet;
  final List<String> pontosFortes;
  final List<String> pontosMelhorar;
  final List<String> proximosPassos;
  final String? persistidoId;

  const AvaliacaoEsbocoResponse({
    required this.notaGeral,
    this.passoShinyashiki = 'preparar',
    this.objetivoClaro = false,
    this.proporcaoTempo,
    this.estruturaBet,
    this.leia = const [],
    this.pilaresShinyashiki = const [],
    this.caracteristicasBet = const [],
    this.pontosFortes = const [],
    this.pontosMelhorar = const [],
    this.proximosPassos = const [],
    this.persistidoId,
  });

  factory AvaliacaoEsbocoResponse.fromJson(Map<String, dynamic> json) {
    return AvaliacaoEsbocoResponse(
      notaGeral: (json['nota_geral'] ?? 'NR').toString(),
      passoShinyashiki: (json['passo_shinyashiki'] ?? 'preparar').toString(),
      objetivoClaro: json['objetivo_claro'] == true,
      proporcaoTempo: json['proporcao_tempo'] is Map
          ? ProporcaoTempo.fromJson(
              Map<String, dynamic>.from(json['proporcao_tempo'] as Map))
          : null,
      estruturaBet: json['estrutura_bet'] is Map
          ? EstruturaBet.fromJson(
              Map<String, dynamic>.from(json['estrutura_bet'] as Map))
          : null,
      leia: (json['leia'] as List?)
              ?.map((e) =>
                  LeiaAvaliacao.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pilaresShinyashiki: (json['pilares_shinyashiki'] as List?)
              ?.map((e) => PilarShinyashiki.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      caracteristicasBet: (json['caracteristicas_be_t'] as List?)
              ?.map((e) => CaracteristicaBetAvaliacao.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pontosFortes: List<String>.from(json['pontos_fortes'] ?? []),
      pontosMelhorar: List<String>.from(json['pontos_melhorar'] ?? []),
      proximosPassos: List<String>.from(json['proximos_passos'] ?? []),
      persistidoId: json['persistido_id']?.toString(),
    );
  }
}

@immutable
class ProporcaoTempo {
  final int introducaoPct;
  final int corpoPct;
  final int conclusaoPct;
  final bool dentroDoIdeal;
  final String comentario;

  const ProporcaoTempo({
    this.introducaoPct = 0,
    this.corpoPct = 0,
    this.conclusaoPct = 0,
    this.dentroDoIdeal = false,
    this.comentario = '',
  });

  factory ProporcaoTempo.fromJson(Map<String, dynamic> json) {
    return ProporcaoTempo(
      introducaoPct: (json['introducao_pct'] ?? 0) as int,
      corpoPct: (json['corpo_pct'] ?? 0) as int,
      conclusaoPct: (json['conclusao_pct'] ?? 0) as int,
      dentroDoIdeal: json['dentro_do_ideal_10min'] == true,
      comentario: (json['comentario'] ?? '').toString(),
    );
  }
}

@immutable
class EstruturaBet {
  final SecaoStatus introducao;
  final CorpoStatus corpo;
  final SecaoStatus conclusao;

  const EstruturaBet({
    this.introducao = const SecaoStatus(),
    this.corpo = const CorpoStatus(),
    this.conclusao = const SecaoStatus(),
  });

  factory EstruturaBet.fromJson(Map<String, dynamic> json) {
    return EstruturaBet(
      introducao: json['introducao'] is Map
          ? SecaoStatus.fromJson(
              Map<String, dynamic>.from(json['introducao'] as Map))
          : const SecaoStatus(),
      corpo: json['corpo'] is Map
          ? CorpoStatus.fromJson(
              Map<String, dynamic>.from(json['corpo'] as Map))
          : const CorpoStatus(),
      conclusao: json['conclusao'] is Map
          ? SecaoStatus.fromJson(
              Map<String, dynamic>.from(json['conclusao'] as Map))
          : const SecaoStatus(),
    );
  }
}

@immutable
class SecaoStatus {
  final String status;
  final List<String> itens;
  final bool? chamaAcao;

  const SecaoStatus({
    this.status = 'ok',
    this.itens = const [],
    this.chamaAcao,
  });

  factory SecaoStatus.fromJson(Map<String, dynamic> json) {
    return SecaoStatus(
      status: (json['status'] ?? 'ok').toString(),
      itens: List<String>.from(json['itens'] ?? []),
      chamaAcao: json['chama_acao'] as bool?,
    );
  }
}

@immutable
class CorpoStatus {
  final String status;
  final String transicoes;
  final List<dynamic> pontos;

  const CorpoStatus({
    this.status = 'ok',
    this.transicoes = 'ok',
    this.pontos = const [],
  });

  factory CorpoStatus.fromJson(Map<String, dynamic> json) {
    return CorpoStatus(
      status: (json['status'] ?? 'ok').toString(),
      transicoes: (json['transicoes'] ?? 'ok').toString(),
      pontos: json['pontos'] as List? ?? const [],
    );
  }
}

@immutable
class LeiaAvaliacao {
  final String referencia;
  final bool completo;
  final List<String> faltando;
  final String sugestao;

  const LeiaAvaliacao({
    required this.referencia,
    this.completo = false,
    this.faltando = const [],
    this.sugestao = '',
  });

  factory LeiaAvaliacao.fromJson(Map<String, dynamic> json) {
    return LeiaAvaliacao(
      referencia: (json['referencia'] ?? '').toString(),
      completo: json['completo'] == true,
      faltando: List<String>.from(json['faltando'] ?? []),
      sugestao: (json['sugestao'] ?? '').toString(),
    );
  }
}

@immutable
class PilarShinyashiki {
  final String id;
  final String nota;
  final String observacao;

  const PilarShinyashiki({
    required this.id,
    this.nota = 'NR',
    this.observacao = '',
  });

  factory PilarShinyashiki.fromJson(Map<String, dynamic> json) {
    return PilarShinyashiki(
      id: (json['id'] ?? '').toString(),
      nota: (json['nota'] ?? 'NR').toString(),
      observacao: (json['observacao'] ?? '').toString(),
    );
  }
}

@immutable
class CaracteristicaBetAvaliacao {
  final int id;
  final String titulo;
  final String nota;
  final String evidencia;
  final String sugestao;

  const CaracteristicaBetAvaliacao({
    required this.id,
    this.titulo = '',
    this.nota = 'NR',
    this.evidencia = '',
    this.sugestao = '',
  });

  factory CaracteristicaBetAvaliacao.fromJson(Map<String, dynamic> json) {
    return CaracteristicaBetAvaliacao(
      id: (json['id'] ?? 0) as int,
      titulo: (json['titulo'] ?? '').toString(),
      nota: (json['nota'] ?? 'NR').toString(),
      evidencia: (json['evidencia'] ?? '').toString(),
      sugestao: (json['sugestao'] ?? '').toString(),
    );
  }
}

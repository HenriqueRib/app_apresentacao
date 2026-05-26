import 'dart:convert';

import '../core/constants/api_routes.dart';
import '../core/utils/api_http_helper.dart';
import '../core/utils/api_json_helpers.dart';
import '../models/voice_rehearsal_online_analysis.dart';

/// Service para rotas de ensino (P1): Ensaio, Aprimorar, Estudo guiado.
///
/// Rotas do backend:
///   - POST /v1/ensaio/registrar
///   - GET  /v1/ensaio/metas-tempo
///   - POST /v1/ensaio/analisar
///   - POST /v1/aprimorar/feedback
///   - POST /v1/estudo/pesquisa
///   - POST /v1/estudo/meditacao
///   - POST /v1/estudo/memorizar
///   - GET  /v1/estudo/progresso/{discurso_id}
class EnsinoApi {
  static const Duration _timeout = Duration(seconds: 60);
  static const Duration _analysisTimeout = Duration(seconds: 90);

  // ==========================================
  // ENSAIO
  // ==========================================

  /// Registra uma sessão de ensaio.
  Future<Map<String, dynamic>> registrarEnsaio({
    String? discursoId,
    String? parteId,
    required String tipo,
    required int duracaoSegundos,
    int metaMinutos = 10,
    int? nivelEnergia,
    Map<String, bool>? checklistPalco,
    String? notas,
    String? audioUrl,
  }) async {
    final body = <String, dynamic>{
      'tipo': tipo,
      'duracao_segundos': duracaoSegundos,
      'meta_minutos': metaMinutos,
      if (discursoId != null) 'discurso_id': discursoId,
      if (parteId != null) 'parte_id': parteId,
      if (nivelEnergia != null) 'nivel_energia': nivelEnergia,
      if (checklistPalco != null) 'checklist_palco': checklistPalco,
      if (notas != null) 'notas': notas,
      if (audioUrl != null) 'audio_url': audioUrl,
    };

    final response = await ApiHttpHelper.post(
      ApiRoutes.ensaioRegistrar,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao registrar ensaio: ${response.statusCode}');
  }

  /// Retorna metas de tempo recomendadas (intro/corpo/conclusao em minutos).
  Future<MetasTempo> getMetasTempo({String tipo = 'parte_10min'}) async {
    final response = await ApiHttpHelper.get(
      '${ApiRoutes.ensaioMetasTempo}?tipo=$tipo',
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = unwrapData(decoded);
      return MetasTempo.fromJson(data);
    }
    throw Exception('Falha ao obter metas de tempo: ${response.statusCode}');
  }

  /// Análise online pós-ensaio (transcrição + métricas locais).
  Future<VoiceRehearsalOnlineAnalysis> analisarEnsaioOnline(
    Map<String, dynamic> body,
  ) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.ensaioAnalisar,
      body: jsonEncode(body),
      timeout: _analysisTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = unwrapData(decoded);
      return VoiceRehearsalOnlineAnalysis.fromApiResponse(data);
    }
    if (response.statusCode == 400 || response.statusCode == 422) {
      throw Exception(
        'Dados insuficientes para análise online (${response.statusCode}).',
      );
    }
    throw Exception('Falha na análise online: ${response.statusCode}');
  }

  // ==========================================
  // APRIMORAR / FEEDBACK
  // ==========================================

  /// Envia autoavaliação pós-apresentação.
  Future<Map<String, dynamic>> enviarFeedback({
    String? discursoId,
    String? parteId,
    required bool objetivoAlcancado,
    int engajamentoAudiencia = 3,
    List<Map<String, dynamic>>? competencias,
    List<int>? caracteristicasIds,
    String? pontosFortes,
    String? pontosMelhorar,
    String? licoesAprendidas,
  }) async {
    final body = <String, dynamic>{
      'objetivo_alcancado': objetivoAlcancado,
      'engajamento_audiencia': engajamentoAudiencia,
      if (discursoId != null) 'discurso_id': discursoId,
      if (parteId != null) 'parte_id': parteId,
      if (competencias != null) 'competencias': competencias,
      if (caracteristicasIds != null) 'caracteristicas_ids': caracteristicasIds,
      if (pontosFortes != null) 'pontos_fortes': pontosFortes,
      if (pontosMelhorar != null) 'pontos_melhorar': pontosMelhorar,
      if (licoesAprendidas != null) 'licoes_aprendidas': licoesAprendidas,
    };

    final response = await ApiHttpHelper.post(
      ApiRoutes.aprimorarFeedback,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao enviar feedback: ${response.statusCode}');
  }

  // ==========================================
  // ESTUDO GUIADO
  // ==========================================

  /// Gera perguntas de pesquisa a partir de fonte/trecho.
  Future<Map<String, dynamic>> estudoPesquisa({
    required String fonte,
    required String trecho,
    String? discursoId,
  }) async {
    final body = <String, dynamic>{
      'fonte': fonte,
      'trecho': trecho,
      if (discursoId != null) 'discurso_id': discursoId,
    };

    final response = await ApiHttpHelper.post(
      ApiRoutes.estudoPesquisa,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha na pesquisa de estudo: ${response.statusCode}');
  }

  /// Gera perguntas de meditação por tópico do esboço.
  Future<Map<String, dynamic>> estudoMeditacao({
    required String topico,
    String? discursoId,
  }) async {
    final body = <String, dynamic>{
      'topico': topico,
      if (discursoId != null) 'discurso_id': discursoId,
    };

    final response = await ApiHttpHelper.post(
      ApiRoutes.estudoMeditacao,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha na meditação de estudo: ${response.statusCode}');
  }

  /// Gera cartões de memorização (frente/verso).
  Future<Map<String, dynamic>> estudoMemorizar({
    required String conteudo,
    String? discursoId,
  }) async {
    final body = <String, dynamic>{
      'conteudo': conteudo,
      if (discursoId != null) 'discurso_id': discursoId,
    };

    final response = await ApiHttpHelper.post(
      ApiRoutes.estudoMemorizar,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao gerar memorização: ${response.statusCode}');
  }

  /// Checklist de progresso por passo Shinyashiki.
  Future<Map<String, dynamic>> getEstudoProgresso(String discursoId) async {
    final response = await ApiHttpHelper.get(
      '${ApiRoutes.estudoProgresso}/$discursoId',
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao obter progresso: ${response.statusCode}');
  }
}

/// Metas de tempo de ensaio retornadas pelo backend.
class MetasTempo {
  final int intro;
  final int corpo;
  final int conclusao;
  final String unidade;

  const MetasTempo({
    this.intro = 1,
    this.corpo = 7,
    this.conclusao = 2,
    this.unidade = 'minutos',
  });

  factory MetasTempo.fromJson(Map<String, dynamic> json) {
    return MetasTempo(
      intro: (json['intro'] ?? 1) as int,
      corpo: (json['corpo'] ?? 7) as int,
      conclusao: (json['conclusao'] ?? 2) as int,
      unidade: (json['unidade'] ?? 'minutos').toString(),
    );
  }

  int get totalMinutos => intro + corpo + conclusao;
}

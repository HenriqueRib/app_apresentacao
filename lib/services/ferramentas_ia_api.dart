import 'dart:convert';

import '../core/constants/api_routes.dart';
import '../core/utils/api_http_helper.dart';
import '../core/utils/api_json_helpers.dart';

/// Service para ferramentas de IA: Comparador de esboços e Exercícios de oratória.
///
/// Rotas:
///   - POST /v1/comparar/esbocos
///   - POST /v1/exercicios/gerar
///   - POST /v1/exercicios/aquecimento
class FerramentasIaApi {
  static const Duration _timeout = Duration(seconds: 60);

  // ==========================================
  // COMPARADOR DE ESBOÇOS
  // ==========================================

  /// Compara dois esboços e retorna análise de diferenças.
  Future<Map<String, dynamic>> compararEsbocos({
    required Map<String, dynamic> esbocoA,
    required Map<String, dynamic> esbocoB,
  }) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.compararEsbocos,
      body: jsonEncode({'esboco_a': esbocoA, 'esboco_b': esbocoB}),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception(
        'Falha ao comparar esboços: ${response.statusCode}');
  }

  // ==========================================
  // EXERCÍCIOS DE ORATÓRIA
  // ==========================================

  /// Gera exercícios personalizados de oratória.
  Future<Map<String, dynamic>> gerarExercicios(
      Map<String, dynamic> params) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.exerciciosGerar,
      body: jsonEncode(params),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception(
        'Falha ao gerar exercícios: ${response.statusCode}');
  }

  /// Aquecimento rápido (exercícios curtos pré-apresentação).
  Future<Map<String, dynamic>> aquecimentoRapido(
      [Map<String, dynamic>? params]) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.exerciciosAquecimento,
      body: params != null ? jsonEncode(params) : null,
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception(
        'Falha ao gerar aquecimento: ${response.statusCode}');
  }
}

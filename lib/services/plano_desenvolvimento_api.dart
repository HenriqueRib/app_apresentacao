import 'dart:convert';

import '../core/constants/api_routes.dart';
import '../core/utils/api_http_helper.dart';
import '../core/utils/api_json_helpers.dart';

/// Service para Plano de Desenvolvimento do Orador.
///
/// Rotas:
///   - GET    /v1/plano-desenvolvimento
///   - POST   /v1/plano-desenvolvimento
///   - GET    /v1/plano-desenvolvimento/analytics
///   - POST   /v1/plano-desenvolvimento/gerar
///   - POST   /v1/plano-desenvolvimento/coaching
///   - GET    /v1/plano-desenvolvimento/{id}
///   - PUT    /v1/plano-desenvolvimento/{id}
///   - DELETE /v1/plano-desenvolvimento/{id}
class PlanoDesenvolvimentoApi {
  static const Duration _timeout = Duration(seconds: 60);

  Future<List<Map<String, dynamic>>> listar() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.planoDesenvolvimento,
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return extractJsonList(decoded);
    }
    throw Exception('Falha ao listar planos: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> data) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.planoDesenvolvimento,
      body: jsonEncode(data),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao criar plano: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> detalhe(int id) async {
    final response = await ApiHttpHelper.get(
      '${ApiRoutes.planoDesenvolvimento}/$id',
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao buscar plano $id: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> atualizar(
      int id, Map<String, dynamic> data) async {
    final response = await ApiHttpHelper.put(
      '${ApiRoutes.planoDesenvolvimento}/$id',
      body: jsonEncode(data),
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao atualizar plano $id: ${response.statusCode}');
  }

  Future<void> excluir(int id) async {
    final response = await ApiHttpHelper.delete(
      '${ApiRoutes.planoDesenvolvimento}/$id',
      timeout: _timeout,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir plano $id: ${response.statusCode}');
    }
  }

  /// Analytics (evolução do orador).
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.planoDesenvolvimentoAnalytics,
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao obter analytics: ${response.statusCode}');
  }

  /// Gera plano de desenvolvimento via IA.
  Future<Map<String, dynamic>> gerarPlano(Map<String, dynamic> input) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.planoDesenvolvimentoGerar,
      body: jsonEncode(input),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao gerar plano: ${response.statusCode}');
  }

  /// Sessão de coaching (IA).
  Future<Map<String, dynamic>> coaching(Map<String, dynamic> input) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.planoDesenvolvimentoCoaching,
      body: jsonEncode(input),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return unwrapData(decoded);
    }
    throw Exception('Falha ao obter coaching: ${response.statusCode}');
  }
}

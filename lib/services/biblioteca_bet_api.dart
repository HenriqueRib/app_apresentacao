import 'dart:convert';

import '../core/constants/api_routes.dart';
import '../core/utils/api_http_helper.dart';
import '../core/utils/api_json_helpers.dart';

/// Service para Biblioteca be-T — 53 características de oratória no backend.
///
/// Rotas:
///   - GET  /v1/biblioteca-bet
///   - GET  /v1/biblioteca-bet/{id}
///   - GET  /v1/biblioteca-bet/categoria/{categoria}
///   - POST /v1/biblioteca-bet/{id}/dicas
class BibliotecaBetApi {
  static const Duration _timeout = Duration(seconds: 60);

  /// Lista todas as características be-T.
  Future<List<CaracteristicaBet>> listar() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.bibliotecaBet,
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = extractJsonList(decoded);
      return list.map(CaracteristicaBet.fromJson).toList();
    }
    throw Exception(
        'Falha ao listar biblioteca be-T: ${response.statusCode}');
  }

  /// Detalhe de uma característica.
  Future<CaracteristicaBet> detalhe(int id) async {
    final response = await ApiHttpHelper.get(
      '${ApiRoutes.bibliotecaBet}/$id',
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return CaracteristicaBet.fromJson(unwrapData(decoded));
    }
    throw Exception(
        'Falha ao buscar característica $id: ${response.statusCode}');
  }

  /// Filtra por categoria.
  Future<List<CaracteristicaBet>> porCategoria(String categoria) async {
    final response = await ApiHttpHelper.get(
      '${ApiRoutes.bibliotecaBet}/categoria/$categoria',
      timeout: _timeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = extractJsonList(decoded);
      return list.map(CaracteristicaBet.fromJson).toList();
    }
    throw Exception(
        'Falha ao filtrar por categoria: ${response.statusCode}');
  }

  /// Gera dicas de melhoria para a característica (IA).
  Future<String> gerarDicas(int id) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.bibliotecaBet}/$id/dicas',
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return extractGeneratedContent(decoded);
    }
    throw Exception('Falha ao gerar dicas: ${response.statusCode}');
  }
}

class CaracteristicaBet {
  final int id;
  final String titulo;
  final String? categoria;
  final String? descricao;
  final String? dicas;

  const CaracteristicaBet({
    required this.id,
    required this.titulo,
    this.categoria,
    this.descricao,
    this.dicas,
  });

  factory CaracteristicaBet.fromJson(Map<String, dynamic> json) {
    return CaracteristicaBet(
      id: (json['id'] ?? 0) as int,
      titulo: (json['titulo'] ?? json['title'] ?? '').toString(),
      categoria: json['categoria']?.toString(),
      descricao: json['descricao']?.toString(),
      dicas: json['dicas']?.toString(),
    );
  }
}

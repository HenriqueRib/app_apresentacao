import 'dart:convert';

import '../core/constants/api_routes.dart';
import '../core/utils/api_http_helper.dart';
import '../core/utils/api_json_helpers.dart';
import '../models/avaliacao_esboco.dart';
import '../models/speech.dart';

/// Service para `POST /api/v1/avaliar/esboco`.
///
/// Rota canônica de avaliação pedagógica de esboço (Shinyashiki + be-T).
/// Substitui a proposta antiga `/oratoria/avaliar-conteudo`.
///
/// Contrato: [doc/mobile/contrato-json-backend-flutter.md]
class AvaliacaoEsbocoApi {
  static const Duration _timeout = Duration(seconds: 60);

  /// Avalia um esboço estruturado a partir de um [Speech].
  ///
  /// [speech] deve ter `outline` preenchido.
  /// [focoId] — se o usuário selecionou uma característica be-T de foco.
  Future<AvaliacaoEsbocoResponse> avaliarEsboco(
    Speech speech, {
    int? focoId,
  }) async {
    if (speech.outline == null) {
      throw ArgumentError('Speech.outline é obrigatório para avaliação.');
    }

    final body = _buildRequestBody(speech, focoId: focoId);
    final response = await ApiHttpHelper.post(
      ApiRoutes.avaliarEsboco,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = unwrapData(decoded);
      return AvaliacaoEsbocoResponse.fromJson(data);
    }

    if (response.statusCode == 422) {
      final decoded = jsonDecode(response.body);
      final msg = decoded['message'] ?? 'Dados inválidos para avaliação';
      throw Exception('Validação: $msg');
    }

    throw Exception(
        'Falha ao avaliar esboço: ${response.statusCode}');
  }

  /// Avalia texto livre (esboço manuscrito/OCR ou corrido).
  Future<AvaliacaoEsbocoResponse> avaliarTextoLivre({
    required String tipo,
    required String objetivoCentral,
    required String textoLivre,
    int duracaoMinutos = 10,
    int? focoId,
    String idioma = 'pt-BR',
  }) async {
    final body = <String, dynamic>{
      'tipo': tipo,
      'objetivo_central': objetivoCentral,
      'esboco_texto_livre': textoLivre,
      'duracao_minutos': duracaoMinutos,
      'idioma': idioma,
      if (focoId != null) 'caracteristica_foco_id': focoId,
    };

    final response = await ApiHttpHelper.post(
      ApiRoutes.avaliarEsboco,
      body: jsonEncode(body),
      timeout: _timeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = unwrapData(decoded);
      return AvaliacaoEsbocoResponse.fromJson(data);
    }

    if (response.statusCode == 422) {
      final decoded = jsonDecode(response.body);
      final msg = decoded['message'] ?? 'Dados inválidos para avaliação';
      throw Exception('Validação: $msg');
    }

    throw Exception(
        'Falha ao avaliar esboço (texto livre): ${response.statusCode}');
  }

  Map<String, dynamic> _buildRequestBody(Speech speech, {int? focoId}) {
    return {
      'tipo': speech.apiTipo,
      'titulo': speech.title,
      'objetivo_central': speech.centralObjective,
      'esboco': speech.outline!.toApiJson(),
      'duracao_minutos': speech.durationMinutes,
      'idioma': 'pt-BR',
      if (focoId != null)
        'caracteristica_foco_id': focoId
      else if (speech.focusCharacteristicId != null)
        'caracteristica_foco_id': speech.focusCharacteristicId,
    };
  }
}

import 'dart:convert';
import '../core/constants/api_routes.dart';
import '../core/utils/api_http_helper.dart';
import '../core/utils/api_json_helpers.dart';
import '../models/weekly_comment_item.dart';
import '../models/admin_discurso.dart';
import '../models/assentinel_study.dart';
import '../models/parte.dart';
import '../models/resposta_gerada.dart';

class BackendSpeechSummary {
  final int id;
  final String tema;
  final String? objetivo;
  final DateTime? createdAt;

  const BackendSpeechSummary({
    required this.id,
    required this.tema,
    this.objetivo,
    this.createdAt,
  });

  factory BackendSpeechSummary.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return BackendSpeechSummary(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      tema: (json['tema'] ?? '').toString(),
      objetivo: json['objetivo']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class BackendSpeechDetails {
  final int id;
  final String tema;
  final String objetivo;
  final String esbocoOriginal;
  final String manuscritoCompleto;
  final String comentarioInicial;
  final String comentarioFinal;
  final String? data;
  final String? numero;
  final String? cantico;
  final String? fonteMaterias;
  final String? guide;
  final DateTime? createdAt;

  const BackendSpeechDetails({
    required this.id,
    required this.tema,
    required this.objetivo,
    required this.esbocoOriginal,
    required this.manuscritoCompleto,
    required this.comentarioInicial,
    required this.comentarioFinal,
    this.data,
    this.numero,
    this.cantico,
    this.fonteMaterias,
    this.guide,
    this.createdAt,
  });

  factory BackendSpeechDetails.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return BackendSpeechDetails(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      tema: (json['tema'] ?? '').toString(),
      objetivo: (json['objetivo'] ?? '').toString(),
      esbocoOriginal: (json['esboco_original'] ?? '').toString(),
      manuscritoCompleto: (json['manuscrito_completo'] ?? '').toString(),
      comentarioInicial: (json['comentario_inicial'] ?? '').toString(),
      comentarioFinal: (json['comentario_final'] ?? '').toString(),
      data: json['data']?.toString(),
      numero: json['numero']?.toString(),
      cantico: json['cantico']?.toString(),
      fonteMaterias: json['fonte_materias']?.toString(),
      guide: json['guide']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class WeeklyCommentsResponse {
  final String semana;
  final String textoJoiaEspiritual;
  final String capituloTexto;
  final String livro;
  final int? capitulo;
  final List<WeeklyCommentItem> comentarios;

  const WeeklyCommentsResponse({
    required this.semana,
    required this.textoJoiaEspiritual,
    this.capituloTexto = '',
    this.livro = '',
    this.capitulo,
    this.comentarios = const [],
  });

  List<String> get comentarioTexts =>
      comentarios.map((c) => c.comentario).where((t) => t.isNotEmpty).toList();

  factory WeeklyCommentsResponse.fromJson(Map<String, dynamic> json) {
    final reuniao = json['reuniao'] is Map
        ? Map<String, dynamic>.from(json['reuniao'] as Map)
        : null;
    final rawComments = json['comentarios'] as List? ?? const [];
    final items = rawComments
        .map(WeeklyCommentItem.fromJson)
        .where((c) => c.comentario.isNotEmpty)
        .toList();

    final cap = reuniao?['capitulo'] ?? json['capitulo'];
    return WeeklyCommentsResponse(
      semana: (json['semana'] ?? reuniao?['semana'] ?? '').toString(),
      textoJoiaEspiritual:
          (reuniao?['texto_joia_espiritual'] ?? json['texto_joia_espiritual'] ?? '')
              .toString(),
      capituloTexto:
          (reuniao?['capitulo_texto'] ?? json['capitulo_texto'] ?? '').toString(),
      livro: (reuniao?['livro'] ?? json['livro'] ?? '').toString(),
      capitulo: cap is int ? cap : int.tryParse(cap?.toString() ?? ''),
      comentarios: items,
    );
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const Duration _requestTimeout = Duration(seconds: 60);
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, dynamic>> generateManuscript(String rawContent) async {
    try {
      final response = await ApiHttpHelper.post(
        '/v1/discursos/gerar-manuscrito/total',
        body: jsonEncode({'conteudo_bruto': rawContent}),
        timeout: _requestTimeout,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao gerar manuscrito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> generateGuide(String rawContent) async {
    try {
      final response = await ApiHttpHelper.post(
        '/v1/discursos/gerar-guia',
        body: jsonEncode({'conteudo_bruto': rawContent}),
        timeout: _requestTimeout,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao gerar guia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao gerar guia: $e');
    }
  }

  Future<List<BackendSpeechSummary>> getSpeechHistory() async {
    try {
      final response = await ApiHttpHelper.get(
        ApiRoutes.discursos,
        timeout: _requestTimeout,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao listar discursos: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> jsonList;
      if (decoded is Map && decoded['data'] is List<dynamic>) {
        jsonList = decoded['data'] as List<dynamic>;
      } else if (decoded is List) {
        jsonList = decoded;
      } else {
        throw Exception('Formato de resposta invalido para histórico. Conteudo: $decoded');
      }

      return jsonList
          .map((item) => BackendSpeechSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar historico de discursos: $e');
    }
  }

  Future<BackendSpeechDetails> getSpeechDetails(int id) async {
    try {
      final response = await ApiHttpHelper.get(
        '${ApiRoutes.discursos}/$id',
        timeout: _requestTimeout,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao buscar detalhes do discurso: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      final Map<String, dynamic> jsonMap;
      if (decoded is Map<String, dynamic>) {
        final hasDirectSpeechFields =
            decoded.containsKey('tema') ||
            decoded.containsKey('esboco_original') ||
            decoded.containsKey('manuscrito_completo');

        if (hasDirectSpeechFields) {
          jsonMap = decoded;
        } else if (decoded['data'] is Map<String, dynamic>) {
          jsonMap = decoded['data'] as Map<String, dynamic>;
        } else {
          // Alguns backends retornam "data" com outros tipos (ex: string de data).
          // Nesse caso, aproveitamos o objeto raiz ao inves de falhar a sincronizacao.
          jsonMap = decoded;
        }
      } else {
        throw Exception('Formato de resposta invalido para detalhes. Conteudo: $decoded');
      }

      return BackendSpeechDetails.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do discurso $id: $e');
    }
  }

  Future<WeeklyCommentsResponse> getWeeklyComments() async {
    try {
      final response = await ApiHttpHelper.get(
        ApiRoutes.comentariosSemanal,
        timeout: _requestTimeout,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao buscar comentarios semanais: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>) {
        return WeeklyCommentsResponse.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      if (decoded is Map<String, dynamic>) {
        return WeeklyCommentsResponse.fromJson(decoded);
      }
      throw Exception('Formato inesperado de comentarios semanais: $decoded');
    } catch (e) {
      throw Exception('Erro ao buscar comentarios da semana: $e');
    }
  }

  /// Gera comentários da semana via v1 (com fallback para rota legada /wol).
  Future<int> generateWeeklyComments() async {
    try {
      var response = await ApiHttpHelper.post(
        ApiRoutes.comentariosGerar,
        body: jsonEncode({}),
        timeout: _requestTimeout,
      );

      // Fallback: se v1 retornar 404, tentar rota legada WOL
      if (response.statusCode == 404) {
        response = await ApiHttpHelper.post(
          ApiRoutes.wolComentariosGerar,
          body: jsonEncode({}),
          timeout: _requestTimeout,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final count = decoded['generated_count'] ??
              decoded['gerados'] ??
              decoded['count'];
          if (count is int) return count;
          if (count != null) return int.tryParse(count.toString()) ?? 0;
        }
        return 0;
      }
      throw Exception('Falha ao gerar comentarios: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro ao gerar comentarios da semana: $e');
    }
  }

  /// Refina um trecho curto de texto (tópico de esboço).
  /// Rota esperada no backend WOL: POST /v1/discursos/refinar-texto
  Future<String> improveText(String text) async {
    try {
      final response = await ApiHttpHelper.post(
        '/v1/discursos/refinar-texto',
        body: jsonEncode({'texto': text}),
        timeout: _requestTimeout,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final result = decoded['texto_refinado'] ??
              decoded['texto'] ??
              decoded['data'];
          if (result is String) return result;
          if (result is Map && result['texto'] != null) {
            return result['texto'].toString();
          }
        }
        if (decoded is String) return decoded;
        throw Exception('Formato de resposta inesperado ao refinar texto.');
      }
      throw Exception('Falha ao refinar texto: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro ao refinar texto: $e');
    }
  }

  // ==========================================
  // 1. RESPOSTAS GERADAS ENDPOINTS
  // ==========================================
  Future<List<RespostaGerada>> getBackendRespostasGeradas() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.respostasGeradas,
      timeout: _requestTimeout,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return extractJsonList(decoded, listKeys: ['respostas'])
          .map(RespostaGerada.fromJson)
          .toList();
    }
    throw Exception('Falha ao obter respostas: ${response.statusCode}');
  }

  Future<RespostaGerada> generateRespostaGerada({
    String? pergunta,
    required String textoBase,
    required String fontePesquisa,
    String? promptEspecifico,
  }) async {
    final body = jsonEncode({
      'pergunta': pergunta,
      'texto_base': textoBase,
      'fonte_pesquisa': fontePesquisa,
      'prompt_especifico': promptEspecifico ?? 'Resposta simples e objetiva',
    });
    final response = await ApiHttpHelper.post(
      ApiRoutes.respostasGeradas,
      body: body,
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = decoded['resposta'] ?? decoded['data'] ?? decoded;
      return RespostaGerada.fromJson(data);
    }
    throw Exception('Falha ao gerar resposta: ${response.statusCode}');
  }

  Future<RespostaGerada> improveRespostaGerada(String id, String instructions) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.respostasGeradas}/$id/improve',
      body: jsonEncode({'instrucao_melhoria': instructions}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['resposta'] ?? decoded['data'] ?? decoded;
      return RespostaGerada.fromJson(data);
    }
    throw Exception('Falha ao melhorar resposta: ${response.statusCode}');
  }

  // ==========================================
  // 2. A SENTINELA (ASSENTINEL) ENDPOINTS
  // ==========================================
  Future<List<AssentinelStudy>> getBackendAssentinelStudies() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.assentinelEstudos,
      timeout: _requestTimeout,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return extractJsonList(decoded, listKeys: ['estudos'])
          .map(AssentinelStudy.fromJson)
          .toList();
    }
    throw Exception('Falha ao obter estudos: ${response.statusCode}');
  }

  Future<AssentinelStudy> createBackendAssentinelStudy(String content) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.assentinelEstudos,
      body: jsonEncode({'conteudo_estudo': content}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return AssentinelStudy.fromJson(data);
    }
    throw Exception('Falha ao criar estudo: ${response.statusCode}');
  }

  Future<void> deleteBackendAssentinelStudy(String id) async {
    final response = await ApiHttpHelper.delete(
      '${ApiRoutes.assentinelEstudos}/$id',
      timeout: _requestTimeout,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir estudo: ${response.statusCode}');
    }
  }

  Future<String> generateAssentinelComment(String studyId, String type) async {
    // type: comentario-inicial | comentario-final | resumo (sem body)
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.assentinelEstudos}/$studyId/$type',
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return extractGeneratedContent(decoded);
    }
    throw Exception('Falha ao gerar bloco de estudo: ${response.statusCode}');
  }

  Future<Map<String, String>> getAssentinelSettings() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.assentinelSettings,
      timeout: _requestTimeout,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return parseSettingsMap(decoded);
    }
    throw Exception('Falha ao carregar configurações: ${response.statusCode}');
  }

  Future<void> saveAssentinelSettings(Map<String, String> settings) async {
    final response = await ApiHttpHelper.put(
      ApiRoutes.assentinelSettings,
      body: jsonEncode(settings),
      timeout: _requestTimeout,
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao salvar configurações: ${response.statusCode}');
    }
  }

  // ==========================================
  // 3. PARTES DA REUNIÃO ENDPOINTS
  // ==========================================
  Future<List<Parte>> getBackendPartes() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.partes,
      timeout: _requestTimeout,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return extractJsonList(decoded, listKeys: ['partes'])
          .map(Parte.fromJson)
          .toList();
    }
    throw Exception('Falha ao obter partes: ${response.statusCode}');
  }

  Future<Parte> createBackendParte(Parte parte) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.partes,
      body: jsonEncode(parte.toJson()),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return Parte.fromJson(data);
    }
    throw Exception('Falha ao criar parte: ${response.statusCode}');
  }

  Future<Parte> updateBackendParte(String id, Parte parte) async {
    final response = await ApiHttpHelper.put(
      '${ApiRoutes.partes}/$id',
      body: jsonEncode(parte.toJson()),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return Parte.fromJson(data);
    }
    throw Exception('Falha ao atualizar parte: ${response.statusCode}');
  }

  Future<void> deleteBackendParte(String id) async {
    final response = await ApiHttpHelper.delete(
      '${ApiRoutes.partes}/$id',
      timeout: _requestTimeout,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir parte: ${response.statusCode}');
    }
  }

  Future<String> generateParteEsboco(String id) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.partes}/$id/gerar-esboco',
      body: jsonEncode({'id': id}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return (decoded['content'] ?? decoded['esboco'] ?? decoded['data'] ?? '').toString();
    }
    throw Exception('Falha ao gerar esboço da parte: ${response.statusCode}');
  }

  Future<String> improveParteEsboco(String id, String instructions, String esbocoCompleto) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.partes}/$id/esboco/improve',
      body: jsonEncode({'instructions': instructions, 'esboco': esbocoCompleto}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return (decoded['content'] ?? decoded['esboco'] ?? decoded['data'] ?? '').toString();
    }
    throw Exception('Falha ao melhorar esboço da parte: ${response.statusCode}');
  }

  Future<String> getParteSettings() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.partesSettings,
      timeout: _requestTimeout,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final map = parseSettingsMap(
        decoded,
        aliases: const {
          'prompt_geral': 'prompt_parte_geral',
        },
      );
      return map['prompt_geral'] ??
          map['prompt_parte_geral'] ??
          '';
    }
    throw Exception('Falha ao carregar configuração de partes: ${response.statusCode}');
  }

  Future<void> saveParteSettings(String prompt) async {
    final response = await ApiHttpHelper.put(
      ApiRoutes.partesSettings,
      body: jsonEncode({'prompt_geral': prompt}),
      timeout: _requestTimeout,
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao salvar configuração de partes: ${response.statusCode}');
    }
  }

  // ==========================================
  // 4. DISCURSOS EXTENDED ENDPOINTS
  // ==========================================
  Future<AdminDiscurso> createBackendDiscurso(Map<String, dynamic> data) async {
    final response = await ApiHttpHelper.post(
      ApiRoutes.discursos,
      body: jsonEncode(data),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final map = decoded['data'] ?? decoded;
      return AdminDiscurso.fromJson(map as Map<String, dynamic>);
    }
    throw Exception('Falha ao criar discurso: ${response.statusCode}');
  }

  Future<void> deleteBackendDiscurso(int id) async {
    final response = await ApiHttpHelper.delete(
      '${ApiRoutes.discursos}/$id',
      timeout: _requestTimeout,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir discurso: ${response.statusCode}');
    }
  }

  Future<AdminDiscurso> fetchAdminDiscurso(int id) async {
    final details = await getSpeechDetails(id);
    return AdminDiscurso(
      id: details.id,
      tema: details.tema,
      data: details.data,
      numero: details.numero,
      cantico: details.cantico,
      objetivo: details.objetivo,
      esbocoOriginal: details.esbocoOriginal,
      manuscritoCompleto: details.manuscritoCompleto,
      fonteMaterias: details.fonteMaterias,
      guide: details.guide,
      createdAt: details.createdAt,
    );
  }

  Future<void> updateBackendSpeech(String id, Map<String, dynamic> data) async {
    final response = await ApiHttpHelper.put(
      '${ApiRoutes.discursos}/$id',
      body: jsonEncode(data),
      timeout: _requestTimeout,
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar discurso no backend: ${response.statusCode}');
    }
  }

  Future<String> generateSpeechManuscriptBackend(String id) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.discursos}/$id/gerar-manuscrito',
      body: jsonEncode({'id': id}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return (decoded['content'] ?? decoded['manuscrito'] ?? decoded['data'] ?? '').toString();
    }
    throw Exception('Falha ao gerar manuscrito: ${response.statusCode}');
  }

  Future<String> generateSpeechGuideBackend(String id) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.discursos}/$id/gerar-guia',
      body: jsonEncode({'id': id}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return (decoded['content'] ?? decoded['guia'] ?? decoded['data'] ?? '').toString();
    }
    throw Exception('Falha ao gerar guia: ${response.statusCode}');
  }

  Future<String> improveSpeechManuscriptBackend(String id, String instructions, String manuscriptCompleto) async {
    final response = await ApiHttpHelper.post(
      '${ApiRoutes.discursos}/$id/manuscrito/improve',
      body: jsonEncode({'instructions': instructions, 'manuscript': manuscriptCompleto}),
      timeout: _requestTimeout,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return (decoded['content'] ?? decoded['manuscrito'] ?? decoded['data'] ?? '').toString();
    }
    throw Exception('Falha ao melhorar manuscrito: ${response.statusCode}');
  }

  Future<Map<String, String>> getSpeechSettings() async {
    final response = await ApiHttpHelper.get(
      ApiRoutes.discursosSettings,
      timeout: _requestTimeout,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final map = parseSettingsMap(
        decoded,
        aliases: const {
          'prompt_discurso_geral': 'prompt_geral',
          'prompt_discurso_guia': 'prompt_guia',
        },
      );
      return {
        'prompt_discurso_geral':
            map['prompt_discurso_geral'] ?? map['prompt_geral'] ?? '',
        'prompt_discurso_guia':
            map['prompt_discurso_guia'] ?? map['prompt_guia'] ?? '',
      };
    }
    throw Exception('Falha ao carregar configurações de discursos: ${response.statusCode}');
  }

  Future<void> saveSpeechSettings(String promptGeral, String promptGuia) async {
    final response = await ApiHttpHelper.put(
      ApiRoutes.discursosSettings,
      body: jsonEncode({
        'prompt_geral': promptGeral,
        'prompt_guia': promptGuia,
      }),
      timeout: _requestTimeout,
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao salvar configurações de discursos: ${response.statusCode}');
    }
  }
}

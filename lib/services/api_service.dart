import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

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
  final DateTime? createdAt;

  const BackendSpeechDetails({
    required this.id,
    required this.tema,
    required this.objetivo,
    required this.esbocoOriginal,
    required this.manuscritoCompleto,
    required this.comentarioInicial,
    required this.comentarioFinal,
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
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class WeeklyCommentsResponse {
  final String semana;
  final String textoJoiaEspiritual;
  final List<String> comentarios;

  const WeeklyCommentsResponse({
    required this.semana,
    required this.textoJoiaEspiritual,
    required this.comentarios,
  });

  factory WeeklyCommentsResponse.fromJson(Map<String, dynamic> json) {
    final reuniao = json['reuniao'] as Map<String, dynamic>?;
    final comments = (json['comentarios'] as List?)
            ?.map((item) => (item as Map<String, dynamic>)['comentario']?.toString() ?? '')
            .where((value) => value.isNotEmpty)
            .toList() ??
        const <String>[];

    return WeeklyCommentsResponse(
      semana: (json['semana'] ?? '').toString(),
      textoJoiaEspiritual: (reuniao?['texto_joia_espiritual'] ?? '').toString(),
      comentarios: comments,
    );
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const Duration _requestTimeout = Duration(seconds: 60);
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, dynamic>> generateManuscript(String rawContent) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/v1/discursos/gerar-manuscrito/total');
    final payload = {'conteudo_bruto': rawContent};

    log('Iniciando POST em $url', name: 'ApiService');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(_requestTimeout);

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
    final url = Uri.parse('${AppConstants.apiBaseUrl}/v1/discursos/gerar-guia'); 
    final payload = {'conteudo_bruto': rawContent};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(_requestTimeout);

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
    final url = Uri.parse('${AppConstants.apiBaseUrl}/v1/discursos');
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Falha ao listar discursos: ${response.statusCode}');
      }

      log('Resposta histórico: ${response.body}', name: 'ApiService');
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
      log('Erro ao buscar histórico: $e', name: 'ApiService');
      throw Exception('Erro ao buscar historico de discursos: $e');
    }
  }

  Future<BackendSpeechDetails> getSpeechDetails(int id) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/v1/discursos/$id');
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Falha ao buscar detalhes do discurso: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      log('Resposta detalhes ($id): ${response.body}', name: 'ApiService');
      
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
          log(
            'Resposta de detalhes sem envelope de objeto em "data" (id=$id). '
            'Usando objeto raiz.',
            name: 'ApiService',
            error: 'data=${decoded['data']}',
          );
        }
      } else {
        throw Exception('Formato de resposta invalido para detalhes. Conteudo: $decoded');
      }

      return BackendSpeechDetails.fromJson(jsonMap);
    } catch (e) {
      log('Erro ao buscar detalhes do discurso $id: $e', name: 'ApiService');
      throw Exception('Erro ao buscar detalhes do discurso $id: $e');
    }
  }

  Future<WeeklyCommentsResponse> getWeeklyComments() async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/v1/comentarios/semanal');
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(_requestTimeout);

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
}

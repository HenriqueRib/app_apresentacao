import 'dart:convert';

/// Resultado normalizado de qualquer resposta da API.
///
/// O backend pode retornar:
///   - `{ "data": { ... } }` (envelope Laravel — preferido em rotas novas)
///   - `{ "success": true, "content": "..." }` (legado)
///   - Objeto direto (ex.: manuscrito JSON)
///
/// O Flutter normaliza para `{ success, content }` via [unwrapEnvelope].
class ApiEnvelope {
  final bool success;
  final dynamic content;
  final String? message;

  const ApiEnvelope({required this.success, this.content, this.message});
}

/// Normaliza qualquer formato de resposta do backend para [ApiEnvelope].
ApiEnvelope unwrapEnvelope(dynamic decoded) {
  if (decoded == null) {
    return const ApiEnvelope(success: false, message: 'Resposta vazia');
  }

  if (decoded is! Map) {
    return ApiEnvelope(success: true, content: decoded);
  }

  final map = Map<String, dynamic>.from(decoded);

  // Formato Laravel preferido: { "data": ... }
  if (map.containsKey('data')) {
    return ApiEnvelope(success: true, content: map['data']);
  }

  // Formato legado: { "success": bool, "content": ... }
  if (map.containsKey('success')) {
    final ok = map['success'] == true;
    return ApiEnvelope(
      success: ok,
      content: map['content'] ?? map['data'],
      message: ok ? null : (map['error'] ?? map['message'])?.toString(),
    );
  }

  // Erro explícito
  if (map.containsKey('error') || map.containsKey('message')) {
    final hasError = map.containsKey('error');
    return ApiEnvelope(
      success: !hasError,
      content: map,
      message: (map['error'] ?? map['message'])?.toString(),
    );
  }

  // Objeto direto (não tem wrapper)
  return ApiEnvelope(success: true, content: map);
}

/// Atalho: extrai o campo `data` de uma resposta ou retorna o objeto raiz.
Map<String, dynamic> unwrapData(dynamic decoded) {
  final envelope = unwrapEnvelope(decoded);
  if (envelope.content is Map) {
    return Map<String, dynamic>.from(envelope.content as Map);
  }
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }
  return {};
}

/// Extrai lista de objetos de respostas Laravel com formatos variados.
List<Map<String, dynamic>> extractJsonList(dynamic decoded, {List<String> listKeys = const []}) {
  if (decoded == null) return [];
  if (decoded is List) {
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (decoded is! Map) return [];

  final map = Map<String, dynamic>.from(decoded);
  final keys = [
    ...listKeys,
    'data',
    'estudos',
    'items',
    'results',
    'partes',
    'discursos',
    'respostas',
  ];

  for (final key in keys) {
    final value = map[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (value is Map<String, dynamic>) {
      final nested = extractJsonList(value, listKeys: listKeys);
      if (nested.isNotEmpty) return nested;
    }
  }

  return [];
}

/// Normaliza settings e prompts vindos do backend para Map de String para String.
Map<String, String> parseSettingsMap(
  dynamic decoded, {
  Map<String, String> aliases = const {},
}) {
  final result = <String, String>{};

  void put(String key, dynamic value) {
    if (value == null) return;
    final text = value.toString().trim();
    if (text.isNotEmpty) result[key] = text;
  }

  void readMap(Map<String, dynamic> map) {
    for (final entry in map.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is String || value is num || value is bool) {
        put(key, value);
      } else if (value is Map) {
        readMap(Map<String, dynamic>.from(value));
      }
    }
  }

  if (decoded == null) return result;

  if (decoded is String) {
    try {
      final parsed = jsonDecode(decoded);
      return parseSettingsMap(parsed, aliases: aliases);
    } catch (_) {
      return result;
    }
  }

  if (decoded is List) {
    for (final item in decoded) {
      if (item is Map) {
        final m = Map<String, dynamic>.from(item);
        final k = (m['key'] ?? m['name'] ?? m['setting_key'])?.toString();
        final v = m['value'] ?? m['content'] ?? m['setting_value'];
        if (k != null && k.isNotEmpty) put(k, v);
      }
    }
    return result;
  }

  if (decoded is Map) {
    readMap(Map<String, dynamic>.from(decoded));
  }

  for (final entry in aliases.entries) {
    if (result.containsKey(entry.value) && result[entry.value]!.isNotEmpty) {
      result[entry.key] = result[entry.value]!;
    } else if (result.containsKey(entry.key) && result[entry.key]!.isNotEmpty) {
      result.putIfAbsent(entry.value, () => result[entry.key]!);
    }
  }

  return result;
}

String extractGeneratedContent(dynamic decoded) {
  if (decoded == null) return '';
  if (decoded is String) return decoded;
  if (decoded is! Map) return decoded.toString();

  final map = Map<String, dynamic>.from(decoded);
  for (final key in [
    'content',
    'comment',
    'texto',
    'texto_refinado',
    'manuscrito',
    'esboco',
    'guia',
    'resposta_gerada',
  ]) {
    final v = map[key];
    if (v is String && v.isNotEmpty) return v;
  }

  final data = map['data'];
  if (data is String && data.isNotEmpty) return data;
  if (data is Map) return extractGeneratedContent(data);

  final resposta = map['resposta'];
  if (resposta is Map) return extractGeneratedContent(resposta);

  return '';
}

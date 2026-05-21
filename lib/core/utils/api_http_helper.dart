import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'api_request_logger.dart';

/// Recurso ainda não exposto no servidor (HTTP 404).
class ApiNotFoundException implements Exception {
  final String path;
  const ApiNotFoundException(this.path);

  @override
  String toString() =>
      'Recurso ainda não publicado no backend (404): ${AppConstants.apiBaseUrl}$path';
}

class ApiHttpHelper {
  static const Duration defaultTimeout = Duration(seconds: 60);

  static Uri uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  static Map<String, String> get jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static Future<http.Response> get(
    String path, {
    Duration timeout = defaultTimeout,
    Map<String, String>? headers,
  }) async {
    final response = await _send('GET', uri(path), timeout: timeout, headers: headers);
    _throwIfNotPublished(path, response);
    return response;
  }

  static Future<http.Response> post(
    String path, {
    Object? body,
    Duration timeout = defaultTimeout,
    Map<String, String>? headers,
  }) async {
    final response =
        await _send('POST', uri(path), body: body, timeout: timeout, headers: headers);
    _throwIfNotPublished(path, response);
    return response;
  }

  static Future<http.Response> put(
    String path, {
    Object? body,
    Duration timeout = defaultTimeout,
    Map<String, String>? headers,
  }) async {
    final response =
        await _send('PUT', uri(path), body: body, timeout: timeout, headers: headers);
    _throwIfNotPublished(path, response);
    return response;
  }

  static Future<http.Response> delete(
    String path, {
    Duration timeout = defaultTimeout,
    Map<String, String>? headers,
  }) async {
    final response =
        await _send('DELETE', uri(path), timeout: timeout, headers: headers);
    _throwIfNotPublished(path, response);
    return response;
  }

  static void _throwIfNotPublished(String path, http.Response response) {
    if (response.statusCode == 404) {
      throw ApiNotFoundException(path);
    }
  }

  static Future<http.Response> _send(
    String method,
    Uri url, {
    Object? body,
    Duration timeout = defaultTimeout,
    Map<String, String>? headers,
  }) async {
    final h = {...jsonHeaders, ...?headers};
    final bodyStr = body?.toString();

    final sw = Stopwatch()..start();
    try {
      final http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(url, headers: h).timeout(timeout);
        case 'POST':
          response = await http.post(url, headers: h, body: body).timeout(timeout);
        case 'PUT':
          response = await http.put(url, headers: h, body: body).timeout(timeout);
        case 'DELETE':
          response = await http.delete(url, headers: h).timeout(timeout);
        default:
          throw ArgumentError('Método HTTP não suportado: $method');
      }
      if (response.statusCode != 200) {
        ApiRequestLogger.request(
          method: method,
          url: url,
          body: bodyStr,
          headers: h,
        );
        ApiRequestLogger.response(
          method: method,
          url: url,
          statusCode: response.statusCode,
          body: response.body,
          durationMs: sw.elapsedMilliseconds,
        );
      }
      return response;
    } catch (e, st) {
      ApiRequestLogger.error(
        method: method,
        url: url,
        error: '$e\n$st',
        durationMs: sw.elapsedMilliseconds,
      );
      rethrow;
    }
  }
}

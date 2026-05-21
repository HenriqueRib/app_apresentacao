import 'dart:developer';

import 'package:flutter/foundation.dart';

/// Logs de rede visíveis no terminal (`flutter run`) para debug.
class ApiRequestLogger {
  static const String logName = 'API';
  static const int maxBodyChars = 3000;

  static void request({
    required String method,
    required Uri url,
    String? body,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer()
      ..writeln('┌── API ▶ REQUEST ─────────────────────────────')
      ..writeln('│ $method $url');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('│ headers: $headers');
    }
    if (body != null && body.isNotEmpty) {
      buffer.writeln('│ body:');
      buffer.writeln(_indent(_truncate(body)));
    }
    buffer.write('└────────────────────────────────────────────');
    _emit(buffer.toString());
    log('$method $url', name: logName);
  }

  static void response({
    required String method,
    required Uri url,
    required int statusCode,
    required String body,
    required int durationMs,
  }) {
    final icon = statusCode >= 200 && statusCode < 300 ? '✓' : '✗';
    final buffer = StringBuffer()
      ..writeln(
        '┌── API ◀ RESPONSE $icon $statusCode (${durationMs}ms) ─────────',
      )
      ..writeln('│ $method $url')
      ..writeln('│ body:')
      ..writeln(_indent(_truncate(body)));
    buffer.write('└────────────────────────────────────────────');
    _emit(buffer.toString());
  }

  static void error({
    required String method,
    required Uri url,
    required Object error,
    int? durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('┌── API ✗ ERROR ─────────────────────────────')
      ..writeln('│ $method $url');
    if (durationMs != null) {
      buffer.writeln('│ após ${durationMs}ms');
    }
    buffer
      ..writeln('│ $error')
      ..write('└────────────────────────────────────────────');
    _emit(buffer.toString());
    log('ERROR $method $url → $error', name: logName, level: 1000);
  }

  static void fallback({
    required String method,
    required String path,
    required int statusCode,
    String? nextPath,
  }) {
    final next = nextPath != null ? ' → tentando $nextPath' : ' (sem mais fallbacks)';
    _emit(
      'API ⟳ $method $path retornou $statusCode$next',
    );
  }

  static void info(String message) {
    _emit('API ℹ $message');
  }

  static String _truncate(String text) {
    if (text.length <= maxBodyChars) return text;
    return '${text.substring(0, maxBodyChars)}… [+${text.length - maxBodyChars} chars]';
  }

  static String _indent(String text) {
    return text.split('\n').map((line) => '│   $line').join('\n');
  }

  static void _emit(String message) {
    debugPrint(message);
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../constants/api_constants.dart';
import '../exceptions/api_exception.dart';

class ApiLogger {
  ApiLogger._();

  static const _encoder = JsonEncoder.withIndent('  ');

  static void request(
    String method,
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) {
    _print([
      '╔════════ API REQUEST ════════',
      '║ $method ${_url(path)}',
      if (query != null && query.isNotEmpty) '║ query: ${_pretty(query)}',
      if (headers != null && headers.isNotEmpty)
        '║ headers: ${_pretty(headers)}',
      if (body != null) '║ body: ${_pretty(body)}',
      '╚══════════════════════════════',
    ]);
  }

  static void success(
    String method,
    String path, {
    int? statusCode,
    dynamic response,
  }) {
    _print([
      '╔════════ API SUCCESS ════════',
      '║ $method ${_url(path)}',
      '║ status: ${statusCode ?? '-'}',
      '║ response: ${_pretty(response)}',
      '╚══════════════════════════════',
    ]);
  }

  static void error(
    String method,
    String path, {
    int? statusCode,
    dynamic body,
    Map<String, dynamic>? query,
    dynamic response,
    Object? error,
  }) {
    _print([
      '╔════════ API ERROR ══════════',
      '║ $method ${_url(path)}',
      '║ status: ${statusCode ?? '-'}',
      if (query != null && query.isNotEmpty) '║ query: ${_pretty(query)}',
      if (body != null) '║ request body: ${_pretty(body)}',
      if (response != null) '║ response: ${_pretty(response)}',
      if (error != null) '║ error: ${_errorText(error)}',
      '╚══════════════════════════════',
    ]);
  }

  static String _url(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiConstants.baseUrl}$path';
  }

  static String _pretty(dynamic value) {
    if (value == null) return 'null';
    if (value is FormData) return _formData(value);
    try {
      return _encoder.convert(_jsonSafe(value));
    } catch (_) {
      return value.toString();
    }
  }

  static String _formData(FormData data) {
    final fields = <String, dynamic>{};
    for (final entry in data.fields) {
      fields[entry.key] = entry.value;
    }
    final files = data.files
        .map((entry) {
          final name = entry.value.filename;
          return '${entry.key}: ${name.isEmpty ? 'file' : name}';
        })
        .toList();
    return _pretty({'fields': fields, 'files': files});
  }

  static dynamic _jsonSafe(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), _jsonSafe(item)));
    }
    if (value is Iterable) {
      return value.map(_jsonSafe).toList();
    }
    return value.toString();
  }

  static String _errorText(Object error) {
    if (error is ApiException) {
      return _pretty({
        'message': error.message,
        'statusCode': error.statusCode,
        'errors': error.errors,
      });
    }
    return error.toString();
  }

  static void _print(List<String> lines) {
    for (final line in lines) {
      debugPrint(line);
    }
  }
}

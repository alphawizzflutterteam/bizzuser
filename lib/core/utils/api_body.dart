import 'dart:convert';

import '../../core/constants/app_strings.dart';

class ApiBody {
  ApiBody._();

  static Map<String, dynamic>? asMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed.startsWith('<')) return null;
      try {
        final decoded = jsonDecode(trimmed);
        return asMap(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Map<String, dynamic> dataMap(Map<String, dynamic> json) {
    return asMap(json['data']) ?? {};
  }

  static List<Map<String, dynamic>> asMapList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> dataList(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is List) return asMapList(data);
    final map = asMap(data);
    if (map == null) return const [];
    return asMapList(
      map['items'] ?? map['list'] ?? map['records'] ?? map['addresses'],
    );
  }

  static int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num asNum(dynamic value, {num fallback = 0}) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool isSuccess(Map<String, dynamic> json) {
    final success = json['success'];
    final status = json['status'];
    if (success == true || status == true) return true;
    if (success is num && success == 1) return true;
    if (status is num && status == 1) return true;
    if (success is String && success.toLowerCase() == 'true') return true;
    if (status is String &&
        (status.toLowerCase() == 'true' || status.toLowerCase() == 'success')) {
      return true;
    }
    return false;
  }

  static String message(
    Map<String, dynamic>? json, {
    String fallback = AppStrings.somethingWentWrong,
  }) {
    if (json == null) return fallback;

    final fromErrors = firstError(json['errors'] ?? json['error']);
    if (fromErrors != null) return fromErrors;

    for (final key in ['message', 'msg', 'detail', 'error_message']) {
      final value = json[key];
      final parsed = _asMessage(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static String? firstError(dynamic errors) {
    if (errors == null) return null;
    if (errors is String) {
      final trimmed = errors.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (errors is List && errors.isNotEmpty) {
      return _asMessage(errors.first);
    }
    if (errors is Map) {
      for (final value in errors.values) {
        final parsed = firstError(value) ?? _asMessage(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? _asMessage(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.startsWith('<')) return null;
      return trimmed;
    }
    if (value is List && value.isNotEmpty) {
      return _asMessage(value.first);
    }
    if (value is Map) {
      final parsed = firstError(value) ?? message(asMap(value), fallback: '');
      return parsed.isEmpty ? null : parsed;
    }
    return null;
  }
}

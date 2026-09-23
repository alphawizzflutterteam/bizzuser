import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/api_logger.dart';
import 'session_expiry.dart';
import 'storage_service.dart';

class ApiService extends GetConnect {
  ApiService();

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: ApiConstants.timeoutSeconds);
    httpClient.addRequestModifier<void>((request) {
      request.headers[ApiConstants.headerAccept] = ApiConstants.jsonContentType;
      final isMultipart = request.files != null;
      if (!isMultipart) {
        request.headers[ApiConstants.headerContentType] =
            ApiConstants.jsonContentType;
      }

      if (Get.isRegistered<StorageService>()) {
        final token = Get.find<StorageService>().read<String>(
          StorageKeys.accessToken,
        );
        if (token != null && token.isNotEmpty) {
          request.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
        }
      }
      return request;
    });
    super.onInit();
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _request('POST', path, body: body, encodeJson: true);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _request('GET', path, query: query);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _request('PUT', path, body: body, encodeJson: true);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, [
    Map<String, dynamic>? body,
  ]) {
    return _request(
      'PATCH',
      path,
      body: body ?? <String, dynamic>{},
      encodeJson: true,
    );
  }

  Future<Map<String, dynamic>> postForm(String path, FormData body) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> deleteJson(String path) {
    return _request('DELETE', path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    bool encodeJson = false,
  }) async {
    ApiLogger.request(
      method,
      path,
      body: body,
      query: query,
      headers: _logHeaders(),
    );
    final payload = encodeJson && body is Map<String, dynamic>
        ? jsonEncode(body)
        : body;
    final contentType = encodeJson ? ApiConstants.jsonContentType : null;
    final response = await _send(() {
      switch (method) {
        case 'GET':
          return get(path, query: query);
        case 'PUT':
          return put(path, payload, contentType: contentType);
        case 'PATCH':
          return patch(path, payload, contentType: contentType);
        case 'DELETE':
          return delete(path);
        default:
          return post(path, payload, contentType: contentType);
      }
    }, method: method, path: path, body: body, query: query);
    return _unwrap(method, path, response, body: body, query: query);
  }

  Map<String, String> _logHeaders() {
    final headers = <String, String>{
      ApiConstants.headerAccept: ApiConstants.jsonContentType,
      ApiConstants.headerContentType: ApiConstants.jsonContentType,
    };
    if (Get.isRegistered<StorageService>()) {
      final token = Get.find<StorageService>().read<String>(
        StorageKeys.accessToken,
      );
      if (token != null && token.isNotEmpty) {
        headers[ApiConstants.headerAuthorization] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request, {
    required String method,
    required String path,
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await request();
    } on TimeoutException {
      const exception = ApiException(AppStrings.requestTimedOut, statusCode: 408);
      ApiLogger.error(
        method,
        path,
        statusCode: 408,
        body: body,
        query: query,
        error: exception,
      );
      throw exception;
    } on ApiException catch (error) {
      ApiLogger.error(
        method,
        path,
        statusCode: error.statusCode,
        body: body,
        query: query,
        error: error,
      );
      rethrow;
    } catch (error) {
      final exception = ApiException('${AppStrings.noInternet} ($error)');
      ApiLogger.error(
        method,
        path,
        body: body,
        query: query,
        error: exception,
      );
      throw exception;
    }
  }

  Map<String, dynamic> _unwrap(
    String method,
    String path,
    Response<dynamic> response, {
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    if (response.status.connectionError) {
      throw const ApiException(AppStrings.noInternet);
    }

    final status = response.statusCode ?? 0;
    if (status == 401 && _sentToken(response) && !path.contains('/auth/')) {
      SessionExpiry.handle();
    }
    var json =
        ApiBody.asMap(response.body) ?? ApiBody.asMap(response.bodyString);
    if (json == null) {
      final list = response.body is List
          ? response.body
          : _decodeList(response.bodyString);
      if (list != null) {
        json = {'success': true, 'data': list};
      }
    }
    final fallback = _statusMessage(status);
    final rawResponse = json ?? response.body ?? response.bodyString;

    if (json != null) {
      final message = ApiBody.message(json, fallback: fallback);
      final explicitFail =
          (json.containsKey('success') || json.containsKey('status')) &&
          !ApiBody.isSuccess(json);
      if (status >= 400 || explicitFail) {
        final exception = ApiException(
          message,
          statusCode: status == 0 ? null : status,
          errors: json['errors'] ?? json['error'],
          data: json,
        );
        ApiLogger.error(
          method,
          path,
          statusCode: status,
          body: body,
          query: query,
          response: json,
          error: exception,
        );
        throw exception;
      }
      if (status >= 200 && status < 300) {
        ApiLogger.success(
          method,
          path,
          statusCode: status,
          response: json,
        );
        return json;
      }
    }

    if (status >= 200 && status < 300) {
      final empty = <String, dynamic>{'success': true};
      ApiLogger.success(
        method,
        path,
        statusCode: status,
        response: empty,
      );
      return empty;
    }

    if (response.hasError || status == 0 || status >= 400) {
      final raw = response.bodyString?.trim();
      final rawMessage =
          (raw != null && raw.isNotEmpty && !raw.startsWith('<'))
          ? raw
          : fallback;
      final exception = ApiException(
        rawMessage,
        statusCode: status == 0 ? null : status,
      );
      ApiLogger.error(
        method,
        path,
        statusCode: status,
        body: body,
        query: query,
        response: rawResponse,
        error: exception,
      );
      throw exception;
    }

    final exception = ApiException(fallback, statusCode: status);
    ApiLogger.error(
      method,
      path,
      statusCode: status,
      body: body,
      query: query,
      response: rawResponse,
      error: exception,
    );
    throw exception;
  }

  bool _sentToken(Response<dynamic> response) {
    final header = response.request?.headers[ApiConstants.headerAuthorization];
    return header != null && header.startsWith('Bearer ');
  }

  List<dynamic>? _decodeList(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('[')) return null;
    try {
      final decoded = jsonDecode(trimmed);
      return decoded is List ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  String _statusMessage(int status) {
    if (status == 0) return AppStrings.noInternet;
    if (status == 401) return AppStrings.unauthorized;
    if (status == 403) return AppStrings.forbidden;
    if (status == 404) return AppStrings.noAccountFound;
    if (status == 409) return AppStrings.accountAlreadyExists;
    if (status == 408 || status == 504) return AppStrings.requestTimedOut;
    if (status == 429) return AppStrings.tooManyRequests;
    if (status >= 500) return AppStrings.serverError;
    return AppStrings.somethingWentWrong;
  }

  Future<Response<T>> getRequest<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic json)? decoder,
  }) {
    return get<T>(path, query: query, decoder: decoder);
  }

  Future<Response<T>> postRequest<T>(
    String path, {
    dynamic body,
    T Function(dynamic json)? decoder,
  }) {
    return post<T>(path, body, decoder: decoder);
  }

  Future<Response<T>> putRequest<T>(
    String path, {
    dynamic body,
    T Function(dynamic json)? decoder,
  }) {
    return put<T>(path, body, decoder: decoder);
  }

  Future<Response<T>> deleteRequest<T>(
    String path, {
    T Function(dynamic json)? decoder,
  }) {
    return delete<T>(path, decoder: decoder);
  }
}

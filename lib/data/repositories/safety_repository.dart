import '../../core/constants/api_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/api_body.dart';
import '../models/sos_alert.dart';
import 'base_repository.dart';

class SafetyRepository extends BaseRepository {
  const SafetyRepository(super.apiService);

  Future<List<String>> fetchSosNumbers() async {
    final json = await apiService.getJson(ApiConstants.appConfig);
    final map = ApiBody.dataMap(json);
    final raw = map['sosNumbers'] ?? map['sos'] ?? json['sosNumbers'];
    return _parseNumbers(raw);
  }

  Future<SosAlert> raiseSos({
    String? rideId,
    required double lat,
    required double lng,
    String location = '',
    String message = 'Need help',
  }) async {
    final body = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'message': message,
    };
    final trimmedRideId = rideId?.trim() ?? '';
    if (trimmedRideId.isNotEmpty) {
      body['rideId'] = trimmedRideId;
    }
    final address = location.trim();
    if (address.isNotEmpty) body['location'] = address;
    try {
      final json = await apiService.postJson(ApiConstants.sos, body);
      return SosAlert.fromJson(json);
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        final alert = _alertFromException(error);
        if (alert != null) return alert;
      }
      if (_isOffline(error)) {
        throw const ApiException(AppStrings.unableToReachServer);
      }
      rethrow;
    } catch (_) {
      throw const ApiException(AppStrings.unableToReachServer);
    }
  }

  Future<SosAlert?> fetchActive() async {
    try {
      final json = await apiService.getJson(ApiConstants.sosActive);
      if (json['data'] == null) return null;
      if (json['data'] is! Map) return null;
      final alert = SosAlert.fromJson(json);
      if (alert.id.isEmpty) return null;
      return alert;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      if (_isOffline(error)) {
        throw const ApiException(AppStrings.unableToReachServer);
      }
      rethrow;
    }
  }

  Future<String> cancelSos(String id, {String reason = ''}) async {
    final body = <String, dynamic>{};
    final value = reason.trim();
    if (value.isNotEmpty) {
      body['reason'] = value.length > 200 ? value.substring(0, 200) : value;
    }
    try {
      final json = await apiService.patchJson(
        ApiConstants.sosCancel(id),
        body,
      );
      return ApiBody.message(json, fallback: AppStrings.sosCancelled);
    } on ApiException catch (error) {
      if (_isOffline(error)) {
        throw const ApiException(AppStrings.unableToReachServer);
      }
      rethrow;
    }
  }

  Future<SosHistoryPage> fetchHistory({
    String status = '',
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': '$page',
      'limit': '$limit',
    };
    if (status.trim().isNotEmpty) query['status'] = status.trim();
    try {
      final json = await apiService.getJson(ApiConstants.sos, query: query);
      return SosHistoryPage.fromJson(json);
    } on ApiException catch (error) {
      if (_isOffline(error)) {
        throw const ApiException(AppStrings.unableToReachServer);
      }
      rethrow;
    }
  }

  Future<String> reportSafety({
    String? rideId,
    required String subject,
    required String message,
    required double lat,
    required double lng,
    String location = '',
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'message': message,
      'lat': lat,
      'lng': lng,
    };
    final address = location.trim();
    if (address.isNotEmpty) body['location'] = address;
    final trimmedRideId = rideId?.trim() ?? '';
    if (trimmedRideId.isNotEmpty) {
      body['rideId'] = trimmedRideId;
    }
    print('SOS report API: POST ${ApiConstants.baseUrl}${ApiConstants.reports}');
    print('SOS report request: $body');
    try {
      final json = await apiService.postJson(ApiConstants.reports, body);
      return ApiBody.message(json, fallback: AppStrings.reportSubmitted);
    } on ApiException catch (error) {
      if (_isOffline(error)) {
        throw const ApiException(AppStrings.unableToReachServer);
      }
      rethrow;
    }
  }

  SosAlert? _alertFromException(ApiException error) {
    final raw = error.data;
    if (raw == null) return null;
    final alert = SosAlert.fromJson(raw);
    return alert.id.isEmpty ? null : alert;
  }

  bool _isOffline(ApiException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == null ||
        message.contains('internet') ||
        message.contains('timed out') ||
        message.contains('socket');
  }

  List<String> _parseNumbers(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) {
            if (item is String) return item.trim();
            if (item is Map) {
              return (item['phone'] ?? item['number'] ?? item['value'])
                      ?.toString()
                      .trim() ??
                  '';
            }
            return item.toString().trim();
          })
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (raw is Map) {
      return _parseNumbers(raw['numbers'] ?? raw['items'] ?? raw['list']);
    }
    return const [];
  }
}

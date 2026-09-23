import '../../core/constants/api_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/api_body.dart';
import '../models/chat_message.dart';
import '../models/ride_booking.dart';
import '../models/ride_coupon.dart';
import '../models/ride_estimate.dart';
import '../models/ride_location.dart';
import '../models/ride_payment.dart';
import '../models/ride_vehicles_result.dart';
import '../models/safety_models.dart';
import 'base_repository.dart';
import 'ride_catalog.dart';

/// `POST /user/rides` → 409 "You already have an active ride".
/// [rideId] is the existing ride (`data.rideId`) the app should resume.
class ActiveRideExistsException extends ApiException {
  const ActiveRideExistsException(
    super.message, {
    required this.rideId,
    super.statusCode,
    super.data,
  });

  final String rideId;
}

class RideRepository extends BaseRepository {
  const RideRepository(super.apiService);

  /// Backend requires real coordinates for both ends – never send a default
  /// city as a silent fallback.
  static void _requireCoordinates(RideLocation pickup, RideLocation drop) {
    if (!pickup.hasCoordinates) {
      throw const ApiException(AppStrings.selectPickupLocation);
    }
    if (!drop.hasCoordinates) {
      throw const ApiException(AppStrings.selectDropLocation);
    }
  }

  Future<List<RideBooking>> fetchRides({required String status}) async {
    final json = await apiService.getJson(
      ApiConstants.rides,
      query: {'status': status},
    );
    return ApiBody.dataList(json)
        .map(RideBooking.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<RideBooking> fetchRide(String id) async {
    final json = await apiService.getJson(ApiConstants.ride(id));
    return RideBooking.fromJson(json);
  }

  Future<RideBooking?> fetchActive() async {
    final json = await apiService.getJson(ApiConstants.rideActive);
    if (json['data'] == null) return null;
    final ride = RideBooking.fromJson(json);
    if (ride.id.isEmpty) return null;
    return ride;
  }

  Future<List<ChatMessage>> fetchMessages(String rideId) async {
    final json = await apiService.getJson(ApiConstants.rideMessages(rideId));
    return ApiBody.dataList(json)
        .map(ChatMessage.fromJson)
        .where((item) => item.text.isNotEmpty)
        .toList(growable: false);
  }

  Future<ChatMessage> sendMessage({
    required String rideId,
    required String text,
  }) async {
    final json = await apiService.postJson(ApiConstants.rideMessages(rideId), {
      'text': text.trim(),
    });
    final map = ApiBody.dataMap(json);
    if (map.isNotEmpty) {
      final nested = ApiBody.asMap(map['message']);
      return ChatMessage.fromJson(nested ?? map);
    }
    final items = ApiBody.dataList(json);
    if (items.isNotEmpty) return ChatMessage.fromJson(items.first);
    return ChatMessage.fromJson(json);
  }

  Future<List<RideCoupon>> fetchOffers() async {
    final json = await apiService.getJson(ApiConstants.rideOffers);
    return ApiBody.dataList(json)
        .map(RideCoupon.fromJson)
        .where((item) => item.active && item.code.isNotEmpty)
        .toList(growable: false);
  }

  Future<RideVehiclesResult> fetchVehicles({
    required RideLocation pickup,
    required RideLocation drop,
    required String category,
  }) async {
    _requireCoordinates(pickup, drop);
    final json = await apiService.postJson(ApiConstants.rideVehicles, {
      'pickup': pickup.toApiJson(),
      'drop': drop.toApiJson(),
      'category': category.trim(),
    });
    return RideVehiclesResult.fromJson(json);
  }

  Future<RideEstimate> estimate({
    required RideLocation pickup,
    required RideLocation drop,
    required String couponCode,
    String? vehicleType,
  }) async {
    _requireCoordinates(pickup, drop);
    final body = <String, dynamic>{
      'pickup': pickup.toApiJson(),
      'drop': drop.toApiJson(),
    };
    final type = vehicleType?.trim() ?? '';
    if (type.isNotEmpty) body['vehicleType'] = type;
    final code = couponCode.trim();
    if (code.isNotEmpty) body['couponCode'] = code;
    final json = await apiService.postJson(ApiConstants.rideEstimate, body);
    return RideEstimate.fromJson(json, vehicleType: vehicleType);
  }

  Future<RideEstimate> applyCoupon({
    required RideLocation pickup,
    required RideLocation drop,
    required String couponCode,
    required String vehicleType,
  }) async {
    _requireCoordinates(pickup, drop);
    final json = await apiService.postJson(ApiConstants.rideApplyCoupon, {
      'couponCode': couponCode.trim(),
      'pickup': pickup.toApiJson(),
      'drop': drop.toApiJson(),
      'vehicleType': vehicleType.trim(),
    });
    return RideEstimate.fromJson(json, vehicleType: vehicleType);
  }

  Future<RideBooking> createRide({
    required RideLocation pickup,
    required RideLocation drop,
    required String vehicleType,
    String paymentMethod = 'cash',
    String couponCode = '',
  }) async {
    _requireCoordinates(pickup, drop);
    final body = <String, dynamic>{
      'pickup': pickup.toApiJson(),
      'drop': drop.toApiJson(),
      'vehicleType': vehicleType.trim(),
      'paymentMethod':
          paymentMethod.trim().isEmpty ? 'cash' : paymentMethod.trim(),
    };
    final code = couponCode.trim();
    if (code.isNotEmpty) body['couponCode'] = code;
    try {
      final json = await apiService.postJson(ApiConstants.rides, body);
      return RideBooking.fromJson(json);
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        final data = ApiBody.asMap(error.data?['data']) ?? const {};
        final existing =
            (data['rideId'] ?? data['_id'] ?? '').toString().trim();
        if (existing.isNotEmpty) {
          throw ActiveRideExistsException(
            error.message,
            rideId: existing,
            statusCode: error.statusCode,
            data: error.data,
          );
        }
      }
      rethrow;
    }
  }

  Future<List<SafetyReason>> fetchCancelReasons() async {
    final json = await apiService.getJson(ApiConstants.rideCancelReasons);
    final items = ApiBody.dataList(json);
    if (items.isEmpty) return RideCatalog.cancelReasons;
    return items
        .where((item) => item['active'] != false)
        .map(_cancelReason)
        .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<RideBooking> cancelRide({
    required String id,
    required String reasonId,
    String reason = '',
  }) async {
    final body = <String, dynamic>{};
    final reasonKey = reasonId.trim();
    // Offline catalog ids (e.g. "plans") are not server ids – the backend
    // rejects them, so send the label instead (matched case-insensitively).
    final isServerId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(reasonKey);
    if (isServerId) {
      body['reasonId'] = reasonKey;
    } else if (reason.trim().isNotEmpty) {
      body['reason'] = reason.trim();
    } else if (reasonKey.isNotEmpty) {
      body['reasonId'] = reasonKey;
    }
    final json =
        await apiService.postJson(ApiConstants.rideCancel(id.trim()), body);
    return RideBooking.fromJson(json);
  }

  Future<List<RideLocation>> fetchRecentDestinations() async {
    final json = await apiService.getJson(ApiConstants.rideRecentDestinations);
    final rows = ApiBody.dataList(json);
    return rows
        .map(RideLocation.fromJson)
        .where((item) => item.routeLine.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<String> submitRating({
    required String rideId,
    required int stars,
    String review = '',
  }) async {
    final json = await apiService.postJson(ApiConstants.ratings, {
      'rideId': rideId.trim(),
      'stars': stars,
      'review': review.trim(),
    });
    return ApiBody.message(json, fallback: '');
  }

  Future<RidePayResult> payRide(
    String id, {
    String paymentMethod = '',
  }) async {
    final body = <String, dynamic>{};
    final method = paymentMethod.trim();
    if (method.isNotEmpty) body['paymentMethod'] = method;
    final json = await apiService.postJson(ApiConstants.ridePay(id), body);
    return RidePayResult.fromJson(json);
  }

  Future<RideBooking> verifyRidePayment({
    required String id,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final json = await apiService.postJson(ApiConstants.rideVerifyPayment(id), {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    });
    return RideBooking.fromJson(json);
  }

  SafetyReason _cancelReason(Map<String, dynamic> json) {
    final label =
        (json['label'] ?? json['title'] ?? json['reason'])?.toString().trim() ??
        '';
    return SafetyReason(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: label,
      icon: RideCatalog.cancelReasonIcon(label),
    );
  }
}

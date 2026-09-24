import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/phone_utils.dart';
import '../models/auth_session.dart';
import '../models/otp_sent_data.dart';
import '../models/signup_verify_data.dart';
import '../services/fcm_service.dart';
import '../services/ride_socket_service.dart';
import '../services/storage_service.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  AuthRepository(super.apiService, this._storage);

  final StorageService _storage;

  Future<OtpSentData> sendLoginOtp({
    required String phone,
    required bool acceptedTerms,
  }) {
    return _sendOtp(
      ApiConstants.sendOtp,
      phone: phone,
      acceptedTerms: acceptedTerms,
    );
  }

  Future<OtpSentData> sendRegisterOtp({
    required String phone,
    required bool acceptedTerms,
  }) {
    return _sendOtp(
      ApiConstants.registerSendOtp,
      phone: phone,
      acceptedTerms: acceptedTerms,
    );
  }

  Future<OtpSentData> resendLoginOtp(String phone) {
    return _resendOtp(ApiConstants.resendOtp, phone);
  }

  Future<OtpSentData> resendRegisterOtp(String phone) {
    return _resendOtp(ApiConstants.registerResendOtp, phone);
  }

  Future<AuthSession> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    final fcmToken = await _fcmToken();
    final body = <String, dynamic>{
      'phone': PhoneUtils.toRequestPhone(phone),
      'otp': otp.trim(),
    };
    if (fcmToken.isNotEmpty) body['fcmToken'] = fcmToken;
    final json = await apiService.postJson(ApiConstants.verifyOtp, body);
    final session = _saveSession(AuthSession.fromJson(json));
    _markFcmUploaded(fcmToken);
    return session;
  }

  Future<SignupVerifyData> verifyRegisterOtp({
    required String phone,
    required String otp,
  }) async {
    final fcmToken = await _fcmToken();
    final body = <String, dynamic>{
      'phone': PhoneUtils.toRequestPhone(phone),
      'otp': otp.trim(),
    };
    if (fcmToken.isNotEmpty) body['fcmToken'] = fcmToken;
    final json = await apiService.postJson(
      ApiConstants.registerVerifyOtp,
      body,
    );
    final result = SignupVerifyData.fromJson(json);
    if (result.signupToken.isEmpty) {
      throw ApiException(
        result.message.isNotEmpty
            ? result.message
            : AppStrings.somethingWentWrong,
      );
    }
    return result;
  }

  Future<AuthSession> register({
    required String signupToken,
    required String name,
    String? email,
    String? referralCode,
  }) async {
    final fcmToken = await _fcmToken();
    final body = <String, dynamic>{
      'signupToken': signupToken,
      'name': name.trim(),
      'email': email?.trim() ?? '',
      'referralCode': referralCode?.trim() ?? '',
      'fcmToken': fcmToken,
    };

    final json = await apiService.postJson(ApiConstants.register, body);
    final session = _saveSession(
      AuthSession.fromJson(json, fallbackMessage: AppStrings.accountCreated),
    );
    _markFcmUploaded(fcmToken);
    return session;
  }

  Future<String> logout() async {
    var message = AppStrings.loggedOut;
    final fcmToken = await _fcmToken();
    final body = <String, dynamic>{};
    if (fcmToken.isNotEmpty) body['fcmToken'] = fcmToken;
    try {
      final json = await apiService.postJson(ApiConstants.logout, body);
      message = ApiBody.message(json, fallback: AppStrings.loggedOut);
    } catch (_) {}
    await _clearRealtimeSession();
    return message;
  }

  Future<String> deleteAccount() async {
    final json = await apiService.deleteJson(ApiConstants.deleteAccount);
    final message = ApiBody.message(json, fallback: AppStrings.accountDeleted);
    await _clearRealtimeSession();
    return message;
  }

  Future<void> clearSession() async {
    await _clearRealtimeSession();
  }

  Future<void> _clearRealtimeSession() async {
    if (Get.isRegistered<RideSocketService>()) {
      Get.find<RideSocketService>().disconnect();
    }
    if (Get.isRegistered<FcmService>()) {
      await Get.find<FcmService>().clearOnLogout();
    }
    await _storage.clearSession();
  }

  Future<String> _fcmToken() async {
    if (Get.isRegistered<FcmService>()) {
      try {
        final token = await Get.find<FcmService>().getToken();
        if (token.isNotEmpty) return token;
      } catch (_) {}
    }
    return _storage.read<String>(StorageKeys.fcmToken)?.trim() ?? '';
  }

  void _markFcmUploaded(String token) {
    if (!Get.isRegistered<FcmService>()) return;
    Get.find<FcmService>().markUploaded(token);
  }

  Future<OtpSentData> _sendOtp(
    String path, {
    required String phone,
    required bool acceptedTerms,
  }) async {
    final json = await apiService.postJson(path, {
      'phone': PhoneUtils.toRequestPhone(phone),
      'acceptedTerms': acceptedTerms,
    });
    return OtpSentData.fromJson(json);
  }

  Future<OtpSentData> _resendOtp(String path, String phone) async {
    final json = await apiService.postJson(path, {
      'phone': PhoneUtils.toRequestPhone(phone),
    });
    return OtpSentData.fromJson(json);
  }

  AuthSession _saveSession(AuthSession session) {
    if (session.token.isEmpty) {
      throw ApiException(
        session.message.isNotEmpty
            ? session.message
            : AppStrings.somethingWentWrong,
      );
    }
    _storage.saveSession(token: session.token, user: session.user.toJson());
    if (Get.isRegistered<RideSocketService>()) {
      Get.find<RideSocketService>().ensureConnected();
    }
    return session;
  }
}

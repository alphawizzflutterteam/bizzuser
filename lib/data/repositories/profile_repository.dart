import '../../core/constants/api_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/phone_utils.dart';
import '../models/auth_session.dart';
import '../models/sos_alert.dart';
import '../models/otp_sent_data.dart';
import '../services/storage_service.dart';
import 'base_repository.dart';

class ProfileRepository extends BaseRepository {
  ProfileRepository(super.apiService, this._storage);

  final StorageService _storage;

  Future<ProfileResult> getProfile() async {
    final json = await apiService.getJson(ApiConstants.profile);
    return _save(_parse(json, fallback: AppStrings.profileFetched));
  }

  Future<ProfileResult> updateProfile({
    required String name,
    String? email,
    String? avatar,
    String? referralCode,
  }) async {
    final body = <String, dynamic>{'name': name.trim()};
    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isNotEmpty) {
      body['email'] = trimmedEmail;
    }
    final trimmedAvatar = avatar?.trim() ?? '';
    if (trimmedAvatar.isNotEmpty) {
      body['avatar'] = trimmedAvatar;
    }
    final trimmedReferral = referralCode?.trim() ?? '';
    if (trimmedReferral.isNotEmpty) {
      body['referralCode'] = trimmedReferral;
    }

    final json = await apiService.putJson(ApiConstants.profile, body);
    return _save(_parse(json, fallback: AppStrings.profileUpdated));
  }

  Future<ProfileResult> updateEmergencyContacts(
    List<EmergencyContact> contacts,
  ) async {
    final json = await apiService.putJson(ApiConstants.profile, {
      'emergencyContacts': contacts
          .where((item) => item.isValid)
          .take(3)
          .map((item) => item.toJson())
          .toList(),
    });
    return _save(_parse(json, fallback: AppStrings.profileUpdated));
  }

  Future<void> updateFcmToken(String token) async {
    final value = token.trim();
    if (value.isEmpty) return;
    await apiService.putJson(ApiConstants.profile, {'fcmToken': value});
  }

  Future<OtpSentData> sendPhoneOtp(String phone) async {
    final json = await apiService.postJson(ApiConstants.profilePhoneSendOtp, {
      'phone': PhoneUtils.toRequestPhone(phone),
    });
    return OtpSentData.fromJson(json);
  }

  Future<ProfileResult> confirmPhone({
    required String phone,
    required String otp,
  }) async {
    final json = await apiService.postJson(ApiConstants.profilePhoneConfirm, {
      'phone': PhoneUtils.toRequestPhone(phone),
      'otp': otp.trim(),
    });
    final data = json['data'];
    if (data is Map && (data['id'] != null || data['name'] != null)) {
      return _save(_parse(json, fallback: AppStrings.phoneUpdated));
    }
    return getProfile();
  }

  AuthUser? cachedUser() {
    final raw = _storage.readUser();
    if (raw == null || raw.isEmpty) return null;
    return AuthUser.fromJson(raw);
  }

  ProfileResult _parse(
    Map<String, dynamic> json, {
    required String fallback,
  }) {
    final result = ProfileResult.fromJson(json, fallbackMessage: fallback);
    if (result.user.id.isEmpty && result.user.name.isEmpty) {
      throw ApiException(
        result.message.isNotEmpty ? result.message : fallback,
      );
    }
    return result;
  }

  ProfileResult _save(ProfileResult result) {
    _storage.saveUser(result.user.toJson());
    return result;
  }
}

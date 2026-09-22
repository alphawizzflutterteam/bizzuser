import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';

class SignupVerifyData {
  const SignupVerifyData({
    required this.message,
    required this.signupToken,
    required this.phone,
    required this.expiresInSec,
  });

  final String message;
  final String signupToken;
  final String phone;
  final int expiresInSec;

  factory SignupVerifyData.fromJson(Map<String, dynamic> json) {
    final map = ApiBody.dataMap(json);
    final message = (json['message'] as String?)?.trim();

    return SignupVerifyData(
      message: (message != null && message.isNotEmpty)
          ? message
          : AppStrings.mobileVerified,
      signupToken: map['signupToken']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      expiresInSec: ApiBody.asInt(map['expiresInSec']) ?? 900,
    );
  }
}

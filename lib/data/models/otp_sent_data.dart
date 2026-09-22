import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';

class OtpSentData {
  const OtpSentData({
    required this.message,
    required this.phone,
    required this.maskedPhone,
    required this.otpLength,
    required this.expiresInSec,
    required this.resendInSec,
    this.devOtp,
  });

  final String message;
  final String phone;
  final String maskedPhone;
  final int otpLength;
  final int expiresInSec;
  final int resendInSec;
  final String? devOtp;

  factory OtpSentData.fromJson(Map<String, dynamic> json) {
    final map = ApiBody.dataMap(json);
    final message = (json['message'] as String?)?.trim();
    final masked = map['maskedPhone']?.toString() ?? '';

    return OtpSentData(
      message: (message != null && message.isNotEmpty)
          ? message
          : AppStrings.otpSent,
      phone: map['phone']?.toString() ?? '',
      maskedPhone: masked,
      otpLength: ApiBody.asInt(map['otpLength']) ?? 4,
      expiresInSec: ApiBody.asInt(map['expiresInSec']) ?? 300,
      resendInSec: ApiBody.asInt(map['resendInSec']) ?? 30,
      devOtp: map['devOtp']?.toString(),
    );
  }
}

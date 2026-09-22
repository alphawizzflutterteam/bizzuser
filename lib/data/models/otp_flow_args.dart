class OtpFlowArgs {
  const OtpFlowArgs({
    required this.phone,
    required this.isSignup,
    this.isProfilePhone = false,
    this.maskedPhone = '',
    this.resendInSec = 60,
    this.otpLength = 4,
    this.devOtp = '',
  });

  final String phone;
  final bool isSignup;
  final bool isProfilePhone;
  final String maskedPhone;
  final int resendInSec;
  final int otpLength;
  final String devOtp;

  factory OtpFlowArgs.fromArguments(dynamic args) {
    if (args is OtpFlowArgs) return args;
    if (args is String) {
      return OtpFlowArgs(phone: args, isSignup: false);
    }
    return const OtpFlowArgs(phone: '', isSignup: false);
  }

  factory OtpFlowArgs.login({
    required String phone,
    String maskedPhone = '',
    int otpLength = 4,
    String devOtp = '',
  }) {
    return OtpFlowArgs(
      phone: phone,
      isSignup: false,
      maskedPhone: maskedPhone,
      otpLength: otpLength,
      devOtp: devOtp,
    );
  }

  factory OtpFlowArgs.signup({
    required String phone,
    String maskedPhone = '',
    int otpLength = 4,
    String devOtp = '',
  }) {
    return OtpFlowArgs(
      phone: phone,
      isSignup: true,
      maskedPhone: maskedPhone,
      otpLength: otpLength,
      devOtp: devOtp,
    );
  }

  factory OtpFlowArgs.profilePhone({
    required String phone,
    String maskedPhone = '',
    int otpLength = 4,
    String devOtp = '',
  }) {
    return OtpFlowArgs(
      phone: phone,
      isSignup: false,
      isProfilePhone: true,
      maskedPhone: maskedPhone,
      otpLength: otpLength,
      devOtp: devOtp,
    );
  }
}

class SignupFlowArgs {
  const SignupFlowArgs({required this.phone, required this.signupToken});

  final String phone;
  final String signupToken;

  factory SignupFlowArgs.fromArguments(dynamic args) {
    if (args is SignupFlowArgs) return args;
    if (args is String) {
      return SignupFlowArgs(phone: args, signupToken: '');
    }
    return const SignupFlowArgs(phone: '', signupToken: '');
  }
}

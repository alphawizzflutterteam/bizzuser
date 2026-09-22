import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/models/otp_flow_args.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/fcm_service.dart';
import '../../../data/services/push_notification_service.dart';
import '../../../data/services/sos_service.dart';
import '../../profile/controllers/profile_controller.dart';

class VerifyOtpController extends GetxController {
  VerifyOtpController({OtpFlowArgs? args})
    : flowArgs = args ?? OtpFlowArgs.fromArguments(Get.arguments);

  final OtpFlowArgs flowArgs;

  String get phoneNumber => flowArgs.phone;

  final isLoading = false.obs;
  final displayedOtp = ''.obs;
  late final RxInt secondsLeft;

  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> focusNodes;

  Timer? _timer;

  bool get canResend => secondsLeft.value <= 0;

  String get otpCode => otpControllers.map((c) => c.text).join();

  String get subtitle => AppUtils.otpSubtitle(
    flowArgs.maskedPhone.isNotEmpty ? flowArgs.maskedPhone : phoneNumber,
  );

  String get timerLabel {
    final minutes = (secondsLeft.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onInit() {
    super.onInit();
    secondsLeft = AppDimensions.otpResendSeconds.obs;
    otpControllers = List.generate(
      flowArgs.otpLength,
      (_) => TextEditingController(),
    );
    focusNodes = List.generate(flowArgs.otpLength, (_) => FocusNode());
    _applyOtp(flowArgs.devOtp);
    _startTimer();
  }

  void onDigitChanged(int index, String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length > 1) {
      _fillFromPaste(cleaned);
      return;
    }

    if (cleaned.isNotEmpty && index < flowArgs.otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (cleaned.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void _applyOtp(String? otp) {
    final digits = (otp ?? '').replaceAll(RegExp(r'\D'), '');
    displayedOtp.value = digits;
    if (digits.isEmpty) return;
    _fillFromPaste(digits);
  }

  void _fillFromPaste(String value) {
    final chars = value.split('').take(flowArgs.otpLength).toList();
    for (var i = 0; i < flowArgs.otpLength; i++) {
      final digit = i < chars.length ? chars[i] : '';
      otpControllers[i].text = digit;
    }
    final lastIndex = chars.length.clamp(1, flowArgs.otpLength) - 1;
    focusNodes[lastIndex].requestFocus();
  }

  Future<void> onContinue() async {
    AppUtils.hideKeyboard();
    final error = AppValidators.otp(otpCode, length: flowArgs.otpLength);
    if (error != null) {
      AppUtils.showError(error);
      return;
    }

    try {
      isLoading.value = true;
      if (flowArgs.isProfilePhone) {
        await _confirmProfilePhone();
        return;
      }

      final auth = Get.find<AuthRepository>();
      if (flowArgs.isSignup) {
        final result = await runApi(
          () => auth.verifyRegisterOtp(phone: phoneNumber, otp: otpCode),
        );
        if (result == null) return;
        AppUtils.showSuccess(result.message);
        Get.offNamed(
          AppRoutes.signup,
          arguments: SignupFlowArgs(
            phone: result.phone.isNotEmpty ? result.phone : phoneNumber,
            signupToken: result.signupToken,
          ),
        );
        return;
      }

      final result = await runApi(
        () => auth.verifyLoginOtp(phone: phoneNumber, otp: otpCode),
      );
      if (result == null) return;
      AppUtils.showSuccess(result.message);
      Get.offAllNamed(AppRoutes.home);
      SosService.refreshIfLoggedIn();
      if (Get.isRegistered<FcmService>()) {
        Get.find<FcmService>().syncToken();
      }
      if (Get.isRegistered<PushNotificationService>()) {
        Get.find<PushNotificationService>().consumeLaunchTap();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _confirmProfilePhone() async {
    if (!Get.isRegistered<ProfileRepository>()) {
      AppUtils.showError(AppStrings.somethingWentWrong);
      return;
    }
    final result = await runApi(
      () => Get.find<ProfileRepository>().confirmPhone(
        phone: phoneNumber,
        otp: otpCode,
      ),
    );
    if (result == null) return;
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().applyUser(result.user);
    }
    AppUtils.showSuccess(result.message);
    Get.until((route) => route.isFirst);
  }

  Future<void> resendOtp() async {
    if (!canResend || isLoading.value) return;
    try {
      isLoading.value = true;
      final result = await runApi(
        () => flowArgs.isProfilePhone
            ? Get.find<ProfileRepository>().sendPhoneOtp(phoneNumber)
            : flowArgs.isSignup
            ? Get.find<AuthRepository>().resendRegisterOtp(phoneNumber)
            : Get.find<AuthRepository>().resendLoginOtp(phoneNumber),
      );
      if (result == null) return;
      AppUtils.showSuccess(result.message);
      _applyOtp(result.devOtp);
      _startTimer();
    } finally {
      isLoading.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    secondsLeft.value = AppDimensions.otpResendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        timer.cancel();
        return;
      }
      secondsLeft.value--;
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}

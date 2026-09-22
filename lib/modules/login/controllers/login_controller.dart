import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/models/otp_flow_args.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  final agreedToTerms = false.obs;
  final isLoading = false.obs;

  String? validatePhone(String? value) => AppValidators.phone(value);

  void toggleTerms(bool? value) {
    agreedToTerms.value = value ?? false;
  }

  Future<void> getOtp() async {
    AppUtils.hideKeyboard();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!agreedToTerms.value) {
      AppUtils.showError(AppStrings.acceptTerms);
      return;
    }

    try {
      isLoading.value = true;
      final result = await runApi(
        () => Get.find<AuthRepository>().sendLoginOtp(
          phone: phoneController.text.trim(),
          acceptedTerms: true,
        ),
      );
      if (result == null) return;
      AppUtils.showSuccess(result.message);
      Get.toNamed(
        AppRoutes.verifyOtp,
        arguments: OtpFlowArgs.login(
          phone: phoneController.text.trim(),
          maskedPhone: result.maskedPhone,
          otpLength: result.otpLength,
          devOtp: result.devOtp ?? '',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSignUp() {
    Get.toNamed(AppRoutes.register);
  }

  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}

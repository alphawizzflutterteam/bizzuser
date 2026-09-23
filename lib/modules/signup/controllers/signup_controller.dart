import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/models/otp_flow_args.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/fcm_service.dart';
import '../../../data/services/sos_service.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final referralController = TextEditingController();

  final isLoading = false.obs;
  late final SignupFlowArgs flowArgs;

  String? validateName(String? value) => AppValidators.name(value);

  String? validatePhone(String? value) => AppValidators.phone(value);

  String? validateEmail(String? value) => AppValidators.optionalEmail(value);

  @override
  void onInit() {
    super.onInit();
    flowArgs = SignupFlowArgs.fromArguments(Get.arguments);
    final phone = PhoneUtils.localNumber(flowArgs.phone);
    if (phone.isNotEmpty) {
      phoneController.text = phone;
    }
  }

  Future<void> getStarted() async {
    AppUtils.hideKeyboard();
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (flowArgs.signupToken.isEmpty) {
      AppUtils.showError(AppStrings.signupSessionExpired);
      return;
    }

    try {
      isLoading.value = true;
      final result = await runApi(
        () => Get.find<AuthRepository>().register(
          signupToken: flowArgs.signupToken,
          name: AppValidators.normalizeName(nameController.text),
          email: emailController.text.trim(),
          referralCode: referralController.text.trim().toUpperCase(),
        ),
      );
      if (result == null) return;
      AppUtils.showSuccess(result.message);
      Get.offAllNamed(AppRoutes.home);
      SosService.refreshIfLoggedIn();
      if (Get.isRegistered<FcmService>()) {
        Get.find<FcmService>().syncToken();
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    referralController.dispose();
    super.onClose();
  }
}

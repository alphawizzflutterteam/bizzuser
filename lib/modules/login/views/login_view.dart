import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/auth_phone_form.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPhoneForm(
        formKey: controller.formKey,
        phoneController: controller.phoneController,
        agreedToTerms: controller.agreedToTerms,
        isLoading: controller.isLoading,
        title: AppStrings.loginTitle,
        subtitle: AppStrings.loginSubtitle,
        footerPrompt: AppStrings.dontHaveAccount,
        footerAction: AppStrings.signup,
        onFooterTap: controller.onSignUp,
        onGetOtp: controller.getOtp,
        validatePhone: controller.validatePhone,
        onToggleTerms: controller.toggleTerms,
      ),
    );
  }
}

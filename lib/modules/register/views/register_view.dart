import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/auth_phone_form.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPhoneForm(
        formKey: controller.formKey,
        phoneController: controller.phoneController,
        agreedToTerms: controller.agreedToTerms,
        isLoading: controller.isLoading,
        title: AppStrings.registerTitle,
        subtitle: AppStrings.loginSubtitle,
        footerPrompt: AppStrings.alreadyHaveAccount,
        footerAction: AppStrings.login,
        onFooterTap: controller.onAlreadyHaveAccount,
        onGetOtp: controller.getOtp,
        validatePhone: controller.validatePhone,
        onToggleTerms: controller.toggleTerms,
      ),
    );
  }
}

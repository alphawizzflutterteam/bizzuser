import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../controllers/signup_controller.dart';
import '../widgets/signup_labeled_field.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(width: 168),
            const SizedBox(height: 20),
            AppText(
              text: AppStrings.signupTitle,
              style: AppTextStyles.loginTitle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            AppText(
              text: AppStrings.signupSubtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: AppDimensions.fontSm,
              ),
            ),
            const SizedBox(height: 20),
            SignupLabeledField(
              label: AppStrings.name,
              controller: controller.nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: controller.validateName,
              hintText: AppStrings.hintFullName,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
            ),
            const SizedBox(height: 12),
            SignupPhoneField(
              controller: controller.phoneController,
              validator: controller.validatePhone,
              readOnly: true,
            ),
            const SizedBox(height: 12),
            SignupLabeledField(
              label: AppStrings.emailOptional,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: controller.validateEmail,
              hintText: AppStrings.hintEmail,
            ),
            const SizedBox(height: 12),
            SignupLabeledField(
              label: AppStrings.referralCodeOptional,
              controller: controller.referralController,
              textInputAction: TextInputAction.done,
              hintText: AppStrings.hintReferralCode,
            ),
            const SizedBox(height: 20),
            Obx(
              () => AppButton(
                title: AppStrings.getStarted,
                isLoading: controller.isLoading.value,
                backgroundColor: AppColors.brandBlack,
                textColor: AppColors.white,
                borderRadius: AppDimensions.radiusMedium,
                height: 48,
                onPressed: controller.getStarted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

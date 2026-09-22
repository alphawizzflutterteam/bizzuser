import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_button.dart';
import 'app_logo.dart';
import 'app_text.dart';
import 'app_text_field.dart';
import 'auth_footer_link.dart';
import 'auth_terms_row.dart';
import 'phone_code_prefix.dart';

class AuthPhoneForm extends StatelessWidget {
  const AuthPhoneForm({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.agreedToTerms,
    required this.isLoading,
    required this.title,
    required this.subtitle,
    required this.footerPrompt,
    required this.footerAction,
    required this.onFooterTap,
    required this.onGetOtp,
    required this.validatePhone,
    required this.onToggleTerms,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final RxBool agreedToTerms;
  final RxBool isLoading;
  final String title;
  final String subtitle;
  final String footerPrompt;
  final String footerAction;
  final VoidCallback onFooterTap;
  final VoidCallback onGetOtp;
  final String? Function(String?) validatePhone;
  final ValueChanged<bool?> onToggleTerms;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(),
          const SizedBox(height: AppDimensions.paddingXLarge),
          AppText(text: title, style: AppTextStyles.loginTitle),
          const SizedBox(height: AppDimensions.paddingSmall),
          AppText(
            text: subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: AppDimensions.fontSm,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXLarge),
          AppText(
            text: AppStrings.mobileNumber,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          AppTextField(
            controller: phoneController,
            hintText: AppStrings.enterMobileNumber,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            fillColor: AppColors.fieldFill,
            borderColor: AppColors.fieldBorder,
            borderRadius: AppDimensions.radiusMedium,
            validator: validatePhone,
            onSubmitted: (_) => onGetOtp(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: AppTextStyles.body.copyWith(
              color: AppColors.brandBlack,
              fontWeight: FontWeight.w500,
            ),
            prefix: const PhoneCodePrefix(),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Obx(
            () => AuthTermsRow(
              value: agreedToTerms.value,
              onChanged: onToggleTerms,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Obx(
            () => AppButton(
              title: AppStrings.getOtp,
              isLoading: isLoading.value,
              backgroundColor: AppColors.brandBlack,
              textColor: AppColors.white,
              borderRadius: AppDimensions.radiusMedium,
              onPressed: onGetOtp,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          AuthFooterLink(
            prompt: footerPrompt,
            action: footerAction,
            onTap: onFooterTap,
          ),
        ],
      ),
    );
  }
}

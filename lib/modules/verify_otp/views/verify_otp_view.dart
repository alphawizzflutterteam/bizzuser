import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../controllers/verify_otp_controller.dart';
import '../widgets/otp_input_row.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(),
          const SizedBox(height: AppDimensions.paddingXLarge),
          AppText(
            text: AppStrings.verificationTitle,
            style: AppTextStyles.loginTitle,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          AppText(
            text: controller.subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: AppDimensions.fontSm,
            ),
          ),
          Obx(() {
            if (controller.displayedOtp.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: AppText(
                text: AppStrings.otpDisplay(controller.displayedOtp.value),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.brandBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
            );
          }),
          const SizedBox(height: AppDimensions.paddingLarge),
          const OtpInputRow(),
          const SizedBox(height: AppDimensions.paddingLarge),
          Obx(
            () => AppButton(
              title: AppStrings.continueText,
              isLoading: controller.isLoading.value,
              backgroundColor: AppColors.brandBlack,
              textColor: AppColors.white,
              borderRadius: AppDimensions.radiusLarge,
              onPressed: controller.onContinue,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: controller.timerLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                TextButton(
                  onPressed:
                      controller.canResend && !controller.isLoading.value
                      ? controller.resendOtp
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandYellow,
                    disabledForegroundColor: AppColors.grey,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: AppText(
                    text: AppStrings.resendOtp,
                    style: AppTextStyles.label.copyWith(
                      color: controller.canResend
                          ? AppColors.brandYellow
                          : AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

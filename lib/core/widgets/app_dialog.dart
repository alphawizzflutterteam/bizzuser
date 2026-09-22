import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_button.dart';
import 'app_text.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> showConfirm({
    required String title,
    required String message,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return Get.dialog<bool>(
      AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      barrierDismissible: false,
    );
  }
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = AppStrings.confirm,
    this.cancelText = AppStrings.cancel,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(text: title, style: AppTextStyles.title),
            const SizedBox(height: AppDimensions.paddingSmall),
            AppText(
              text: message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: cancelText,
                    backgroundColor: AppColors.greyLight,
                    textColor: AppColors.textPrimary,
                    onPressed: () {
                      onCancel?.call();
                      Get.back(result: false);
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: AppButton(
                    title: confirmText,
                    onPressed: () {
                      onConfirm?.call();
                      Get.back(result: true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

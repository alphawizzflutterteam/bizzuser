import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_text.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String? title}) {
    _show(
      title: title ?? AppStrings.success,
      message: message,
      backgroundColor: AppColors.snackbarSuccess,
    );
  }

  static void error(String message, {String? title}) {
    _show(
      title: title ?? AppStrings.error,
      message: message,
      backgroundColor: AppColors.snackbarError,
    );
  }

  static void info(String message, {String? title}) {
    _show(
      title: title ?? AppStrings.info,
      message: message,
      backgroundColor: AppColors.snackbarInfo,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      borderRadius: AppDimensions.radiusMedium,
      duration: const Duration(seconds: 3),
      titleText: AppText(
        text: title,
        style: AppTextStyles.label.copyWith(color: AppColors.white),
      ),
      messageText: AppText(
        text: message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
      ),
    );
  }
}

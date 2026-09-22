import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_snackbar.dart';

class AppUtils {
  AppUtils._();

  static bool _isLoaderVisible = false;

  static void showSuccess(String message, {String? title}) {
    AppSnackbar.success(message, title: title);
  }

  static void showError(String message, {String? title}) {
    AppSnackbar.error(message, title: title);
  }

  static void showInfo(String message, {String? title}) {
    AppSnackbar.info(message, title: title);
  }

  static void showLoader({String? message}) {
    if (_isLoaderVisible) return;
    _isLoaderVisible = true;
    Get.dialog(
      AppFullScreenLoader(message: message),
      barrierDismissible: false,
      barrierColor: AppColors.overlay,
    ).whenComplete(() {
      _isLoaderVisible = false;
    });
  }

  static void hideLoader() {
    if (!_isLoaderVisible) return;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    _isLoaderVisible = false;
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return AppDialog.showConfirm(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static String rupee(num value, {bool decimals = false}) {
    return decimals
        ? '₹${value.toStringAsFixed(2)}'
        : '₹${value.toStringAsFixed(0)}';
  }

  static String groupedRupee(num value) {
    final negative = value < 0;
    var digits = value.abs().round().toString();
    if (digits.length <= 3) {
      return '₹${negative ? '-' : ''}$digits';
    }
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${negative ? '-' : ''}${parts.join(',')},$last3';
  }

  static String maskMobile(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return AppStrings.countryCode;
    }
    final visible = digits.length >= 3
        ? digits.substring(digits.length - 3)
        : digits;
    return '${AppStrings.countryCode} *******$visible';
  }

  static String otpSubtitle(String phone) {
    if (phone.contains('*')) {
      return AppStrings.otpSubtitle(phone);
    }
    return AppStrings.otpSubtitle(maskMobile(phone));
  }
}

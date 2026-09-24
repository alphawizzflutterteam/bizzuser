import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';

class SosConfirmSheet {
  SosConfirmSheet._();

  static Future<bool> show() async {
    final result = await Get.bottomSheet<bool>(
      const SafeArea(top: false, child: _SosConfirmBody()),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.sheetRadius),
        ),
      ),
    );
    return result == true;
  }
}

class _SosConfirmBody extends StatelessWidget {
  const _SosConfirmBody();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            text: AppStrings.sosConfirmTitle,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.brandBlack,
          ),
          const SizedBox(height: 12),
          const AppText(
            text: AppStrings.sosConfirmMessage,
            fontSize: 14,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            height: 1.4,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  title: AppStrings.cancel,
                  outlined: true,
                  borderColor: AppColors.fieldBorder,
                  textColor: AppColors.brandBlack,
                  backgroundColor: AppColors.white,
                  borderRadius: 28,
                  height: 48,
                  onPressed: () => Get.back(result: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  title: AppStrings.sos,
                  backgroundColor: AppColors.sosButton,
                  textColor: AppColors.white,
                  borderRadius: 28,
                  height: 48,
                  onPressed: () => Get.back(result: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../routes/app_routes.dart';

class AuthTermsRow extends StatefulWidget {
  const AuthTermsRow({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  State<AuthTermsRow> createState() => _AuthTermsRowState();
}

class _AuthTermsRowState extends State<AuthTermsRow> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => Get.toNamed(AppRoutes.termsConditions);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => Get.toNamed(AppRoutes.privacyPolicy);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppDimensions.checkboxSize,
          height: AppDimensions.checkboxSize,
          child: Checkbox(
            value: widget.value,
            onChanged: widget.onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side: const BorderSide(color: AppColors.grey, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusSmall / 2,
              ),
            ),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.brandBlack;
              }
              return AppColors.transparent;
            }),
            checkColor: AppColors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: AppDimensions.fontSm,
                height: 1.45,
              ),
              children: [
                const TextSpan(text: AppStrings.agreeToThe),
                TextSpan(
                  text: AppStrings.termsOfService,
                  style: const TextStyle(
                    color: AppColors.brandYellow,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: _termsTap,
                ),
                const TextSpan(text: AppStrings.andSeparator),
                TextSpan(
                  text: AppStrings.privacyPolicy,
                  style: const TextStyle(
                    color: AppColors.brandYellow,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: _privacyTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

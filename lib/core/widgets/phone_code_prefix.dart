import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_text.dart';

class PhoneCodePrefix extends StatelessWidget {
  const PhoneCodePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        0,
        AppDimensions.paddingSmall,
        0,
      ),
      child: AppText(
        text: AppStrings.countryCode,
        style: AppTextStyles.body.copyWith(
          color: AppColors.brandBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

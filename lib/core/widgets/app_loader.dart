import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_text.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = AppDimensions.loaderSize,
    this.color,
    this.strokeWidth = 2.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  factory AppLoader.button({Color? color}) {
    return AppLoader(
      size: AppDimensions.loaderSizeSmall,
      color: color ?? AppColors.white,
      strokeWidth: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: AppColors.overlay,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoader(color: AppColors.white),
              if (message != null) ...[
                const SizedBox(height: AppDimensions.paddingMedium),
                AppText(
                  text: message ?? AppStrings.loading,
                  style: AppTextStyles.body.copyWith(color: AppColors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

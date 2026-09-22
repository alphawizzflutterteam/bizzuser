import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle _base = TextStyle(
    fontFamily: AppFonts.primary,
    color: AppColors.textPrimary,
  );

  static TextStyle get display => _base.copyWith(
    fontSize: AppDimensions.fontDisplay,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static TextStyle get loginTitle => _base.copyWith(
    fontSize: AppDimensions.fontLoginTitle,
    fontWeight: FontWeight.w800,
    color: AppColors.brandBlack,
    height: 1.25,
  );

  static TextStyle get title => _base.copyWith(
    fontSize: AppDimensions.fontXl,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get heading => _base.copyWith(
    fontSize: AppDimensions.fontLg,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get subtitle => _base.copyWith(
    fontSize: AppDimensions.fontMd,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get body => _base.copyWith(
    fontSize: AppDimensions.fontMd,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => _base.copyWith(
    fontSize: AppDimensions.fontSm,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get caption => _base.copyWith(
    fontSize: AppDimensions.fontXs,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle get button => _base.copyWith(
    fontSize: AppDimensions.fontMd,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );

  static TextStyle get label => _base.copyWith(
    fontSize: AppDimensions.fontSm,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}

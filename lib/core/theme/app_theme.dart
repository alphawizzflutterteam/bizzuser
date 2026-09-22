import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_fonts.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.primary,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.surface,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.primary,
          fontSize: AppDimensions.fontLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      textTheme: _textTheme(AppColors.textPrimary, AppColors.textSecondary),
      inputDecorationTheme: _inputDecorationTheme(isDark: false),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: false),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(color: AppColors.greyLight),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        titleTextStyle: AppTextStyles.title,
        contentTextStyle: AppTextStyles.body,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: _inputDecorationTheme(isDark: false),
        textStyle: AppTextStyles.body,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      dividerColor: AppColors.greyLight,
      iconTheme: const IconThemeData(color: AppColors.greyDark),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        modalElevation: 0,
        constraints: BoxConstraints(maxWidth: double.infinity),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.darkSurface,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.primary,
          fontSize: AppDimensions.fontLg,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      textTheme: _textTheme(AppColors.white, AppColors.grey),
      inputDecorationTheme: _inputDecorationTheme(isDark: true),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: true),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(color: AppColors.greyDark),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.white),
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.grey),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: _inputDecorationTheme(isDark: true),
        textStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      dividerColor: AppColors.greyDark,
      iconTheme: const IconThemeData(color: AppColors.grey),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        modalElevation: 0,
        constraints: BoxConstraints(maxWidth: double.infinity),
      ),
    );
  }

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: primaryText),
      headlineMedium: AppTextStyles.title.copyWith(color: primaryText),
      titleLarge: AppTextStyles.title.copyWith(color: primaryText),
      titleMedium: AppTextStyles.heading.copyWith(color: primaryText),
      titleSmall: AppTextStyles.subtitle.copyWith(color: secondaryText),
      bodyLarge: AppTextStyles.body.copyWith(color: primaryText),
      bodyMedium: AppTextStyles.body.copyWith(color: primaryText),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondaryText),
      labelLarge: AppTextStyles.button.copyWith(color: primaryText),
      labelMedium: AppTextStyles.label.copyWith(color: primaryText),
      labelSmall: AppTextStyles.caption.copyWith(color: secondaryText),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) {
    final fill = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.greyDark : AppColors.border;
    final hintColor = isDark ? AppColors.grey : AppColors.textSecondary;

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(color: color),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      hintStyle: AppTextStyles.body.copyWith(color: hintColor),
      labelStyle: AppTextStyles.label.copyWith(color: hintColor),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error),
      disabledBorder: border(AppColors.greyLight),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.greyLight,
        disabledForegroundColor: AppColors.greyDark,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        foregroundColor: isDark ? AppColors.white : AppColors.primary,
        side: BorderSide(
          color: isDark ? AppColors.greyDark : AppColors.primary,
        ),
        textStyle: AppTextStyles.button.copyWith(
          color: isDark ? AppColors.white : AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
    );
  }
}

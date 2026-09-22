import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'app_loader.dart';
import 'app_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.outlined = false,
    this.borderColor,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool outlined;
  final Color? borderColor;

  bool get _canTap => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final fg =
        textColor ??
        (outlined ? AppColors.brandBlack : AppColors.textOnPrimary);
    final bg =
        backgroundColor ?? (outlined ? AppColors.white : AppColors.primary);
    final radius = BorderRadius.circular(
      borderRadius ?? AppDimensions.radiusMedium,
    );
    final child = isLoading
        ? AppLoader.button(color: fg)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: AppDimensions.paddingSmall),
              ],
              Flexible(
                child: AppText(
                  text: title,
                  style: AppTextStyles.button.copyWith(color: fg),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: AppDimensions.paddingSmall),
                suffixIcon!,
              ],
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppDimensions.buttonHeight,
      child: outlined
          ? OutlinedButton(
              onPressed: _canTap ? onPressed : null,
              style: OutlinedButton.styleFrom(
                elevation: 0,
                backgroundColor: bg,
                foregroundColor: fg,
                side: BorderSide(color: borderColor ?? fg),
                shape: RoundedRectangleBorder(borderRadius: radius),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: _canTap ? onPressed : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: bg,
                foregroundColor: fg,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                disabledBackgroundColor: AppColors.greyLight,
                disabledForegroundColor: AppColors.greyDark,
                shape: RoundedRectangleBorder(borderRadius: radius),
              ),
              child: child,
            ),
    );
  }
}

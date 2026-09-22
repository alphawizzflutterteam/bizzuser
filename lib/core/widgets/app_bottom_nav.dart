import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_text.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, AppStrings.homeTitle),
      (
        Icons.assignment_rounded,
        Icons.assignment_outlined,
        AppStrings.ridesTitle,
      ),
      (
        Icons.person_rounded,
        Icons.person_outline_rounded,
        AppStrings.profileTitle,
      ),
    ];

    return Container(
      height: AppDimensions.homeNavHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;
          final iconColor = selected
              ? AppColors.brandYellow
              : AppColors.navInactive;
          final textColor = selected
              ? AppColors.textPrimary
              : AppColors.navInactive;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? items[index].$1 : items[index].$2,
                    color: iconColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: items[index].$3,
                    style: AppTextStyles.caption.copyWith(
                      color: textColor,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

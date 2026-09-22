import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import 'app_text.dart';

class SosChip extends StatelessWidget {
  const SosChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppDimensions.paddingMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.sos,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        ),
        child: AppText(
          text: AppStrings.sos,
          style: AppTextStyles.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class DriverAvatar extends StatelessWidget {
  const DriverAvatar({super.key, this.size, this.imageAsset, this.imageUrl});

  final double? size;
  final String? imageAsset;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final side = size ?? AppDimensions.avatarSize;
    final url = imageUrl?.trim() ?? '';
    final asset = imageAsset ?? AppAssets.driverPhoto;
    Widget fallback() {
      return CircleAvatar(
        radius: side / 2,
        backgroundColor: AppColors.fieldFill,
        child: Icon(
          Icons.person_rounded,
          color: AppColors.brandBlack,
          size: side / 2,
        ),
      );
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          url,
          width: side,
          height: side,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback(),
        ),
      );
    }

    if (imageAsset != null && imageAsset!.isEmpty) {
      return fallback();
    }

    return ClipOval(
      child: Image.asset(
        asset,
        width: side,
        height: side,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      ),
    );
  }
}

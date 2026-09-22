import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 86, this.imagePath, this.onEdit});

  final double size;
  final String? imagePath;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final badge = size * 0.32;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(child: _photo(size)),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Container(
                width: badge,
                height: badge,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: badge * 0.5,
                  color: AppColors.brandYellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(double size) {
    final path = imagePath;
    if (path == null || path.isEmpty) {
      return Image.asset(
        AppAssets.profilePhoto,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(size),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(size),
      );
    }
    if (!kIsWeb) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(size),
      );
    }
    return Image.asset(
      AppAssets.profilePhoto,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(size),
    );
  }

  Widget _fallback(double size) {
    return ColoredBox(
      color: AppColors.fieldFill,
      child: Icon(
        Icons.person_rounded,
        color: AppColors.brandBlack,
        size: size * 0.46,
      ),
    );
  }
}

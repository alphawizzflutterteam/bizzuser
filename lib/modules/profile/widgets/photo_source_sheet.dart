import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';

class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  static void show({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    Get.bottomSheet(
      PhotoSourceSheet(onCamera: onCamera, onGallery: onGallery),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.fieldBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            text: AppStrings.choosePhoto,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.brandBlack,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.brandBlack,
            ),
            title: const AppText(text: AppStrings.camera),
            onTap: onCamera,
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.brandBlack,
            ),
            title: const AppText(text: AppStrings.gallery),
            onTap: onGallery,
          ),
        ],
      ),
    );
  }
}

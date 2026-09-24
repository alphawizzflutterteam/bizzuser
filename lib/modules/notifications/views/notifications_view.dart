import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: AppText(
          text: AppStrings.notificationsTitle,
          style: AppTextStyles.heading,
        ),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        actions: [
          Obx(() {
            if (!controller.hasUnread) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.isMarkingAll.value
                  ? null
                  : controller.markAllRead,
              child: AppText(
                text: AppStrings.markAllRead,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isPageLoading.value) {
          return const AppPageLoader();
        }
        final items = controller.items;
        if (items.isEmpty) {
          return const Center(
            child: AppText(
              text: AppStrings.noNotifications,
              color: AppColors.textHint,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingLarge,
            AppDimensions.paddingSmall,
            AppDimensions.paddingLarge,
            AppDimensions.paddingLarge,
          ),
          itemCount: items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimensions.paddingLarge),
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => controller.openItem(item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          text: item.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: item.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      AppText(
                        text: item.time,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingXSmall),
                  AppText(
                    text: item.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

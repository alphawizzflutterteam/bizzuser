import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class HomeLocationHeader extends GetView<HomeController> {
  const HomeLocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.homeHeaderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ColoredBox(
            color: AppColors.white.withValues(alpha: 0.58),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: AppDimensions.headerPinSize,
                    height: AppDimensions.headerPinSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.brandBlack,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            text: AppStrings.currentLocation,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: AppDimensions.fontXs,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: AppText(
                                  text: controller.headerLocationLabel,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    height: 1.2,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.brandBlack,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.triggerSos,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sos,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        text: AppStrings.sos,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.openNotifications,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Align(
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.brandBlack,
                              size: 24,
                            ),
                          ),
                          Obx(() {
                            if (controller.unreadCount.value <= 0) {
                              return const SizedBox.shrink();
                            }
                            return const Positioned(
                              top: 2,
                              right: 2,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.notificationDot,
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(width: 8, height: 8),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

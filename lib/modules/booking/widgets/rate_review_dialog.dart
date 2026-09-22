import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/controllers/home_controller.dart';

class RateReviewDialog extends StatelessWidget {
  const RateReviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Dialog(
      insetPadding: const EdgeInsets.all(AppDimensions.paddingLarge),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sheetRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: AppStrings.rateAndReview,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: () => controller.setRating(i),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: AppDimensions.starSize,
                            minHeight: AppDimensions.starSize,
                          ),
                          icon: Icon(
                            Icons.star_rounded,
                            size: AppDimensions.starSize,
                            color: i <= controller.rating.value
                                ? AppColors.brandYellow
                                : AppColors.starInactive,
                          ),
                        ),
                    ],
                  ),
                ),
                Obx(
                  () => AppText(
                    text: controller.starCountLabel,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    text: AppStrings.shareReviewOptional,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                AppTextField(
                  controller: controller.reviewController,
                  hintText: AppStrings.reviewHint,
                  maxLines: 3,
                  fillColor: AppColors.white,
                  borderRadius: AppDimensions.radiusLarge,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                AppButton(
                  title: AppStrings.submit,
                  backgroundColor: AppColors.brandBlack,
                  textColor: AppColors.white,
                  borderRadius: AppDimensions.radiusLarge,
                  onPressed: controller.submitReview,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

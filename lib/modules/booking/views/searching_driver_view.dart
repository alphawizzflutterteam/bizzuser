import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../core/widgets/ride_map_backdrop.dart';
import '../controllers/searching_driver_controller.dart';

class SearchingDriverView extends GetView<SearchingDriverController> {
  const SearchingDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.onBackPressed();
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Opacity(
            opacity: 0.16,
            child: RideMapBackdrop(showHalo: false, showRoute: false),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: PillHeader(
                    title: AppStrings.searchingForDriver,
                    onBack: controller.onBackPressed,
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.noDriversAvailable) {
                      return const _NoDriversState();
                    }
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.openBookingDetail,
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36),
                            child: Image(
                              image: AssetImage(AppAssets.searchingDriver),
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: _FindingDriverCard(
                              hint: controller.progressText,
                            ),
                          ),
                          const Spacer(flex: 3),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: AppButton(
                              title: AppStrings.cancelSearch,
                              outlined: true,
                              borderColor: AppColors.error,
                              textColor: AppColors.error,
                              borderRadius: AppDimensions.radiusLarge,
                              isLoading: controller.isCancelling,
                              onPressed: controller.isCancelling
                                  ? null
                                  : controller.cancelSearch,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDriversState extends GetView<SearchingDriverController> {
  const _NoDriversState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: AppColors.brandBlack,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          AppText(
            text: AppStrings.noDriversAvailableTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            text: AppStrings.noDriversAvailableBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 3),
          Obx(
            () => AppButton(
              title: AppStrings.tryAgain,
              backgroundColor: AppColors.brandBlack,
              textColor: AppColors.white,
              borderRadius: AppDimensions.searchButtonRadius,
              isLoading: controller.isRetrying,
              onPressed: controller.isRetrying ? null : controller.retry,
            ),
          ),
          const SizedBox(height: 10),
          AppButton(
            title: AppStrings.backToHome,
            outlined: true,
            borderRadius: AppDimensions.searchButtonRadius,
            onPressed: controller.backToHome,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FindingDriverCard extends StatelessWidget {
  const _FindingDriverCard({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.brandYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.brandBlack,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: AppStrings.findingDriver,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.brandBlack,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                AppText(
                  text: hint,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

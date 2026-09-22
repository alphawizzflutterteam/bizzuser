import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../core/widgets/ride_map_backdrop.dart';
import '../controllers/searching_driver_controller.dart';

class SearchingDriverView extends GetView<SearchingDriverController> {
  const SearchingDriverView({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: PillHeader(title: AppStrings.searchingDriver),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.openBookingDetail,
                    child: const Column(
                      children: [
                        Spacer(flex: 2),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Image(
                            image: AssetImage(AppAssets.searchingDriver),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 28),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _FindingDriverCard(),
                        ),
                        Spacer(flex: 3),
                      ],
                    ),
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

class _FindingDriverCard extends StatelessWidget {
  const _FindingDriverCard();

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
                  text: AppStrings.findingDriverHint,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../rides/views/rides_view.dart';
import '../bindings/dashboard_binding.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  DashboardController get controller {
    DashboardBinding.register();
    return Get.find<DashboardController>();
  }

  @override
  Widget build(BuildContext context) {
    final bottomGap =
        MediaQuery.paddingOf(context).bottom + AppDimensions.homeNavBottomGap;

    return Obx(
      () => Scaffold(
        backgroundColor: controller.tabIndex.value == 2
            ? AppColors.profileWash
            : AppColors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _pageFor(controller.tabIndex.value),
            Positioned(
              left: AppDimensions.homeSheetPadding,
              right: AppDimensions.homeSheetPadding,
              bottom: bottomGap,
              child: AppBottomNav(
                currentIndex: controller.tabIndex.value,
                onTap: controller.changeTab,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageFor(int index) {
    switch (index) {
      case 1:
        return const RidesView();
      case 2:
        return const ProfileView();
      default:
        return const HomeView();
    }
  }
}

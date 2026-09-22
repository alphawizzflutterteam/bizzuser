import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_booking_sheet.dart';
import '../widgets/home_location_header.dart';
import '../widgets/home_map_background.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppPageLoadingGate(
        loading: controller.isPageLoading.value,
        child: Stack(
      fit: StackFit.expand,
      children: [
        const HomeMapBackground(),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.homeSheetPadding,
                AppDimensions.paddingSmall,
                AppDimensions.homeSheetPadding,
                0,
              ),
              child: HomeLocationHeader(),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: HomeBookingSheet(),
        ),
      ],
        ),
      ),
    );
  }
}

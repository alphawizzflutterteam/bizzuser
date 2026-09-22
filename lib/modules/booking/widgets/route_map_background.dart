import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ride_map_backdrop.dart';
import '../../home/controllers/home_controller.dart';
import 'route_trip_map.dart';

class RouteMapBackground extends StatelessWidget {
  const RouteMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      return const RideMapBackdrop(showRoute: true);
    }
    final controller = Get.find<HomeController>();
    return Obx(
      () => RouteTripMap(
        pickup: controller.pickup.value,
        drop: controller.drop.value,
        distance: controller.estimateDistance.value,
      ),
    );
  }
}

class RouteBackButton extends StatelessWidget {
  const RouteBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MapControlButton(icon: Icons.chevron_left_rounded, onTap: onTap);
  }
}

class RouteMapControls extends StatelessWidget {
  const RouteMapControls({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.homeSheetPadding,
          AppDimensions.paddingSmall,
          AppDimensions.homeSheetPadding,
          0,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: RouteBackButton(onTap: onBack),
        ),
      ),
    );
  }
}

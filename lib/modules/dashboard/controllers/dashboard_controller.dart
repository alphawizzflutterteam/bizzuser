import 'package:get/get.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../rides/controllers/rides_controller.dart';

class DashboardController extends GetxController {
  final tabIndex = 0.obs;

  static const ridesTab = 1;

  void changeTab(int index) {
    tabIndex.value = index;
    // Rides list can be stale after a trip changed state elsewhere.
    if (index == ridesTab && Get.isRegistered<RidesController>()) {
      Get.find<RidesController>().refreshRides();
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<RidesController>()) {
      Get.put(RidesController());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }
}

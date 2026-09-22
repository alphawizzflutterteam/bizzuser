import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../rides/controllers/rides_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() => register();

  static void register() {
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut<DashboardController>(DashboardController.new, fenix: true);
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(HomeController.new, fenix: true);
    }
    if (!Get.isRegistered<RidesController>()) {
      Get.lazyPut<RidesController>(RidesController.new, fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(ProfileController.new, fenix: true);
    }
  }
}

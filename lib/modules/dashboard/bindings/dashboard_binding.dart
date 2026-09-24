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
    // Permanent: it holds the booking + live-ride state for the whole session.
    // With lazyPut/fenix, Get.offAllNamed(home) deleted the instance the new
    // home page was using and silently created a second one, so picked
    // pickup/drop locations landed on a different controller than the UI.
    // Deleted explicitly on logout (ProfileController._endSession).
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }
    if (!Get.isRegistered<RidesController>()) {
      Get.lazyPut<RidesController>(RidesController.new, fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(ProfileController.new, fenix: true);
    }
  }
}

import 'package:get/get.dart';

import '../controllers/ride_detail_controller.dart';

class RideDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RideDetailController>(RideDetailController.new);
  }
}

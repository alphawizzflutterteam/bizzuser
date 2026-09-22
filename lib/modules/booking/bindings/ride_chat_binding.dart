import 'package:get/get.dart';

import '../controllers/ride_chat_controller.dart';

class RideChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RideChatController>(RideChatController.new);
  }
}

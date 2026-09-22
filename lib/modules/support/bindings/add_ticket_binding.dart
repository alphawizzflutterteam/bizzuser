import 'package:get/get.dart';

import '../controllers/add_ticket_controller.dart';

class AddTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTicketController>(AddTicketController.new);
  }
}

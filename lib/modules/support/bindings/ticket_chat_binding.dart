import 'package:get/get.dart';

import '../controllers/ticket_chat_controller.dart';

class TicketChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketChatController>(TicketChatController.new);
  }
}

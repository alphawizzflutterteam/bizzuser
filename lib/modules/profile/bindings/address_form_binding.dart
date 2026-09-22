import 'package:get/get.dart';

import '../controllers/address_form_controller.dart';

class AddressFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressFormController>(AddressFormController.new);
  }
}

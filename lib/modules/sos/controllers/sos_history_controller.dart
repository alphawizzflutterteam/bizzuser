import 'package:get/get.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/sos_alert.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../../data/services/sos_service.dart';

class SosHistoryController extends GetxController with PageLoadingMixin {
  final items = <SosAlert>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (!Get.isRegistered<SafetyRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      try {
        final page = await Get.find<SafetyRepository>().fetchHistory();
        items.assignAll(page.items);
      } on ApiException catch (error) {
        AppUtils.showError(error.message);
      }
    });
  }

  void open(SosAlert alert) {
    if (!alert.isOpen || !Get.isRegistered<SosService>()) return;
    Get.find<SosService>().activeSos.value = alert;
    Get.find<SosService>().openActive();
  }
}

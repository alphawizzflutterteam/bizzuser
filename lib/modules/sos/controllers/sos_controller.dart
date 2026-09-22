import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../../data/repositories/safety_catalog.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../../data/services/sos_service.dart';
import '../../home/controllers/home_controller.dart';

class SosController extends GetxController with PageLoadingMixin {
  final selectedReasonId = SafetyCatalog.reasons.first.id.obs;
  final sosNumbers = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSosNumbers();
    stopPageLoading();
  }

  void selectReason(String id) {
    selectedReasonId.value = id;
  }

  Future<bool> submitReport() async {
    final reason = SafetyCatalog.reasons.firstWhere(
      (item) => item.id == selectedReasonId.value,
      orElse: () => SafetyCatalog.reasons.first,
    );
    if (!Get.isRegistered<SafetyRepository>()) {
      AppUtils.showSuccess(AppStrings.reportSubmitted);
      return true;
    }
    var lat = 0.0;
    var lng = 0.0;
    var location = '';
    if (Get.isRegistered<SosService>()) {
      final coords = await Get.find<SosService>().currentLocation();
      lat = coords.$1;
      lng = coords.$2;
      location = coords.$3;
    }
    final message = await runApi(
      () => Get.find<SafetyRepository>().reportSafety(
        rideId: _activeRideId(),
        subject: reason.title,
        message: reason.title,
        lat: lat,
        lng: lng,
        location: location,
      ),
    );
    if (message == null) return false;
    AppUtils.showSuccess(message);
    return true;
  }

  String? _activeRideId() {
    if (Get.isRegistered<HomeController>()) {
      final id = Get.find<HomeController>().liveRide?.id.trim() ?? '';
      if (id.isNotEmpty) return id;
    }
    final rideId = Get.isRegistered<SosService>()
        ? Get.find<SosService>().activeSos.value?.rideId.trim() ?? ''
        : '';
    return rideId.isEmpty ? null : rideId;
  }

  Future<void> _loadSosNumbers() async {
    if (Get.isRegistered<SosService>()) {
      final numbers = Get.find<SosService>().dialNumbers();
      if (numbers.isNotEmpty) {
        sosNumbers.assignAll(numbers);
        return;
      }
    }
    if (Get.isRegistered<AppConfigRepository>()) {
      final config = Get.find<AppConfigRepository>().cached ??
          await Get.find<AppConfigRepository>().fetch();
      sosNumbers.assignAll(config.sosNumbers);
    }
  }
}

class SosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SosController>(SosController.new);
  }
}

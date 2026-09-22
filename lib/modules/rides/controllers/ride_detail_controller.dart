import 'dart:async';

import 'package:get/get.dart';

import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/ride_booking.dart';
import '../../../data/repositories/ride_repository.dart';

class RideDetailController extends GetxController with PageLoadingMixin {
  final ride = Rxn<RideBooking>();
  Timer? _poll;

  String get _rideId {
    final current = ride.value;
    if (current != null && current.id.isNotEmpty) return current.id;
    final args = Get.arguments;
    return args is String ? args : '';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RideBooking) {
      ride.value = args;
    }
    _load();
  }

  Future<void> _load() async {
    final id = _rideId;
    if (!Get.isRegistered<RideRepository>() || id.isEmpty) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      ride.value = await Get.find<RideRepository>().fetchRide(id);
      _startPollIfLive();
    });
  }

  void _startPollIfLive() {
    _poll?.cancel();
    final current = ride.value;
    if (current == null || !current.isLive) return;
    _poll = Timer.periodic(const Duration(seconds: 3), (_) async {
      final id = _rideId;
      if (id.isEmpty || !Get.isRegistered<RideRepository>()) return;
      try {
        ride.value = await Get.find<RideRepository>().fetchRide(id);
        if (ride.value?.isLive != true) {
          _poll?.cancel();
        }
      } catch (_) {}
    });
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}

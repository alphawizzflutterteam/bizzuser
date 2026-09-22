import 'dart:async';

import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/ride_booking.dart';
import '../../home/controllers/home_controller.dart';

class SearchingDriverController extends GetxController {
  Worker? _rideWorker;
  bool _openedDetail = false;

  HomeController? get _home {
    if (!Get.isRegistered<HomeController>()) return null;
    return Get.find<HomeController>();
  }

  @override
  void onReady() {
    super.onReady();
    final home = _home;
    if (home == null) return;
    _onRide(home.activeRide.value);
    _rideWorker = ever<RideBooking?>(home.activeRide, _onRide);
  }

  void openBookingDetail() {
    unawaited(_home?.refreshActiveRide());
    final ride = _home?.activeRide.value;
    if (ride != null && ride.isAssigned) {
      _goToDetail();
    }
  }

  void _onRide(RideBooking? ride) {
    if (ride == null || _openedDetail) return;
    if (ride.isAssigned) {
      _goToDetail();
    }
  }

  void _goToDetail() {
    if (_openedDetail) return;
    _openedDetail = true;
    Get.offNamed(AppRoutes.bookingDetail);
  }

  @override
  void onClose() {
    _rideWorker?.dispose();
    super.onClose();
  }
}

class SearchingDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchingDriverController>(SearchingDriverController.new);
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(HomeController.new, fenix: true);
    }
  }
}

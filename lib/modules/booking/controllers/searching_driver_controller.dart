import 'dart:async';

import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/ride_booking.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../home/controllers/home_controller.dart';

class SearchingDriverController extends GetxController {
  Worker? _rideWorker;

  HomeController? get _home {
    if (!Get.isRegistered<HomeController>()) return null;
    return Get.find<HomeController>();
  }

  /// Progress line from `ride:status searching` (wave / radius / notified).
  String get progressText {
    final text = _home?.searchProgress.value ?? '';
    return text.isNotEmpty ? text : AppStrings.findingDriverHint;
  }

  bool get noDriversAvailable => _home?.noDriversAvailable.value ?? false;

  bool get isRetrying => _home?.isConfirmingBooking.value ?? false;

  bool get isCancelling => _home?.isCancellingRide.value ?? false;

  @override
  void onReady() {
    super.onReady();
    final home = _home;
    if (home == null) return;
    _onRide(home.activeRide.value);
    _rideWorker = ever<RideBooking?>(home.activeRide, _onRide);
  }

  void openBookingDetail() {
    final home = _home;
    if (home == null) return;
    final ride = home.activeRide.value;
    if (ride != null && ride.isAssigned) {
      home.showAssignedRide();
      return;
    }
    // Demo / offline mode keeps the old tap-through behaviour.
    if (!Get.isRegistered<RideRepository>()) {
      Get.offNamed(AppRoutes.bookingDetail);
      return;
    }
    unawaited(home.refreshActiveRide());
  }

  void _onRide(RideBooking? ride) {
    if (ride == null) return;
    if (ride.isAssigned) {
      // Navigation is centralised in HomeController (with a double-push
      // guard shared with resumeActiveRide).
      _home?.showAssignedRide();
    }
  }

  /// Back button / "Cancel search": ask before cancelling instead of silently
  /// returning to the booking overview (which allowed duplicate bookings).
  Future<void> onBackPressed() async {
    final home = _home;
    if (home == null) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    if (home.noDriversAvailable.value) {
      home.exitSearch();
      return;
    }
    await home.cancelSearch();
  }

  Future<void> cancelSearch() => onBackPressed();

  Future<void> retry() async => _home?.retrySearch();

  void backToHome() => _home?.exitSearch();

  @override
  void onClose() {
    _rideWorker?.dispose();
    final home = _home;
    if (home != null && home.noDriversAvailable.value) {
      home.noDriversAvailable.value = false;
    }
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

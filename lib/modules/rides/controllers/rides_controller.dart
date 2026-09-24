import 'dart:async';

import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/ride_booking.dart';
import '../../../data/repositories/ride_catalog.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../home/controllers/home_controller.dart';

class RidesController extends GetxController with PageLoadingMixin {
  final tabIndex = 0.obs;
  final items = <RideBooking>[].obs;

  static const tabs = [
    RideBookingStatus.ongoing,
    RideBookingStatus.completed,
    RideBookingStatus.cancelled,
  ];

  List<RideBooking> get bookings => items.toList(growable: false);

  RideBookingStatus get currentStatus => tabs[tabIndex.value];

  Worker? _liveRideWorker;
  Timer? _refreshDebounce;
  String _liveRideKey = '';

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<RideRepository>()) {
      items.assignAll(_catalogFor(currentStatus));
      stopPageLoading();
      return;
    }
    _watchLiveRide();
    loadRides();
  }

  @override
  void onClose() {
    _liveRideWorker?.dispose();
    _refreshDebounce?.cancel();
    super.onClose();
  }

  /// The live ride moved on (searching → accepted → … → completed / cancelled
  /// or paid): the lists it appears in are stale, so reload the open tab.
  void _watchLiveRide() {
    if (!Get.isRegistered<HomeController>()) return;
    _liveRideWorker = ever<RideBooking?>(
      Get.find<HomeController>().activeRide,
      (ride) {
        final key = ride == null
            ? ''
            : '${ride.id}|${ride.normalizedStatus}|${ride.isPaymentPending}';
        if (key == _liveRideKey) return;
        _liveRideKey = key;
        _refreshDebounce?.cancel();
        _refreshDebounce = Timer(
          const Duration(milliseconds: 600),
          refreshRides,
        );
      },
    );
  }

  /// Reload the open tab in place (no loader or empty state flash when the
  /// list is already showing). Used when the Rides tab is opened again.
  Future<void> refreshRides() async {
    if (!Get.isRegistered<RideRepository>()) return;
    if (items.isEmpty) return loadRides();
    final status = currentStatus;
    try {
      final fetched = await Get.find<RideRepository>().fetchRides(
        status: status.name,
      );
      if (tabIndex.value == tabs.indexOf(status)) {
        items.assignAll(fetched);
      }
    } catch (_) {
      // Keep the current list; pull-to-refresh can retry.
    }
  }

  void changeTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    if (tabIndex.value == index) return;
    tabIndex.value = index;
    if (!Get.isRegistered<RideRepository>()) {
      items.assignAll(_catalogFor(currentStatus));
      stopPageLoading();
      return;
    }
    items.clear();
    loadRides();
  }

  Future<void> loadRides() async {
    final status = currentStatus;
    if (!Get.isRegistered<RideRepository>()) {
      items.assignAll(_catalogFor(status));
      stopPageLoading();
      return;
    }

    await runPageLoad(() async {
      final fetched = await Get.find<RideRepository>().fetchRides(
        status: status.name,
      );
      if (tabIndex.value == tabs.indexOf(status)) {
        items.assignAll(fetched);
      }
    });
  }

  void openBooking(RideBooking booking) {
    if (booking.isCompleted) {
      if (Get.isRegistered<HomeController>()) {
        // Never overwrites a live ride: HomeController decides between the
        // completed/payment screen and the read-only detail page.
        Get.find<HomeController>().openHistoryRide(booking);
        return;
      }
      Get.toNamed(
        AppRoutes.bookingDetail,
        arguments: booking,
        preventDuplicates: false,
      );
      return;
    }
    if (booking.isLive && Get.isRegistered<HomeController>()) {
      // Shared entry point: binds the socket once and guards double pushes.
      Get.find<HomeController>().openLiveRide(booking);
      return;
    }
    Get.toNamed(
      AppRoutes.bookingDetail,
      arguments: booking,
      preventDuplicates: false,
    );
  }

  List<RideBooking> _catalogFor(RideBookingStatus status) {
    return RideCatalog.bookings
        .where((booking) => booking.status == status)
        .toList(growable: false);
  }
}

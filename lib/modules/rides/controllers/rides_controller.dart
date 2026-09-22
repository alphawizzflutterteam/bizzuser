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

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<RideRepository>()) {
      items.assignAll(_catalogFor(currentStatus));
      stopPageLoading();
      return;
    }
    loadRides();
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
        Get.find<HomeController>().activeRide.value = booking;
      }
      Get.toNamed(
        AppRoutes.rideCompleted,
        arguments: booking,
        preventDuplicates: false,
      );
      return;
    }
    if (booking.isLive && Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.activeRide.value = booking;
      home.watchRide(booking.id);
      if (booking.isSearching) {
        Get.toNamed(
          AppRoutes.searchingDriver,
          preventDuplicates: false,
        );
        return;
      }
      Get.toNamed(
        AppRoutes.bookingDetail,
        preventDuplicates: false,
      );
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

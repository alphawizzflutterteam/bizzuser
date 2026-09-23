import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/models/place_suggestion.dart';
import '../../../data/models/location_pick_args.dart';
import '../../../data/models/ride_booking.dart';
import '../../../data/models/ride_coupon.dart';
import '../../../data/models/ride_driver.dart';
import '../../../data/models/ride_estimate.dart';
import '../../../data/models/ride_location.dart';
import '../../../data/models/ride_vehicles_result.dart';
import '../../../data/models/safety_models.dart';
import '../../../data/models/vehicle_category.dart';
import '../../../data/models/vehicle_option.dart';
import '../../../data/models/vehicle_type.dart';
import '../../../data/models/ride_payment.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../data/repositories/ride_catalog.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/services/places_service.dart';
import '../../../data/services/push_notification_service.dart';
import '../../../data/services/razorpay_checkout.dart';
import '../../../data/services/ride_socket_service.dart';
import '../../../data/services/sos_service.dart';
import '../../booking/widgets/cancel_ride_sheet.dart';
import '../../booking/widgets/rate_review_dialog.dart';
import '../../profile/controllers/profile_controller.dart';

class DriverMapPosition {
  const DriverMapPosition({required this.lat, required this.lng});

  final double lat;
  final double lng;

  bool get isValid => lat != 0 || lng != 0;
}

/// Snapshot of the last booking request, used by "Try again" after the
/// server cancelled the search with "No drivers available".
class _BookingRequest {
  const _BookingRequest({
    required this.pickup,
    required this.drop,
    required this.vehicleType,
    required this.paymentMethod,
    required this.couponCode,
  });

  final RideLocation pickup;
  final RideLocation drop;
  final String vehicleType;
  final String paymentMethod;
  final String couponCode;
}

class HomeController extends GetxController with PageLoadingMixin {
  final pickup = const RideLocation(
    title: AppStrings.currentLocationTitle,
    subtitle: '',
  ).obs;
  final drop = const RideLocation(title: '', subtitle: '').obs;
  final usingCurrentPickup = true.obs;
  final selectedCategoryId = RideCatalog.categories[1].id.obs;
  final selectedVehicle = Rxn<VehicleOption>();
  final appliedCoupon = Rxn<RideCoupon>();
  final couponCode = ''.obs;
  final coupons = <RideCoupon>[].obs;
  final isCouponsLoading = false.obs;
  final isApplyingCoupon = false.obs;
  final isLoadingVehicles = false.obs;
  final isEstimating = false.obs;
  final isConfirmingBooking = false.obs;
  final isCancellingRide = false.obs;
  final estimatedDiscount = 0.0.obs;
  final estimatedBaseFare = Rxn<double>();
  final estimatedGst = Rxn<double>();
  final estimatedCgst = Rxn<double>();
  final estimatedSgst = Rxn<double>();
  final estimatedIgst = Rxn<double>();
  final estimatedDistanceFare = Rxn<double>();
  final estimatedWaitingCharge = Rxn<double>();
  final estimatedTotal = Rxn<double>();
  final estimateVehicles = <RideEstimateVehicle>[].obs;
  final rideVehicleOptions = <VehicleOption>[].obs;
  final estimateDistance = ''.obs;
  final activeRide = Rxn<RideBooking>();
  final paymentMethod = 'cash'.obs;
  final isPaying = false.obs;
  final awaitingDriverCash = false.obs;
  final rating = 4.obs;
  final cancelReasons = <SafetyReason>[].obs;
  final cancelReasonId = RideCatalog.cancelReasons.first.id.obs;
  final unreadCount = 1.obs;
  final vehicleTypes = <VehicleType>[].obs;
  final reviewController = TextEditingController();
  final driverPosition = Rxn<DriverMapPosition>();
  final vehiclesLoadFailed = false.obs;

  /// Progress line for the searching screen, fed by `ride:status searching`.
  final searchProgress = ''.obs;

  /// Search ended with "No drivers available" (system cancel).
  final noDriversAvailable = false.obs;

  Timer? _ridePoll;
  Worker? _statusWorker;
  Worker? _paymentWorker;
  Worker? _locationWorker;
  Worker? _notificationWorker;
  Worker? _connectionWorker;
  RazorpayCheckout? _rideCheckout;
  bool _resumingRide = false;
  bool _ratingShown = false;
  String _watchedRideId = '';
  String _userCancellingRideId = '';
  String? _pendingRoute;
  DateTime? _pendingRouteAt;
  _BookingRequest? _lastBookingRequest;

  /// Ride ids whose cancel was already handled (toast + navigation).
  final Set<String> _terminalHandled = <String>{};

  /// Ride ids for which the completed screen was already opened.
  final Set<String> _completedShown = <String>{};

  String get activeRideId => activeRide.value?.id.trim() ?? '';

  List<VehicleOption> get availableVehicles {
    if (rideVehicleOptions.isNotEmpty) {
      return rideVehicleOptions.toList(growable: false);
    }
    final estimated = estimateVehicles.toList();
    final items = _categoryVehicles;
    if (estimated.isEmpty) return items;
    return items
        .map((option) => _withEstimateFare(option, estimated))
        .toList(growable: false);
  }

  List<VehicleOption> get _categoryVehicles {
    if (vehicleTypes.isNotEmpty) {
      return vehicleTypes
          .where((item) => item.id == selectedCategoryId.value)
          .map((item) => item.toOption())
          .toList(growable: false);
    }
    // Live backend: never offer the offline demo catalog (its names are not
    // valid `vehicleType` values). Demo / test mode keeps it.
    if (Get.isRegistered<RideRepository>()) return const [];
    return RideCatalog.vehiclesFor(selectedCategoryId.value);
  }

  List<VehicleCategory> get categories {
    if (vehicleTypes.isNotEmpty) {
      return vehicleTypes.map((item) => item.toCategory()).toList();
    }
    return RideCatalog.categories;
  }

  VehicleOption? get vehicle {
    final options = availableVehicles;
    if (options.isEmpty) return null;
    final selectedId = selectedVehicle.value?.id;
    if (selectedId != null) {
      for (final item in options) {
        if (item.id == selectedId) return item;
      }
    }
    return options.first;
  }

  String get selectedVehicleType {
    final option = vehicle;
    final type = option?.canonicalType.trim() ?? '';
    if (type.isNotEmpty) return type;
    return selectedCategory.title;
  }

  RideBooking? get liveRide => activeRide.value;

  List<RidePaymentOption> get paymentOptions {
    final items = liveRide?.paymentOptions ?? const [];
    if (items.isNotEmpty) return items;
    return RidePaymentOption.defaults;
  }

  bool get isRidePaid => liveRide?.isPaid ?? false;

  RidePaymentOption? get selectedPaymentOption {
    final method = RidePaymentOption.normalize(paymentMethod.value);
    for (final option in paymentOptions) {
      if (option.method == method) return option;
    }
    return null;
  }

  double get baseFare {
    final ride = liveRide;
    if (ride != null && ride.baseFare > 0) return ride.baseFare;
    return estimatedBaseFare.value ?? vehicle?.price ?? 0;
  }

  double get gst {
    final ride = liveRide;
    if (ride != null) return ride.gst;
    return estimatedGst.value ?? 1;
  }

  double get cgst {
    final ride = liveRide;
    if (ride != null && ride.cgst > 0) return ride.cgst;
    return estimatedCgst.value ?? vehicle?.cgst ?? 0;
  }

  double get sgst {
    final ride = liveRide;
    if (ride != null && ride.sgst > 0) return ride.sgst;
    return estimatedSgst.value ?? vehicle?.sgst ?? 0;
  }

  double get igst {
    final ride = liveRide;
    if (ride != null && ride.igst > 0) return ride.igst;
    return estimatedIgst.value ?? vehicle?.igst ?? 0;
  }

  double get distanceFare {
    final ride = liveRide;
    if (ride != null && ride.distanceFare > 0) return ride.distanceFare;
    return estimatedDistanceFare.value ?? vehicle?.distanceFare ?? 0;
  }

  double get waitingCharge {
    final ride = liveRide;
    if (ride != null && ride.waitingCharge > 0) return ride.waitingCharge;
    return estimatedWaitingCharge.value ?? vehicle?.waitingCharge ?? 0;
  }

  double get fareTax {
    final ride = liveRide;
    if (ride != null && ride.gst > 0) return ride.gst;
    return estimatedGst.value ?? vehicle?.tax ?? 0;
  }

  double get discount {
    final ride = liveRide;
    if (ride != null) return ride.discount;
    final coupon = appliedCoupon.value;
    if (coupon == null) return 0;
    if (estimatedDiscount.value > 0) return estimatedDiscount.value;
    return coupon.amountOff(baseFare);
  }

  double get tripDiscount {
    final ride = liveRide;
    if (ride != null) return ride.discount;
    return discount > 0 ? discount : RideCatalog.tripDiscount;
  }

  double get totalAmount {
    final ride = liveRide;
    if (ride != null && ride.total > 0) return ride.total;
    final estimated = estimatedTotal.value;
    if (estimated != null) {
      return estimated < 0 ? 0 : estimated;
    }
    final total = baseFare + gst - discount;
    return total < 0 ? 0 : total;
  }

  double get tripTotal {
    final ride = liveRide;
    if (ride != null && ride.total > 0) return ride.total;
    return totalAmount;
  }

  String get selectedVehicleLabel {
    final ride = liveRide;
    if (ride != null && ride.vehicleLabel.isNotEmpty) {
      return ride.vehicleLabel;
    }
    final option = vehicle;
    if (option == null) return '';
    return '${selectedCategory.title} (${option.name})';
  }

  VehicleCategory get selectedCategory {
    final items = categories;
    return items.firstWhere(
      (item) => item.id == selectedCategoryId.value,
      orElse: () => items.first,
    );
  }

  String? get selectedVehicleImage =>
      selectedCategory.imageAsset ?? vehicle?.imageAsset;

  String get shareOtpText {
    final rideOtp = liveRide?.otp.trim() ?? '';
    var otp = rideOtp;
    if (otp.isEmpty && Get.isRegistered<RideSocketService>()) {
      otp = Get.find<RideSocketService>().lastOtp.value.trim();
    }
    final value = otp.isNotEmpty ? otp : AppStrings.shareOtpValue;
    return '${AppStrings.shareOtpLabel}$value';
  }

  String get bookingIdText {
    final code = liveRide?.bookingCode.trim() ?? '';
    final value = code.isNotEmpty ? code : AppStrings.bookingIdValue;
    return '${AppStrings.bookingIdLabel}$value';
  }

  String get liveBannerText {
    final ride = liveRide;
    if (ride != null) return ride.etaBanner;
    return AppStrings.driverOnTheWayLabel;
  }

  String get liveStatusLabel {
    final ride = liveRide;
    if (ride != null) return ride.liveStatusUiLabel;
    return AppStrings.onTheWay;
  }

  String get liveDistance {
    final rideDistance = liveRide?.distance.trim() ?? '';
    if (rideDistance.isNotEmpty) return rideDistance;
    if (estimateDistance.value.isNotEmpty) return estimateDistance.value;
    return AppStrings.distanceSample;
  }

  RideDriver get liveDriver => liveRide?.driver ?? RideCatalog.driver;

  String get livePlate {
    final plate = liveDriver.vehicleNumber.trim();
    if (plate.isNotEmpty) return plate;
    return RideCatalog.driver.vehicleNumber;
  }

  bool get canCancelLive => liveRide?.canCancel ?? true;

  bool get showLiveOtp {
    final ride = liveRide;
    if (ride == null) return false;
    if (ride.showOtp) return true;
    if (!Get.isRegistered<RideSocketService>()) return false;
    final otp = Get.find<RideSocketService>().lastOtp.value.trim();
    if (otp.isEmpty) return false;
    final status = ride.normalizedStatus;
    return status == 'accepted' || status == 'arrived';
  }

  String get starCountLabel => '${rating.value} ${AppStrings.starLabel}';

  String get headerLocationLabel {
    if (usingCurrentPickup.value) {
      final address = pickup.value.subtitle.trim();
      if (address.isNotEmpty) {
        return address.split(',').take(2).join(', ');
      }
      return AppStrings.currentLocationTitle;
    }
    final city = pickup.value.subtitle.split(',').first.trim();
    if (pickup.value.title.isEmpty) {
      return city.isEmpty ? AppStrings.currentLocationTitle : city;
    }
    if (city.isEmpty) return pickup.value.title;
    return '${pickup.value.title}, $city';
  }

  void clearPickup() {
    usingCurrentPickup.value = true;
    unawaited(_loadCurrentPickup());
  }

  void clearDrop() {
    drop.value = const RideLocation(title: '', subtitle: '');
  }

  void openPickupPicker() {
    Get.toNamed(
      AppRoutes.addressForm,
      arguments: const LocationPickArgs(LocationPickTarget.pickup),
    );
  }

  void openDropPicker() {
    Get.toNamed(
      AppRoutes.addressForm,
      arguments: const LocationPickArgs(LocationPickTarget.drop),
    );
  }

  void applyPickedLocation(LocationPickTarget target, RideLocation location) {
    if (target == LocationPickTarget.pickup) {
      usingCurrentPickup.value = false;
      pickup.value = location;
    } else {
      drop.value = location;
    }
  }

  Future<void> _loadCurrentPickup() async {
    usingCurrentPickup.value = true;
    pickup.value = RideLocation(
      title: AppStrings.currentLocationTitle,
      subtitle: pickup.value.subtitle,
      lat: pickup.value.lat,
      lng: pickup.value.lng,
    );
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!usingCurrentPickup.value) return;

      PlaceDetails? details;
      if (Get.isRegistered<PlacesService>()) {
        details = await Get.find<PlacesService>().reverseGeocode(
          lat: position.latitude,
          lng: position.longitude,
        );
      }
      details ??= Get.isRegistered<PlacesRepository>()
          ? await Get.find<PlacesRepository>().reverse(
              lat: position.latitude,
              lng: position.longitude,
            )
          : null;
      if (!usingCurrentPickup.value) return;

      pickup.value = RideLocation(
        title: AppStrings.currentLocationTitle,
        subtitle: details?.address.trim() ?? '',
        lat: details?.lat ?? position.latitude,
        lng: details?.lng ?? position.longitude,
      );
    } catch (_) {}
  }

  void selectCategory(String id) {
    selectedCategoryId.value = id;
    final options = availableVehicles;
    selectedVehicle.value = options.isEmpty ? null : options.first;
  }

  void selectVehicle(VehicleOption option) {
    selectedVehicle.value = option;
    _applyQuoteBreakdown(option);
  }

  void searchRide() {
    if (!_ensureTripLocations()) return;
    _selectPreferredVehicle();
    Get.toNamed(AppRoutes.vehicleSelect);
    _loadRideVehicles();
  }

  void reviewBooking() {
    if (isLoadingVehicles.value) return;
    if (vehicle == null) {
      AppUtils.showError(AppStrings.vehiclesLoadFailed);
      return;
    }
    _applyQuoteBreakdown(vehicle);
    Get.toNamed(AppRoutes.bookingOverview);
  }

  Future<void> applyCoupon(RideCoupon coupon) async {
    if (isApplyingCoupon.value) return;
    if (!_ensureTripLocations()) return;
    if (!Get.isRegistered<RideRepository>()) {
      _applyLocalCoupon(coupon);
      return;
    }
    isApplyingCoupon.value = true;
    try {
      final estimate = await runApi(
        () => Get.find<RideRepository>().applyCoupon(
          pickup: pickup.value,
          drop: drop.value,
          couponCode: coupon.code,
          vehicleType: selectedVehicleType,
        ),
      );
      if (estimate == null) {
        final fallback = await runApi(
          () => Get.find<RideRepository>().estimate(
            pickup: pickup.value,
            drop: drop.value,
            couponCode: coupon.code,
            vehicleType: selectedVehicleType,
          ),
        );
        if (fallback == null) return;
        _applyLocalCoupon(coupon);
        _applyEstimate(fallback);
        return;
      }
      _applyLocalCoupon(coupon);
      _applyEstimate(estimate);
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  Future<void> applyTypedCoupon(String code) async {
    final value = code.trim();
    if (value.isEmpty) {
      AppUtils.showError(AppStrings.couponInvalid);
      return;
    }
    final matches = coupons.where(
      (item) => item.code.toLowerCase() == value.toLowerCase(),
    );
    if (matches.isNotEmpty) {
      await applyCoupon(matches.first);
      return;
    }
    if (!Get.isRegistered<RideRepository>()) {
      AppUtils.showError(AppStrings.couponInvalid);
      return;
    }
    await applyCoupon(
      RideCoupon(
        code: value.toUpperCase(),
        title: value.toUpperCase(),
        subtitle: '',
        discount: 0,
      ),
    );
  }

  void _applyLocalCoupon(RideCoupon coupon) {
    appliedCoupon.value = coupon;
    couponCode.value = coupon.code;
    AppUtils.showSuccess(AppStrings.couponApplied);
  }

  Future<void> retryLoadVehicles() => _loadRideVehicles();

  Future<void> _loadRideVehicles() async {
    if (!Get.isRegistered<RideRepository>()) return;
    if (isLoadingVehicles.value) return;
    isLoadingVehicles.value = true;
    vehiclesLoadFailed.value = false;
    rideVehicleOptions.clear();
    estimateDistance.value = '';
    try {
      final result = await runApi(
        () => Get.find<RideRepository>().fetchVehicles(
          pickup: pickup.value,
          drop: drop.value,
          category: selectedCategory.title,
        ),
      );
      if (result == null) {
        vehiclesLoadFailed.value = true;
        return;
      }
      _applyRideVehicles(result);
      if (rideVehicleOptions.isEmpty && availableVehicles.isEmpty) {
        vehiclesLoadFailed.value = true;
      }
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  void _applyRideVehicles(RideVehiclesResult result) {
    if (result.distance.isNotEmpty) {
      estimateDistance.value = result.distance;
    }
    pickup.value = _locationFromVehicles(pickup.value, result.pickup);
    drop.value = _locationFromVehicles(drop.value, result.drop);
    final options =
        result.vehicles.map((item) => item.toOption()).toList(growable: false);
    rideVehicleOptions.assignAll(options);
    if (options.isEmpty) return;
    final selectedId = selectedVehicle.value?.id;
    VehicleOption preferred = options.first;
    if (selectedId != null) {
      for (final item in options) {
        if (item.id == selectedId) {
          preferred = item;
          break;
        }
      }
    } else {
      final auto = options.where(
        (item) => item.name.toLowerCase().contains('auto'),
      );
      preferred = auto.isEmpty ? options.first : auto.first;
    }
    selectedVehicle.value = preferred;
    _applyQuoteBreakdown(preferred);
  }

  RideLocation _locationFromVehicles(
    RideLocation current,
    RideLocation next,
  ) {
    if (next.isBlank && !next.hasCoordinates) return current;
    return RideLocation(
      title: next.isBlank ? current.title : next.title,
      subtitle: next.isBlank ? current.subtitle : next.subtitle,
      lat: next.hasCoordinates ? next.lat : current.lat,
      lng: next.hasCoordinates ? next.lng : current.lng,
    );
  }

  void _applyQuoteBreakdown(VehicleOption? option) {
    if (option == null) return;
    if (option.baseFare > 0 || option.total > 0 || option.price > 0) {
      estimatedBaseFare.value =
          option.baseFare > 0 ? option.baseFare : option.price;
      estimatedGst.value = option.tax > 0 ? option.tax : null;
      estimatedCgst.value = option.cgst > 0 ? option.cgst : null;
      estimatedSgst.value = option.sgst > 0 ? option.sgst : null;
      estimatedIgst.value = option.igst > 0 ? option.igst : null;
      estimatedDistanceFare.value =
          option.distanceFare > 0 ? option.distanceFare : null;
      estimatedWaitingCharge.value =
          option.waitingCharge > 0 ? option.waitingCharge : null;
      estimatedDiscount.value = option.discount;
      estimatedTotal.value =
          option.total > 0 ? option.total : option.price;
      if (option.distance.isNotEmpty) {
        estimateDistance.value = option.distance;
      }
      return;
    }
    if (rideVehicleOptions.isNotEmpty) {
      estimatedBaseFare.value = option.price > 0 ? option.price : null;
      estimatedTotal.value = option.price > 0 ? option.price : null;
      estimatedDiscount.value = 0;
      estimatedGst.value = null;
      estimatedCgst.value = null;
      estimatedSgst.value = null;
      estimatedIgst.value = null;
      estimatedDistanceFare.value = null;
      estimatedWaitingCharge.value = null;
      return;
    }
    _syncSelectedEstimate(option);
  }

  void _applyEstimate(RideEstimate estimate) {
    estimateVehicles.assignAll(estimate.vehicles);
    if (estimate.distance.isNotEmpty) {
      estimateDistance.value = estimate.distance;
    }
    final selected = vehicle;
    if (selected != null && estimate.vehicles.isNotEmpty) {
      _syncSelectedEstimate(selected);
      if (estimate.discount > 0) estimatedDiscount.value = estimate.discount;
      if (estimate.total > 0) estimatedTotal.value = estimate.total;
      return;
    }
    estimatedDiscount.value = estimate.discount;
    estimatedBaseFare.value =
        estimate.baseFare > 0 ? estimate.baseFare : null;
    estimatedGst.value = estimate.tax > 0 ? estimate.tax : null;
    estimatedCgst.value = estimate.cgst > 0 ? estimate.cgst : null;
    estimatedSgst.value = estimate.sgst > 0 ? estimate.sgst : null;
    estimatedIgst.value = estimate.igst > 0 ? estimate.igst : null;
    estimatedDistanceFare.value =
        estimate.distanceFare > 0 ? estimate.distanceFare : null;
    estimatedWaitingCharge.value =
        estimate.waitingCharge > 0 ? estimate.waitingCharge : null;
    estimatedTotal.value = estimate.total > 0 ? estimate.total : null;
  }

  void _syncSelectedEstimate(VehicleOption option) {
    for (final item in estimateVehicles) {
      if (!item.matches(option)) continue;
      estimatedDiscount.value = item.discount;
      estimatedBaseFare.value =
          item.baseFare > 0 ? item.baseFare : null;
      estimatedGst.value = item.tax > 0 ? item.tax : null;
      estimatedCgst.value = item.cgst > 0 ? item.cgst : null;
      estimatedSgst.value = item.sgst > 0 ? item.sgst : null;
      estimatedIgst.value = item.igst > 0 ? item.igst : null;
      estimatedDistanceFare.value =
          item.distanceFare > 0 ? item.distanceFare : null;
      estimatedWaitingCharge.value =
          item.waitingCharge > 0 ? item.waitingCharge : null;
      estimatedTotal.value =
          item.displayFare > 0 ? item.displayFare : null;
      return;
    }
  }

  VehicleOption _withEstimateFare(
    VehicleOption option,
    List<RideEstimateVehicle> estimated,
  ) {
    for (final item in estimated) {
      if (!item.matches(option) || item.displayFare <= 0) continue;
      return option.copyWith(
        price: item.displayFare,
        distance: item.distance.isNotEmpty ? item.distance : option.distance,
        eta: item.durationLabel.isNotEmpty ? item.durationLabel : option.eta,
        vehicleType: item.vehicleType.isNotEmpty
            ? item.vehicleType
            : option.vehicleType,
        baseFare: item.baseFare,
        tax: item.tax,
        cgst: item.cgst,
        sgst: item.sgst,
        igst: item.igst,
        distanceFare: item.distanceFare,
        waitingCharge: item.waitingCharge,
        discount: item.discount,
        total: item.displayFare,
      );
    }
    return option;
  }

  /// Pickup + drop must both carry real coordinates before any quote/create
  /// request (no hardcoded fallback city). Returns false and shows a message
  /// when something is missing.
  bool _ensureTripLocations() {
    if (!Get.isRegistered<RideRepository>()) {
      if (drop.value.isBlank) {
        AppUtils.showError(AppStrings.selectDropLocation);
        return false;
      }
      return true;
    }
    if (!pickup.value.hasCoordinates) {
      if (usingCurrentPickup.value) {
        AppUtils.showError(AppStrings.waitingForPickupLocation);
        unawaited(_loadCurrentPickup());
      } else {
        AppUtils.showError(AppStrings.selectPickupLocation);
      }
      return false;
    }
    if (drop.value.isBlank || !drop.value.hasCoordinates) {
      AppUtils.showError(AppStrings.selectDropLocation);
      return false;
    }
    return true;
  }

  /// True when both ends of the trip are usable for a booking request.
  bool get canSearchRide {
    if (!Get.isRegistered<RideRepository>()) return !drop.value.isBlank;
    return pickup.value.hasCoordinates && drop.value.hasCoordinates;
  }

  Future<void> confirmBooking() async {
    if (isConfirmingBooking.value || isEstimating.value) return;
    if (!_ensureTripLocations()) return;
    if (!Get.isRegistered<RideRepository>()) {
      Get.toNamed(AppRoutes.searchingDriver);
      return;
    }
    final type = selectedVehicleType.trim();
    if (vehicle == null || type.isEmpty) {
      AppUtils.showError(AppStrings.vehiclesLoadFailed);
      return;
    }
    // A live ride already exists locally → resume it instead of re-booking.
    final current = liveRide;
    if (current != null && current.id.isNotEmpty && current.isLive) {
      AppUtils.showInfo(AppStrings.resumingActiveRide);
      _routeForRide(current);
      return;
    }
    final request = _BookingRequest(
      pickup: pickup.value,
      drop: drop.value,
      vehicleType: type,
      paymentMethod: paymentMethod.value,
      couponCode: appliedCoupon.value?.code ?? '',
    );
    await _createBooking(request, fromSearchingScreen: false);
  }

  /// "Try again" on the no-drivers state – re-creates the booking with the
  /// same selection while staying on the searching screen.
  Future<void> retrySearch() async {
    if (isConfirmingBooking.value) return;
    final request = _lastBookingRequest;
    if (request == null || !Get.isRegistered<RideRepository>()) {
      exitSearch();
      return;
    }
    await _createBooking(request, fromSearchingScreen: true);
  }

  /// Leaves the searching / no-drivers screen back to home.
  void exitSearch() {
    noDriversAvailable.value = false;
    searchProgress.value = '';
    final ride = liveRide;
    if (ride != null && !ride.isLive) {
      _clearActiveRide();
    }
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _createBooking(
    _BookingRequest request, {
    required bool fromSearchingScreen,
  }) async {
    isConfirmingBooking.value = true;
    try {
      RideBooking ride;
      try {
        ride = await Get.find<RideRepository>().createRide(
          pickup: request.pickup,
          drop: request.drop,
          vehicleType: request.vehicleType,
          paymentMethod: request.paymentMethod,
          couponCode: request.couponCode,
        );
      } on ActiveRideExistsException catch (error) {
        AppUtils.showInfo(AppStrings.resumingActiveRide);
        noDriversAvailable.value = false;
        await openRideById(error.rideId);
        return;
      } on ApiException catch (error) {
        AppUtils.showError(error.message);
        return;
      } catch (_) {
        AppUtils.showError(AppStrings.somethingWentWrong);
        return;
      }
      if (ride.id.isEmpty) {
        AppUtils.showError(AppStrings.somethingWentWrong);
        return;
      }
      _lastBookingRequest = request;
      _ratingShown = false;
      awaitingDriverCash.value = false;
      noDriversAvailable.value = false;
      searchProgress.value = AppStrings.searchingProgress();
      activeRide.value = ride;
      watchRide(ride.id);

      // Online/UPI at booking: assignment waits until verify-payment succeeds.
      final method = RidePaymentOption.normalize(request.paymentMethod);
      if (method == 'online') {
        final paid = await _collectRidePayment();
        if (!paid) {
          AppUtils.showError(AppStrings.unableToStartPayment);
          // Still open searching — server holds assignment until paid.
        }
      }

      if (!fromSearchingScreen && activeRideId == ride.id) {
        _routeForRide(liveRide ?? ride);
      }
    } finally {
      isConfirmingBooking.value = false;
    }
  }

  /// Starts watching [rideId] via the socket. Idempotent for the same ride:
  /// workers are bound once, so re-opening screens never stacks listeners.
  void watchRide(String rideId) {
    final id = rideId.trim();
    if (id.isEmpty) return;
    if (_watchedRideId == id) {
      _syncFallbackPoll();
      return;
    }
    stopWatching();
    _watchedRideId = id;
    _bindSocket(id);
    _syncFallbackPoll();
    unawaited(refreshActiveRide());
  }

  /// REST fallback only while the socket is disconnected (15 s).
  void _syncFallbackPoll() {
    final watching = _watchedRideId.isNotEmpty;
    final connected = Get.isRegistered<RideSocketService>() &&
        Get.find<RideSocketService>().isConnected.value;
    if (!watching || connected) {
      _stopPolling();
      return;
    }
    if (_ridePoll != null) return;
    _ridePoll = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(refreshActiveRide());
    });
  }

  void _onSocketConnectionChanged(bool connected) {
    _syncFallbackPoll();
    // Single catch-up refresh on (re)connect.
    if (connected && _watchedRideId.isNotEmpty) {
      unawaited(refreshActiveRide());
    }
  }

  /// Re-join socket room when opening Booking Detail for the live trip.
  void ensureLiveRideWatch() {
    final id = activeRideId;
    if (id.isEmpty) return;
    watchRide(id);
  }

  void stopWatching() {
    _stopPolling();
    _watchedRideId = '';
    _statusWorker?.dispose();
    _statusWorker = null;
    _paymentWorker?.dispose();
    _paymentWorker = null;
    _locationWorker?.dispose();
    _locationWorker = null;
    driverPosition.value = null;
    if (Get.isRegistered<RideSocketService>()) {
      Get.find<RideSocketService>().leaveRide();
    }
  }

  void _bindSocket(String rideId) {
    if (!Get.isRegistered<RideSocketService>()) return;
    final socket = Get.find<RideSocketService>();
    socket.joinRide(rideId);
    _statusWorker?.dispose();
    _statusWorker = ever<RideStatusEvent?>(socket.lastStatusEvent, (event) {
      if (event == null || event.status.trim().isEmpty) return;
      _applySocketStatus(event);
    });
    _paymentWorker?.dispose();
    _paymentWorker = ever<RidePaymentEvent?>(socket.lastPaymentEvent, (event) {
      if (event == null || event.paymentStatus.trim().isEmpty) return;
      if (event.rideId != activeRideId) return;
      _applySocketPayment(event.paymentStatus);
    });
    _locationWorker?.dispose();
    _locationWorker = ever<DriverLocationEvent?>(socket.lastLocation, (loc) {
      if (loc == null || !loc.isValid || loc.rideId != activeRideId) return;
      // One observable update per GPS sample (no lat/lng half-updates).
      driverPosition.value = DriverMapPosition(lat: loc.lat, lng: loc.lng);
    });
  }

  void _applySocketStatus(RideStatusEvent event) {
    final current = activeRide.value;
    if (current == null || current.id != event.rideId) return;

    final status = event.normalizedStatus;
    var bucket = RideBookingStatus.ongoing;
    if (status == 'cancelled') {
      bucket = RideBookingStatus.cancelled;
    } else if (status == 'completed') {
      bucket = RideBookingStatus.completed;
    }

    RideDriver? driver;
    if (status == 'accepted') {
      final parsed = RideDriver.fromJson(event.driver, vehicle: event.vehicle);
      if (parsed.hasName || parsed.vehicleNumber.isNotEmpty) driver = parsed;
    } else if (status == 'searching') {
      // Driver cancelled after accept → server re-dispatches.
      driver = const RideDriver(
        name: '',
        rating: '',
        phone: '',
        vehicleNumber: '',
      );
      driverPosition.value = null;
    }

    final otp = event.otp.trim().isNotEmpty ? event.otp.trim() : current.otp;
    final next = current.copyWith(
      status: bucket,
      rawStatus: status,
      statusLabel: _labelForRawStatus(status),
      otp: otp,
      driver: driver,
      paymentStatus: event.paymentStatus.isNotEmpty
          ? event.paymentStatus.toLowerCase()
          : current.paymentStatus,
      cancelReason:
          event.reason.isNotEmpty ? event.reason : current.cancelReason,
      total: event.fare ?? current.total,
    );
    activeRide.value = next;

    switch (status) {
      case 'searching':
        searchProgress.value = AppStrings.searchingProgress(
          radiusKm: event.radiusKm,
          driversNotified: event.driversNotified,
        );
        if (current.isAssigned) {
          // Driver dropped the trip – back to the searching screen.
          AppUtils.showInfo(AppStrings.searchingForDriver);
          _routeForRide(next);
        }
        break;
      case 'accepted':
        searchProgress.value = '';
        // Payload normally carries driver + vehicle + otp; only pull REST
        // when something essential is missing.
        if (driver == null || !driver.hasName || otp.isEmpty) {
          unawaited(refreshActiveRide());
        }
        _routeForRide(next);
        break;
      case 'arrived':
      case 'ongoing':
        if (!current.driver.hasName) {
          unawaited(refreshActiveRide());
        }
        _routeForRide(next);
        break;
      default:
        break;
    }

    _handleTerminalStatus(next, cancelledBy: event.cancelledBy);
  }

  void _applySocketPayment(String paymentStatus) {
    final current = activeRide.value;
    if (current == null) return;
    final paid = paymentStatus.trim().toLowerCase() == 'paid';
    activeRide.value = current.copyWith(
      paymentStatus: paymentStatus.trim().toLowerCase(),
    );
    if (paid) {
      awaitingDriverCash.value = false;
      _stopPolling();
      _showRatingIfNeeded();
    }
  }

  String _labelForRawStatus(String status) {
    switch (status) {
      case 'searching':
        return AppStrings.searchingForDriver;
      case 'accepted':
        return AppStrings.driverOnTheWayLabel;
      case 'arrived':
        return AppStrings.driverHasArrived;
      case 'ongoing':
        return AppStrings.tripInProgress;
      case 'completed':
        return AppStrings.rideStatusCompleted;
      case 'cancelled':
        return AppStrings.rideStatusCancelled;
      default:
        return status;
    }
  }

  void _stopPolling() {
    _ridePoll?.cancel();
    _ridePoll = null;
  }

  Future<void> refreshActiveRide() async {
    final id = activeRide.value?.id ?? '';
    if (id.isEmpty || !Get.isRegistered<RideRepository>()) return;
    try {
      final ride = await Get.find<RideRepository>().fetchRide(id);
      // Ride changed / cleared while the request was in flight.
      if (activeRideId != id || ride.id != id) return;
      activeRide.value = ride;
      if (ride.isSearching && searchProgress.value.isEmpty) {
        searchProgress.value = AppStrings.searchingProgress();
      }
      _handleTerminalStatus(ride);
    } catch (_) {}
  }

  /// Rebuilds a booking request from a server ride (e.g. after the app was
  /// restarted mid-search), so "Try again" keeps the same selection.
  static _BookingRequest? _requestFromRide(RideBooking ride) {
    final type = ride.vehicleType.trim();
    if (type.isEmpty ||
        !ride.pickup.hasCoordinates ||
        !ride.drop.hasCoordinates) {
      return null;
    }
    return _BookingRequest(
      pickup: ride.pickup,
      drop: ride.drop,
      vehicleType: type,
      paymentMethod:
          ride.paymentMethod.isNotEmpty ? ride.paymentMethod : 'cash',
      couponCode: ride.couponCode,
    );
  }

  static bool _isNoDriversReason(String reason) {
    return reason.trim().toLowerCase().contains('no driver');
  }

  void _handleTerminalStatus(RideBooking ride, {String cancelledBy = ''}) {
    final id = ride.id;
    if (id.isEmpty) return;
    if (ride.isCancelled) {
      // User-initiated cancel is finished by submitCancelRide / cancelSearch.
      if (_userCancellingRideId == id) return;
      if (!_terminalHandled.add(id)) return;
      final by = cancelledBy.trim().toLowerCase();
      final noDrivers = _isNoDriversReason(ride.cancelReason) ||
          (by == 'system' && !ride.driver.hasName);
      if (noDrivers) {
        _lastBookingRequest = _requestFromRide(ride) ?? _lastBookingRequest;
      }
      _clearActiveRide(keepQuote: noDrivers);
      if (noDrivers) {
        noDriversAvailable.value = true;
        if (Get.currentRoute != AppRoutes.searchingDriver) {
          AppUtils.showInfo(AppStrings.noDriversAvailableBody);
          if (Get.currentRoute != AppRoutes.home) {
            Get.offAllNamed(AppRoutes.home);
          }
          noDriversAvailable.value = false;
        }
        return;
      }
      AppUtils.showInfo(
        ride.cancelReason.isNotEmpty
            ? '${AppStrings.rideCancelled}: ${ride.cancelReason}'
            : AppStrings.rideCancelled,
      );
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    if (ride.isCompleted) {
      _openCompletedOnce(ride);
      if (ride.isPaid) {
        _stopPolling();
        if (awaitingDriverCash.value) {
          awaitingDriverCash.value = false;
          _showRatingIfNeeded();
        }
      }
    }
  }

  /// Pushes the completed / payment screen at most once per ride id, so a
  /// user who navigated away is never dragged back by later events/polls.
  void _openCompletedOnce(RideBooking ride) {
    if (!_completedShown.add(ride.id)) return;
    _navigate(AppRoutes.rideCompleted);
  }

  /// Single navigation entry point for live-ride screens. Guards against
  /// double pushes (resume vs. searching controller vs. socket events).
  void _navigate(String route) {
    final now = DateTime.now();
    final pending = _pendingRoute;
    final pendingAt = _pendingRouteAt;
    if (pending == route &&
        pendingAt != null &&
        now.difference(pendingAt) < const Duration(milliseconds: 800)) {
      return;
    }
    final current = Get.currentRoute;
    if (current == route) return;
    _pendingRoute = route;
    _pendingRouteAt = now;
    final replace = (route == AppRoutes.bookingDetail &&
            current == AppRoutes.searchingDriver) ||
        (route == AppRoutes.searchingDriver &&
            current == AppRoutes.bookingDetail) ||
        (route == AppRoutes.rideCompleted &&
            current == AppRoutes.bookingDetail);
    if (replace) {
      Get.offNamed(route);
    } else {
      Get.toNamed(route);
    }
  }

  /// Routes to the screen matching [ride]'s state (searching, live trip,
  /// completed + unpaid). Used by resume, notifications and socket events.
  void _routeForRide(RideBooking ride) {
    final route = Get.currentRoute;
    if (ride.isSearching) {
      if (route == AppRoutes.searchingDriver) return;
      _navigate(AppRoutes.searchingDriver);
      return;
    }
    if (ride.isAssigned) {
      const liveRoutes = {
        AppRoutes.bookingDetail,
        AppRoutes.rideChat,
        AppRoutes.sosHelp,
        AppRoutes.rideCompleted,
      };
      if (liveRoutes.contains(route)) return;
      _navigate(AppRoutes.bookingDetail);
      return;
    }
    if (ride.isCompleted && ride.isPaymentPending) {
      _openCompletedOnce(ride);
    }
  }

  /// Called by the searching screen when the ride became assigned.
  void showAssignedRide() {
    final ride = liveRide;
    if (ride == null || !ride.isAssigned) return;
    _routeForRide(ride);
  }

  /// Makes [ride] the live ride, starts watching and routes to it.
  void openLiveRide(RideBooking ride) {
    if (ride.id.isEmpty) return;
    noDriversAvailable.value = false;
    activeRide.value = ride;
    watchRide(ride.id);
    _routeForRide(ride);
  }

  /// Loads a ride by id (notification tap / 409 conflict) and routes to it
  /// instead of showing placeholder data.
  Future<void> openRideById(String rideId) async {
    final id = rideId.trim();
    if (id.isEmpty) return;
    if (!Get.isRegistered<RideRepository>()) return;
    final ride = await runApi(() => Get.find<RideRepository>().fetchRide(id));
    if (ride == null || ride.id.isEmpty) return;
    if (ride.isLive || (ride.isCompleted && ride.isPaymentPending)) {
      if (ride.isCompleted) {
        // Explicit request: show the payment screen even if shown before.
        _completedShown.remove(ride.id);
      }
      openLiveRide(ride);
      return;
    }
    // Finished ride → read-only detail page.
    Get.toNamed(
      AppRoutes.bookingDetail,
      arguments: ride,
      preventDuplicates: false,
    );
  }

  Future<void> resumeActiveRide() async {
    if (_resumingRide) return;
    _resumingRide = true;
    try {
      if (Get.isRegistered<RideSocketService>()) {
        Get.find<RideSocketService>().ensureConnected();
      }
      if (!Get.isRegistered<RideRepository>()) return;
      RideBooking? ride;
      try {
        ride = await Get.find<RideRepository>().fetchActive();
      } catch (_) {
        // Offline: keep the current state; the fallback poll takes over.
        return;
      }
      if (ride == null) {
        // Nothing active on the server – resolve what we hold locally once
        // (it may have completed / been cancelled while in background).
        if (activeRideId.isNotEmpty) await refreshActiveRide();
        return;
      }
      final resumable =
          ride.isLive || (ride.isCompleted && ride.isPaymentPending);
      if (!resumable) return;
      if (activeRideId == ride.id) {
        activeRide.value = ride;
        watchRide(ride.id);
        _routeForRide(ride);
        return;
      }
      openLiveRide(ride);
    } finally {
      _resumingRide = false;
    }
  }

  /// Clears every trace of the finished ride so the next booking starts
  /// clean (no stale fares, OTP, driver or socket state).
  void _clearActiveRide({bool keepQuote = false}) {
    stopWatching();
    activeRide.value = null;
    awaitingDriverCash.value = false;
    searchProgress.value = '';
    _userCancellingRideId = '';
    if (keepQuote) return;
    appliedCoupon.value = null;
    couponCode.value = '';
    estimatedDiscount.value = 0;
    estimatedBaseFare.value = null;
    estimatedGst.value = null;
    estimatedCgst.value = null;
    estimatedSgst.value = null;
    estimatedIgst.value = null;
    estimatedDistanceFare.value = null;
    estimatedWaitingCharge.value = null;
    estimatedTotal.value = null;
    estimateVehicles.clear();
  }

  /// Back from the completed screen: once paid, the ride is done locally.
  void leaveCompletedRide() {
    final ride = liveRide;
    if (ride != null && ride.isCompleted && ride.isPaid) {
      _clearActiveRide();
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    Get.back();
  }

  void completeRide() {
    final ride = liveRide;
    if (ride != null && !ride.isCompleted) return;
    Get.toNamed(AppRoutes.rideCompleted);
    unawaited(loadCompletedRide());
  }

  Future<void> loadCompletedRide() async {
    final args = Get.arguments;
    if (args is RideBooking) {
      activeRide.value = args;
    }
    final ride = liveRide;
    final id = ride?.id ?? '';
    _syncPaymentSelection();
    if (id.isEmpty || !Get.isRegistered<RideRepository>()) return;
    // Already on the completed screen for this ride – never push it again.
    _completedShown.add(id);
    try {
      final fetched = await Get.find<RideRepository>().fetchRide(id);
      if (activeRideId != id) return;
      activeRide.value = fetched;
      _syncPaymentSelection();
      if (fetched.isCompleted && fetched.isPaymentPending) {
        watchRide(fetched.id);
      }
    } catch (_) {}
  }

  void _syncPaymentSelection() {
    final options = paymentOptions;
    if (options.isEmpty) return;
    final current = RidePaymentOption.normalize(paymentMethod.value);
    final currentOk = options.any(
      (item) => item.method == current && item.available,
    );
    if (currentOk) return;
    final booked = RidePaymentOption.normalize(liveRide?.paymentMethod ?? '');
    final bookedOk = options.where(
      (item) => item.method == booked && item.available,
    );
    if (bookedOk.isNotEmpty) {
      paymentMethod.value = bookedOk.first.method;
      return;
    }
    final first = options.where((item) => item.available);
    if (first.isNotEmpty) {
      paymentMethod.value = first.first.method;
    }
  }

  void selectPaymentMethod(String method) {
    final value = RidePaymentOption.normalize(method);
    if (value.isEmpty) return;
    RidePaymentOption? option;
    for (final item in paymentOptions) {
      if (item.method == value) {
        option = item;
        break;
      }
    }
    if (option != null && !option.available) {
      if (option.isWallet) {
        Get.toNamed(AppRoutes.wallet);
      }
      return;
    }
    paymentMethod.value = value;
  }

  void openRateReview() {
    if (Get.isDialogOpen == true) return;
    Get.dialog<void>(
      const RateReviewDialog(),
      barrierColor: AppColors.overlay,
    );
  }

  void _showRatingIfNeeded() {
    if (_ratingShown || !isRidePaid) return;
    _ratingShown = true;
    openRateReview();
  }

  Future<void> payNow() async {
    if (isPaying.value || awaitingDriverCash.value) return;
    if (isRidePaid) {
      openRateReview();
      return;
    }
    isPaying.value = true;
    try {
      final done = await _collectRidePayment();
      if (!done) return;
      _showRatingIfNeeded();
    } finally {
      isPaying.value = false;
    }
  }

  Future<bool> _collectRidePayment() async {
    final method = RidePaymentOption.normalize(paymentMethod.value);
    final ride = liveRide;
    if (ride == null ||
        ride.id.isEmpty ||
        !Get.isRegistered<RideRepository>()) {
      if (method == 'cash') {
        awaitingDriverCash.value = true;
      }
      return method != 'online';
    }
    if (ride.isPaid) return true;
    final option = selectedPaymentOption;
    if (option != null && !option.available) {
      AppUtils.showError(
        option.isWallet
            ? AppStrings.walletShortfall
            : AppStrings.unableToStartPayment,
      );
      return false;
    }

    final result = await runApi(
      () => Get.find<RideRepository>().payRide(
        ride.id,
        paymentMethod: method,
      ),
    );
    if (result == null) return false;
    _applyPayResult(result);

    if (result.awaitCash) {
      awaitingDriverCash.value = true;
      watchRide(ride.id);
      AppUtils.showInfo(
        result.message.isNotEmpty
            ? result.message
            : AppStrings.payCashToDriver,
      );
      return false;
    }
    if (result.openRazorpay || method == 'online') {
      final order = result.order;
      if (order == null) {
        AppUtils.showError(AppStrings.unableToStartPayment);
        return false;
      }
      return _payOnline(ride.id, order);
    }
    return result.isDone || isRidePaid;
  }

  void _applyPayResult(RidePayResult result) {
    final current = activeRide.value;
    if (current == null) {
      if (result.ride != null) activeRide.value = result.ride;
      return;
    }
    activeRide.value = current.copyWith(
      paymentMethod: result.paymentMethod.isNotEmpty
          ? result.paymentMethod
          : result.ride?.paymentMethod,
      paymentLabel: result.paymentLabel.isNotEmpty
          ? result.paymentLabel
          : result.ride?.paymentLabel,
      paymentStatus: result.paymentStatus.isNotEmpty
          ? result.paymentStatus
          : result.ride?.paymentStatus,
    );
  }

  Future<String> _resolveRazorpayKey(WalletOrder order) async {
    final fromOrder = order.key.trim();
    if (fromOrder.startsWith('rzp_')) return fromOrder;
    final fromOptions = (
      order.checkoutOptions['key'] ??
          order.checkoutOptions['keyId'] ??
          ''
    ).toString().trim();
    if (fromOptions.startsWith('rzp_')) return fromOptions;
    if (Get.isRegistered<AppConfigRepository>()) {
      final cached =
          Get.find<AppConfigRepository>().cached?.razorpayKey.trim() ?? '';
      if (cached.startsWith('rzp_')) return cached;
    }
    if (Get.isRegistered<WalletRepository>()) {
      final fetched =
          (await Get.find<WalletRepository>().fetchRazorpayKey()).trim();
      if (fetched.startsWith('rzp_')) return fetched;
    }
    return '';
  }

  Future<bool> _payOnline(String rideId, WalletOrder order) async {
    final key = await _resolveRazorpayKey(order);
    if (key.isEmpty) {
      AppUtils.showError(AppStrings.unableToStartPayment);
      return false;
    }

    _rideCheckout ??= RazorpayCheckout();
    isPaying.value = false;
    late final RazorpayPayment payment;
    try {
      payment = await _rideCheckout!.open(_rideCheckoutOptions(order, key));
    } on ApiException catch (error) {
      AppUtils.showError(error.message);
      return false;
    } catch (_) {
      AppUtils.showError(AppStrings.paymentFailed);
      return false;
    } finally {
      isPaying.value = true;
    }

    if (payment.paymentId.isEmpty || payment.signature.isEmpty) {
      AppUtils.showError(AppStrings.paymentFailed);
      return false;
    }

    return _verifyRidePayment(
      rideId,
      razorpayOrderId: payment.orderId.isNotEmpty
          ? payment.orderId
          : order.razorpayOrderId,
      razorpayPaymentId: payment.paymentId,
      razorpaySignature: payment.signature,
    );
  }

  Future<bool> _verifyRidePayment(
    String rideId, {
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final verified = await runApi(
      () => Get.find<RideRepository>().verifyRidePayment(
        id: rideId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      ),
    );
    if (verified == null) return false;
    try {
      final fresh = await Get.find<RideRepository>().fetchRide(rideId);
      activeRide.value = fresh;
    } catch (_) {
      activeRide.value = verified;
    }
    return isRidePaid || verified.isPaid;
  }

  Map<String, dynamic> _rideCheckoutOptions(WalletOrder order, String key) {
    final user = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().user.value
        : null;
    final contact = user == null ? '' : PhoneUtils.localNumber(user.phone);
    final email = user?.email.trim() ?? '';
    final name = user?.name.trim() ?? '';
    final orderId = order.razorpayOrderId;
    final options = <String, dynamic>{
      ...order.checkoutOptions,
      'key': key,
      'amount': order.amountInPaise(tripTotal),
      'currency': order.currency.isNotEmpty ? order.currency : 'INR',
      'name': AppStrings.appName,
      'description': AppStrings.choosePaymentMethod,
      'prefill': {
        if (contact.length == 10) 'contact': contact,
        if (email.isNotEmpty) 'email': email,
        if (name.isNotEmpty) 'name': name,
      },
      'method': const {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },
      'theme': {'color': '#111111'},
    };
    final validOrderId = orderId.isNotEmpty &&
        orderId.startsWith('order_') &&
        !orderId.startsWith('order_dev');
    if (validOrderId) {
      options['order_id'] = orderId;
    } else {
      options.remove('order_id');
    }
    return options;
  }

  void openChat() {
    Get.toNamed(AppRoutes.rideChat, arguments: liveRide);
  }

  void callDriver() {
    final phone = liveDriver.phone.trim();
    final value =
        phone.isNotEmpty ? phone : RideCatalog.driver.phone;
    AppUtils.showInfo('${AppStrings.callingDriver} $value');
  }

  void triggerSos({String? rideId, bool requireRideId = false}) {
    SosService.raiseOrConfirm(rideId: rideId, requireRideId: requireRideId);
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  Future<void> openCancelRide() async {
    await _loadCancelReasons();
    if (cancelReasons.isNotEmpty) {
      cancelReasonId.value = cancelReasons.first.id;
    }
    CancelRideSheet.show();
  }

  void selectCancelReason(String id) {
    cancelReasonId.value = id;
  }

  Future<void> submitCancelRide() async {
    if (isCancellingRide.value) return;
    final ride = liveRide;
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    if (ride == null || ride.id.isEmpty || !Get.isRegistered<RideRepository>()) {
      AppUtils.showInfo(AppStrings.rideCancelled);
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    final reason = _selectedCancelReason();
    await _cancelActiveRide(
      ride,
      reasonId: reason?.id ?? cancelReasonId.value,
      reasonLabel: reason?.title ?? '',
    );
  }

  SafetyReason? _selectedCancelReason() {
    for (final item in cancelReasons) {
      if (item.id == cancelReasonId.value) return item;
    }
    return cancelReasons.isEmpty ? null : cancelReasons.first;
  }

  Future<bool> _cancelActiveRide(
    RideBooking ride, {
    required String reasonId,
    String reasonLabel = '',
  }) async {
    if (isCancellingRide.value) return false;
    isCancellingRide.value = true;
    _userCancellingRideId = ride.id;
    try {
      final result = await runApi(
        () => Get.find<RideRepository>().cancelRide(
          id: ride.id,
          reasonId: reasonId,
          reason: reasonLabel,
        ),
      );
      if (result == null) {
        _userCancellingRideId = '';
        // Ride may have moved on meanwhile (accepted / cancelled by server).
        unawaited(refreshActiveRide());
        return false;
      }
      _terminalHandled.add(ride.id);
      _clearActiveRide();
      noDriversAvailable.value = false;
      AppUtils.showInfo(AppStrings.rideCancelled);
      Get.offAllNamed(AppRoutes.home);
      return true;
    } finally {
      isCancellingRide.value = false;
    }
  }

  /// "Cancel search" on the searching screen (button or back gesture).
  /// Confirms first, then cancels with a default reason from the server list.
  Future<void> cancelSearch() async {
    if (isCancellingRide.value) return;
    final ride = liveRide;
    if (ride == null ||
        ride.id.isEmpty ||
        !Get.isRegistered<RideRepository>()) {
      exitSearch();
      return;
    }
    if (!ride.isSearching) {
      // Driver already assigned – use the regular cancel flow.
      _routeForRide(ride);
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.cancelSearchTitle),
        content: const Text(AppStrings.cancelSearchBody),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.keepSearching),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              AppStrings.yesCancel,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      barrierColor: AppColors.overlay,
    );
    if (confirmed != true) return;
    final current = liveRide;
    if (current == null || current.id != ride.id) return;
    await _loadCancelReasons();
    final reason = _defaultSearchCancelReason();
    await _cancelActiveRide(
      current,
      reasonId: reason?.id ?? '',
      reasonLabel: reason?.title ?? AppStrings.changeInMyPlans,
    );
  }

  SafetyReason? _defaultSearchCancelReason() {
    if (cancelReasons.isEmpty) return null;
    for (final item in cancelReasons) {
      if (item.title.toLowerCase().contains('plan')) return item;
    }
    return cancelReasons.first;
  }

  void cancelRide() {
    if (!canCancelLive) return;
    openCancelRide();
  }

  void setRating(int value) {
    rating.value = value;
  }

  Future<void> submitReview() async {
    final rideId = liveRide?.id ?? '';
    if (rideId.isNotEmpty && Get.isRegistered<RideRepository>()) {
      await runApi(
        () => Get.find<RideRepository>().submitRating(
          rideId: rideId,
          stars: rating.value,
          review: reviewController.text.trim(),
        ),
      );
    }
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    AppUtils.showSuccess(AppStrings.reviewSubmitted);
    _clearActiveRide();
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _loadCancelReasons() async {
    if (!Get.isRegistered<RideRepository>()) {
      cancelReasons.assignAll(RideCatalog.cancelReasons);
      return;
    }
    try {
      final items = await Get.find<RideRepository>().fetchCancelReasons();
      cancelReasons.assignAll(
        items.isNotEmpty ? items : RideCatalog.cancelReasons,
      );
    } catch (_) {
      if (cancelReasons.isEmpty) {
        cancelReasons.assignAll(RideCatalog.cancelReasons);
      }
    }
  }

  void _selectPreferredVehicle() {
    final options = availableVehicles;
    if (options.isEmpty) return;
    final auto = options.where(
      (item) =>
          item.id == 'auto' || item.name.toLowerCase() == 'auto',
    );
    selectedVehicle.value = auto.isEmpty ? options.first : auto.first;
  }

  @override
  void onInit() {
    super.onInit();
    cancelReasons.assignAll(RideCatalog.cancelReasons);
    _selectPreferredVehicle();
    _loadUnreadCount();
    _loadOffers();
    unawaited(_loadCurrentPickup());
    if (!Get.isRegistered<VehicleRepository>()) {
      stopPageLoading();
      return;
    }
    _loadVehicles();
  }

  @override
  void onReady() {
    super.onReady();
    _bindNotificationSocket();
    unawaited(resumeActiveRide());
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().consumeLaunchTap();
    }
  }

  void _bindNotificationSocket() {
    if (!Get.isRegistered<RideSocketService>()) return;
    final socket = Get.find<RideSocketService>();
    _notificationWorker?.dispose();
    _notificationWorker = ever<int>(
      socket.notificationTick,
      (_) => unawaited(_loadUnreadCount()),
    );
    _connectionWorker?.dispose();
    _connectionWorker = ever<bool>(
      socket.isConnected,
      _onSocketConnectionChanged,
    );
  }

  Future<void> _loadOffers() async {
    if (!Get.isRegistered<RideRepository>()) {
      coupons.assignAll(RideCatalog.coupons);
      return;
    }
    isCouponsLoading.value = true;
    try {
      coupons.assignAll(await Get.find<RideRepository>().fetchOffers());
    } catch (_) {
      if (coupons.isEmpty) {
        coupons.assignAll(RideCatalog.coupons);
      }
    } finally {
      isCouponsLoading.value = false;
    }
  }

  Future<void> _loadVehicles() async {
    if (!Get.isRegistered<VehicleRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final items = await Get.find<VehicleRepository>().fetchTypes();
      if (items.isEmpty) return;
      vehicleTypes.assignAll(items);
      final preferred = items.where((item) {
        final value = '${item.name} ${item.shortName}'.toLowerCase();
        return value.contains('3-wheeler') || value.contains('auto');
      });
      selectedCategoryId.value =
          preferred.isEmpty ? items.first.id : preferred.first.id;
      _selectPreferredVehicle();
    });
  }

  Future<void> refreshUnreadCount() => _loadUnreadCount();

  Future<void> _loadUnreadCount() async {
    if (!Get.isRegistered<NotificationRepository>()) return;
    try {
      final feed = await Get.find<NotificationRepository>().fetchNotifications();
      unreadCount.value = feed.unreadCount;
    } catch (_) {}
  }

  @override
  void onClose() {
    stopWatching();
    _notificationWorker?.dispose();
    _notificationWorker = null;
    _connectionWorker?.dispose();
    _connectionWorker = null;
    _rideCheckout?.dispose();
    _rideCheckout = null;
    reviewController.dispose();
    super.onClose();
  }
}

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

  Timer? _ridePoll;
  Worker? _statusWorker;
  Worker? _paymentWorker;
  Worker? _locationWorker;
  Worker? _notificationWorker;
  RazorpayCheckout? _rideCheckout;
  bool _resumingRide = false;
  bool _handlingTerminal = false;
  bool _ratingShown = false;

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
    final otp = liveRide?.otp.trim() ?? '';
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
    return AppStrings.driverOnTheWay;
  }

  String get liveStatusLabel {
    final label = liveRide?.statusLabel.trim() ?? '';
    if (label.isNotEmpty) return label;
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
    if (ride == null) return true;
    return ride.showOtp;
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
    if (drop.value.isBlank) {
      AppUtils.showError(AppStrings.selectDropLocation);
      return;
    }
    _selectPreferredVehicle();
    Get.toNamed(AppRoutes.vehicleSelect);
    _loadRideVehicles();
  }

  void reviewBooking() {
    if (isLoadingVehicles.value) return;
    _applyQuoteBreakdown(vehicle);
    Get.toNamed(AppRoutes.bookingOverview);
  }

  Future<void> applyCoupon(RideCoupon coupon) async {
    if (isApplyingCoupon.value) return;
    if (drop.value.isBlank) {
      AppUtils.showError(AppStrings.selectDropLocation);
      return;
    }
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

  Future<void> _loadRideVehicles() async {
    if (!Get.isRegistered<RideRepository>()) return;
    isLoadingVehicles.value = true;
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
      if (result == null) return;
      _applyRideVehicles(result);
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

  Future<void> confirmBooking() async {
    if (isConfirmingBooking.value || isEstimating.value) return;
    if (drop.value.isBlank) {
      AppUtils.showError(AppStrings.selectDropLocation);
      return;
    }
    if (!Get.isRegistered<RideRepository>()) {
      Get.toNamed(AppRoutes.searchingDriver);
      return;
    }
    isConfirmingBooking.value = true;
    try {
      final ride = await runApi(
        () => Get.find<RideRepository>().createRide(
          pickup: pickup.value,
          drop: drop.value,
          vehicleType: selectedVehicleType,
          paymentMethod: paymentMethod.value,
          couponCode: appliedCoupon.value?.code ?? '',
        ),
      );
      if (ride == null) return;
      _ratingShown = false;
      awaitingDriverCash.value = false;
      activeRide.value = ride;
      watchRide(ride.id);
      Get.toNamed(AppRoutes.searchingDriver);
    } finally {
      isConfirmingBooking.value = false;
    }
  }

  void watchRide(String rideId) {
    final id = rideId.trim();
    if (id.isEmpty) return;
    _stopPolling();
    _bindSocket(id);
    _ridePoll = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(refreshActiveRide());
    });
    unawaited(refreshActiveRide());
  }

  /// Re-join socket room when opening Booking Detail for the live trip.
  void ensureLiveRideWatch() {
    final id = activeRideId;
    if (id.isEmpty) return;
    watchRide(id);
  }

  void stopWatching() {
    _stopPolling();
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
    socket.connect();
    socket.joinRide(rideId);
    _statusWorker?.dispose();
    _statusWorker = ever<String>(socket.lastStatus, (status) {
      if (status.trim().isEmpty) return;
      unawaited(refreshActiveRide());
    });
    _paymentWorker?.dispose();
    _paymentWorker = ever<String>(socket.lastPaymentStatus, (status) {
      if (status.trim().isEmpty) return;
      unawaited(refreshActiveRide());
    });
    _locationWorker?.dispose();
    _locationWorker = everAll([socket.lastLat, socket.lastLng], (_) {
      final lat = socket.lastLat.value;
      final lng = socket.lastLng.value;
      if (lat == 0 && lng == 0) return;
      driverPosition.value = DriverMapPosition(lat: lat, lng: lng);
    });
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
      activeRide.value = ride;
      _handleTerminalStatus(ride);
    } catch (_) {}
  }

  void _handleTerminalStatus(RideBooking ride) {
    if (_handlingTerminal) return;
    if (ride.isCancelled) {
      _handlingTerminal = true;
      stopWatching();
      AppUtils.showInfo(AppStrings.rideCancelled);
      Get.offAllNamed(AppRoutes.home);
      activeRide.value = null;
      _handlingTerminal = false;
      return;
    }
    if (ride.isCompleted) {
      _handlingTerminal = true;
      if (Get.currentRoute != AppRoutes.rideCompleted) {
        Get.toNamed(AppRoutes.rideCompleted);
      }
      if (ride.isPaid) {
        stopWatching();
        if (awaitingDriverCash.value) {
          awaitingDriverCash.value = false;
          _showRatingIfNeeded();
        }
      }
      _handlingTerminal = false;
    }
  }

  Future<void> resumeActiveRide() async {
    if (_resumingRide) return;
    _resumingRide = true;
    try {
      if (Get.isRegistered<RideSocketService>()) {
        Get.find<RideSocketService>().connect(force: true);
      }
      if (!Get.isRegistered<RideRepository>()) return;
      final ride = await runApi(() => Get.find<RideRepository>().fetchActive());
      if (ride == null) {
        final id = activeRideId;
        if (id.isNotEmpty && Get.isRegistered<RideRepository>()) {
          try {
            final detail = await Get.find<RideRepository>().fetchRide(id);
            if (detail.isLive ||
                (detail.isCompleted && detail.isPaymentPending)) {
              activeRide.value = detail;
              watchRide(detail.id);
            }
          } catch (_) {}
        }
        return;
      }
      if (!ride.isLive && !(ride.isCompleted && ride.isPaymentPending)) {
        return;
      }
      activeRide.value = ride;
      watchRide(ride.id);
      final route = Get.currentRoute;
      if (ride.isSearching && route != AppRoutes.searchingDriver) {
        Get.toNamed(AppRoutes.searchingDriver);
      } else if (ride.isAssigned &&
          route != AppRoutes.bookingDetail &&
          route != AppRoutes.rideChat &&
          route != AppRoutes.sosHelp &&
          route != AppRoutes.rideCompleted) {
        Get.toNamed(AppRoutes.bookingDetail);
      } else if (ride.isCompleted &&
          ride.isPaymentPending &&
          route != AppRoutes.rideCompleted) {
        Get.toNamed(AppRoutes.rideCompleted);
      }
    } finally {
      _resumingRide = false;
    }
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
    try {
      final fetched = await Get.find<RideRepository>().fetchRide(id);
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
    isCancellingRide.value = true;
    try {
      final result = await runApi(
        () => Get.find<RideRepository>().cancelRide(
          id: ride.id,
          reasonId: cancelReasonId.value,
        ),
      );
      if (result == null) return;
      stopWatching();
      activeRide.value = result;
      AppUtils.showInfo(AppStrings.rideCancelled);
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isCancellingRide.value = false;
    }
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
    activeRide.value = null;
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
    _notificationWorker?.dispose();
    _notificationWorker = ever<int>(
      Get.find<RideSocketService>().notificationTick,
      (_) => unawaited(_loadUnreadCount()),
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
    _rideCheckout?.dispose();
    _rideCheckout = null;
    reviewController.dispose();
    super.onClose();
  }
}

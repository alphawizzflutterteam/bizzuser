import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../models/chat_message.dart';
import '../models/ride_booking.dart';
import '../models/ride_coupon.dart';
import '../models/ride_driver.dart';
import '../models/ride_location.dart';
import '../models/safety_models.dart';
import '../models/vehicle_category.dart';
import '../models/vehicle_option.dart';

class RideCatalog {
  RideCatalog._();

  static const RideLocation defaultPickup = RideLocation(
    title: AppStrings.pickupDefaultTitle,
    subtitle: AppStrings.pickupDefaultSubtitle,
    lat: 22.7533,
    lng: 75.8937,
  );

  static const RideLocation defaultDrop = RideLocation(
    title: AppStrings.dropDefaultTitle,
    subtitle: AppStrings.dropDefaultSubtitle,
    lat: 22.9623,
    lng: 76.0508,
  );

  static const List<VehicleCategory> categories = [
    VehicleCategory(
      id: 'two',
      title: AppStrings.twoWheeler,
      subtitle: AppStrings.quickAffordable,
      icon: Icons.two_wheeler_rounded,
      imageAsset: AppAssets.vehicleBike,
    ),
    VehicleCategory(
      id: 'three',
      title: AppStrings.threeWheeler,
      subtitle: AppStrings.comfortableRides,
      icon: Icons.electric_rickshaw,
      imageAsset: AppAssets.vehicleAuto,
    ),
    VehicleCategory(
      id: 'four',
      title: AppStrings.fourWheeler,
      subtitle: AppStrings.spaciousLuxury,
      icon: Icons.directions_car_filled_rounded,
      imageAsset: AppAssets.vehicleCar,
    ),
  ];

  static List<VehicleOption> vehiclesFor(String categoryId) {
    switch (categoryId) {
      case 'two':
        return const [
          VehicleOption(
            id: 'bike',
            name: AppStrings.vehicleBike,
            subtitle: AppStrings.quickAffordable,
            price: 39,
            icon: Icons.two_wheeler_rounded,
            eta: AppStrings.etaSample,
            distance: AppStrings.distanceSample,
          ),
        ];
      case 'four':
        return const [
          VehicleOption(
            id: 'mini',
            name: AppStrings.vehicleMini,
            subtitle: AppStrings.comfortableRide,
            price: 99,
            icon: Icons.directions_car_filled_rounded,
            eta: AppStrings.etaSample,
            distance: AppStrings.distanceSample,
          ),
        ];
      default:
        return const [
          VehicleOption(
            id: 'toto',
            name: AppStrings.vehicleToto,
            subtitle: AppStrings.everydayAffordableRide,
            price: 59,
            icon: Icons.airport_shuttle_rounded,
            eta: AppStrings.etaSample,
            distance: AppStrings.distanceSample,
            imageAsset: AppAssets.vehicleToto,
          ),
          VehicleOption(
            id: 'auto',
            name: AppStrings.vehicleAuto,
            subtitle: AppStrings.comfortableRide,
            price: 49,
            icon: Icons.electric_rickshaw,
            eta: AppStrings.etaSample,
            distance: AppStrings.distanceSample,
            badge: AppStrings.dropTimeBadge,
            imageAsset: AppAssets.vehicleAutoOption,
          ),
        ];
    }
  }

  static const List<RideCoupon> coupons = [
    RideCoupon(
      code: AppStrings.couponFirst50,
      title: AppStrings.couponFirst50,
      subtitle: AppStrings.couponFirst50Hint,
      discount: 50,
    ),
    RideCoupon(
      code: AppStrings.couponSave50,
      title: AppStrings.couponFirst50,
      subtitle: AppStrings.couponFirst50Hint,
      discount: 50,
    ),
    RideCoupon(
      code: AppStrings.couponWelcome50,
      title: AppStrings.couponFirst50,
      subtitle: AppStrings.couponFirst50Hint,
      discount: 50,
    ),
    RideCoupon(
      code: AppStrings.couponRide50,
      title: AppStrings.couponFirst50,
      subtitle: AppStrings.couponFirst50Hint,
      discount: 50,
    ),
  ];

  static const RideDriver driver = RideDriver(
    name: AppStrings.driverName,
    rating: AppStrings.driverRating,
    phone: AppStrings.driverPhone,
    vehicleNumber: AppStrings.vehicleNumber,
    photoAsset: AppAssets.driverPhoto,
  );

  static const List<RideBooking> bookings = [
    RideBooking(
      id: AppStrings.bookingIdValue,
      status: RideBookingStatus.ongoing,
      statusLabel: AppStrings.onTheWay,
      pickup: defaultPickup,
      drop: defaultDrop,
      distance: AppStrings.distanceSample,
      driver: driver,
      vehicleLabel: '${AppStrings.threeWheeler} (${AppStrings.vehicleAuto})',
    ),
  ];

  static const double tripDiscount = 10;

  static const List<ChatMessage> chatThread = [
    ChatMessage(
      text: AppStrings.chatIncomingOne,
      isMine: false,
      time: AppStrings.chatTime,
    ),
    ChatMessage(
      text: AppStrings.chatOutgoingOne,
      isMine: true,
      time: AppStrings.chatTime,
    ),
    ChatMessage(
      text: AppStrings.chatIncomingTwo,
      isMine: false,
      time: AppStrings.chatTime,
    ),
  ];

  static const List<SafetyReason> cancelReasons = [
    SafetyReason(
      id: 'driver_long',
      title: AppStrings.driverTakingTooLong,
      icon: Icons.access_time_rounded,
    ),
    SafetyReason(
      id: 'plans',
      title: AppStrings.changeInMyPlans,
      icon: Icons.location_on_outlined,
    ),
    SafetyReason(
      id: 'fare',
      title: AppStrings.fareTooHigh,
      icon: Icons.currency_rupee,
    ),
    SafetyReason(
      id: 'safety',
      title: AppStrings.safetyConcerns,
      icon: Icons.location_on_outlined,
    ),
    SafetyReason(
      id: 'other',
      title: AppStrings.otherReason,
      icon: Icons.more_horiz_rounded,
    ),
  ];

  static IconData cancelReasonIcon(String label) {
    final value = label.toLowerCase();
    if (value.contains('long') || value.contains('time')) {
      return Icons.access_time_rounded;
    }
    if (value.contains('fare') || value.contains('high')) {
      return Icons.currency_rupee;
    }
    if (value.contains('safety')) {
      return Icons.location_on_outlined;
    }
    if (value.contains('other')) {
      return Icons.more_horiz_rounded;
    }
    if (value.contains('plan')) {
      return Icons.location_on_outlined;
    }
    return Icons.more_horiz_rounded;
  }
}

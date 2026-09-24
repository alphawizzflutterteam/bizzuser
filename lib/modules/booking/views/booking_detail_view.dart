import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/fare_details.dart';
import '../../../core/widgets/ride_chips.dart';
import '../../../data/models/ride_booking.dart';
import '../../home/controllers/home_controller.dart';
import '../../rides/views/ride_detail_view.dart';
// In-app map replaced by the Track button (opens Google Maps).
// import '../widgets/route_trip_map.dart';

class BookingDetailView extends StatelessWidget {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args is RideBooking) {
      return const RideDetailPage();
    }
    return const HomeBookingDetailView();
  }
}

class HomeBookingDetailView extends StatefulWidget {
  const HomeBookingDetailView({super.key});

  @override
  State<HomeBookingDetailView> createState() => _HomeBookingDetailViewState();
}

class _HomeBookingDetailViewState extends State<HomeBookingDetailView> {
  HomeController get controller => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().ensureLiveRideWatch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldFill,
      appBar: AppBar(
        title: AppText(
          text: AppStrings.bookingDetail,
          style: AppTextStyles.heading,
        ),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        actions: [
          Obx(() {
            // Only once a driver is assigned (accepted / arrived / ongoing).
            final ride = controller.liveRide;
            if (ride == null || !ride.isAssigned) {
              return const SizedBox.shrink();
            }
            return Center(child: TrackChip(onTap: controller.trackDriver));
          }),
          SosChip(onTap: () => controller.triggerSos(requireRideId: true)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            // In-app map replaced by the Track button in the app bar, which
            // opens Google Maps with the driver's live position.
            // Obx(() {
            //   final ride = controller.liveRide;
            //   final pos = controller.driverPosition.value;
            //   if (ride == null) return const SizedBox.shrink();
            //   return ClipRRect(
            //     borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            //     child: SizedBox(
            //       height: 220,
            //       width: double.infinity,
            //       child: RouteTripMap(
            //         pickup: ride.pickup,
            //         drop: ride.drop,
            //         distance: ride.distance,
            //         driverLat: pos?.lat,
            //         driverLng: pos?.lng,
            //       ),
            //     ),
            //   );
            // }),
            // const SizedBox(height: AppDimensions.paddingMedium),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.brandYellow,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusXLarge,
                ),
              ),
              child: Obx(
                () => AppText(
                  text: controller.liveBannerText,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.brandBlack,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Obx(() {
              if (!controller.showLiveOtp) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                      border: Border.all(color: AppColors.brandYellow),
                    ),
                    child: AppText(
                      text: controller.shareOtpText,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.brandYellow,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppDimensions.paddingMedium),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => AppText(
                            text: controller.bookingIdText,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: AppDimensions.paddingXSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXLarge,
                          ),
                        ),
                        child: Obx(
                          () => AppText(
                            text: controller.liveStatusLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.brandYellow,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _TripLocations(controller: controller),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppStrings.vehicleDetails,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Obx(() {
                    final vehicle = controller.vehicle;
                    final plate = controller.livePlate;
                    final driver = controller.liveDriver;
                    // Real vehicle details only (model / colour from the
                    // assigned driver) – no placeholder copy.
                    final details = [
                      driver.vehicleModel.trim(),
                      driver.vehicleColor.trim(),
                    ].where((item) => item.isNotEmpty).join(' · ');
                    if (vehicle == null) return const SizedBox.shrink();
                    return Row(
                      children: [
                        Container(
                          width: AppDimensions.vehicleThumbWidth,
                          height: AppDimensions.vehicleThumbHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.fieldFill,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            vehicle.icon,
                            color: AppColors.brandBlack,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: controller.selectedVehicleLabel,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (details.isNotEmpty)
                                AppText(
                                  text: details,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        AppText(
                          text: plate.isNotEmpty ? plate : '–',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppStrings.driverDetails,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Obx(() {
                    final driver = controller.liveDriver;
                    return Row(
                    children: [
                      DriverAvatar(
                        imageAsset: driver.photoAsset ?? '',
                        imageUrl: driver.photoUrl.isNotEmpty
                            ? driver.resolvedPhoto
                            : null,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: driver.hasName
                                  ? driver.name
                                  : AppStrings.yourDriver,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (driver.rating.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: AppDimensions.iconSizeSmall,
                                    color: AppColors.brandYellow,
                                  ),
                                  const SizedBox(width: 2),
                                  AppText(
                                    text: driver.rating,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      CircleIconButton(
                        icon: Icons.call_outlined,
                        onTap: controller.callDriver,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      CircleIconButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: controller.openChat,
                      ),
                    ],
                  );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Obx(
              () => FareDetailsCard(
                baseFare: controller.baseFare,
                gst: controller.fareTax,
                cgst: controller.cgst,
                sgst: controller.sgst,
                igst: controller.igst,
                distanceFare: controller.distanceFare,
                waitingCharge: controller.waitingCharge,
                discount: controller.tripDiscount,
                total: controller.tripTotal,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            AppDimensions.paddingSmall,
            AppDimensions.paddingMedium,
            AppDimensions.paddingMedium,
          ),
          child: Obx(
            () => AppButton(
              title: AppStrings.cancelRide,
              outlined: true,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              borderRadius: AppDimensions.radiusLarge,
              enabled: controller.canCancelLive,
              isLoading: controller.isCancellingRide.value,
              onPressed: controller.canCancelLive
                  ? controller.cancelRide
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _TripLocations extends StatelessWidget {
  const _TripLocations({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Prefer the ride's own addresses (resume / notification after the
      // booking form was reset), then the booking form.
      final ride = controller.liveRide;
      final pickup = ride != null && !ride.pickup.isBlank
          ? ride.pickup
          : controller.pickup.value;
      final drop =
          ride != null && !ride.drop.isBlank ? ride.drop : controller.drop.value;
      return Column(
        children: [
          _LocationLine(
            label: AppStrings.pickupLocation,
            title: pickup.routeLine,
            icon: Icons.radio_button_checked,
            iconColor: AppColors.brandYellow,
            trailing: controller.liveDistance,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _LocationLine(
            label: AppStrings.dropLocation,
            title: drop.routeLine,
            icon: Icons.location_on_rounded,
            iconColor: AppColors.brandBlack,
          ),
        ],
      );
    });
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.label,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });

  final String label;
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: AppDimensions.iconSizeSmall + 2),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              AppText(
                text: title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (trailing != null)
          AppText(
            text: trailing!,
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
      ],
    );
  }
}

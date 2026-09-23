import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/fare_details.dart';
import '../../../core/widgets/ride_chips.dart';
import '../../home/controllers/home_controller.dart';
import '../widgets/payment_method_sheet.dart';

class RideCompletedView extends StatefulWidget {
  const RideCompletedView({super.key});

  @override
  State<RideCompletedView> createState() => _RideCompletedViewState();
}

class _RideCompletedViewState extends State<RideCompletedView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadCompletedRide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.leaveCompletedRide();
      },
      child: _buildScaffold(controller),
    );
  }

  Widget _buildScaffold(HomeController controller) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: AppText(
          text: AppStrings.rideCompleted,
          style: AppTextStyles.heading,
        ),
        leading: IconButton(
          onPressed: controller.leaveCompletedRide,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingMedium,
          0,
          AppDimensions.paddingMedium,
          AppDimensions.paddingMedium,
        ),
        child: Column(
          children: [
            Image.asset(
              AppAssets.rideCompleted,
              height: 120,
              width: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AppText(
              text: AppStrings.rideCompletedTitle,
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            AppText(
              text: AppStrings.rideCompletedHint,
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Obx(() {
                        final driver = controller.liveDriver;
                        return DriverAvatar(
                          imageAsset: driver.photoAsset ?? '',
                          imageUrl: driver.photoUrl.isNotEmpty
                              ? driver.resolvedPhoto
                              : null,
                        );
                      }),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              final driver = controller.liveDriver;
                              return AppText(
                                text: driver.hasName
                                    ? driver.name
                                    : AppStrings.yourDriver,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            }),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: AppDimensions.iconSizeSmall,
                                  color: AppColors.brandYellow,
                                ),
                                const SizedBox(width: 2),
                                Obx(() {
                                  final driver = controller.liveDriver;
                                  return AppText(
                                    text: driver.rating.isNotEmpty
                                        ? driver.rating
                                        : '–',
                                    style: AppTextStyles.caption,
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(
                            () => AppText(
                              text: controller.selectedVehicleLabel,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Obx(
                            () => AppText(
                              text: controller.livePlate,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Obx(() {
                    final ride = controller.liveRide;
                    return _CompletedRoute(
                      pickup: ride != null && ride.pickup.routeLine.isNotEmpty
                          ? ride.pickup.routeLine
                          : '${controller.pickup.value.title}, ${controller.pickup.value.subtitle}',
                      drop: ride != null && ride.drop.routeLine.isNotEmpty
                          ? ride.drop.routeLine
                          : '${controller.drop.value.title}, ${controller.drop.value.subtitle}',
                      distance: controller.liveDistance,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Obx(
              () => FareDetailsCard(
                showIcon: true,
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
      bottomNavigationBar: const PaymentMethodPanel(),
    );
  }
}

class _CompletedRoute extends StatelessWidget {
  const _CompletedRoute({
    required this.pickup,
    required this.drop,
    required this.distance,
  });

  final String pickup;
  final String drop;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.radio_button_checked,
              color: AppColors.brandYellow,
              size: AppDimensions.iconSizeSmall,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppStrings.pickupLocation,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  AppText(
                    text: pickup,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AppText(
              text: distance,
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.brandBlack,
              size: AppDimensions.iconSizeSmall,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppStrings.dropLocation,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  AppText(
                    text: drop,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

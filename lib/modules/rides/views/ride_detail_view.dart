import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/services/sos_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/fare_details.dart';
import '../../../core/widgets/ride_chips.dart';
import '../../../data/models/ride_booking.dart';
import '../controllers/ride_detail_controller.dart';

class RideDetailPage extends GetView<RideDetailController> {
  const RideDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPageLoading.value) {
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
          ),
          body: const AppPageLoader(),
        );
      }
      final ride = controller.ride.value;
      if (ride == null) {
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
          ),
          body: const AppPageLoader(),
        );
      }
      return RideDetailView(ride: ride);
    });
  }
}

class RideDetailView extends StatelessWidget {
  const RideDetailView({super.key, required this.ride});

  final RideBooking ride;

  @override
  Widget build(BuildContext context) {
    final driverName = ride.driverDisplayName;
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
          SosChip(
            onTap: () => SosService.raiseOrConfirm(
              rideId: ride.id,
              requireRideId: true,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
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
              child: AppText(
                text: ride.statusLabel,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.brandBlack,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (ride.showOtp) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  border: Border.all(color: AppColors.brandYellow),
                ),
                child: AppText(
                  text: '${AppStrings.shareOtpLabel}${ride.otp}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.brandYellow,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.paddingMedium),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text:
                              '${AppStrings.bookingIdLabel}${ride.bookingCode}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
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
                        child: AppText(
                          text: ride.statusLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.brandYellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _LocationLine(
                    label: AppStrings.pickupLocation,
                    title: ride.pickup.routeLine,
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.brandYellow,
                    trailing: ride.distance.isEmpty ? null : ride.distance,
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  _LocationLine(
                    label: AppStrings.dropLocation,
                    title: ride.drop.routeLine,
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.brandBlack,
                  ),
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
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: ride.vehicleLabel,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (ride.driver.vehicleNumber.isNotEmpty)
                        AppText(
                          text: ride.driver.vehicleNumber,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
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
                  Row(
                    children: [
                      DriverAvatar(
                        imageAsset: ride.driver.photoAsset ?? '',
                        imageUrl: ride.driver.photoUrl.isNotEmpty
                            ? ride.driver.resolvedPhoto
                            : null,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: driverName,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (ride.driver.rating.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: AppDimensions.iconSizeSmall,
                                    color: AppColors.brandYellow,
                                  ),
                                  const SizedBox(width: 2),
                                  AppText(
                                    text: ride.driver.rating,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (ride.driver.phone.isNotEmpty)
                        CircleIconButton(
                          icon: Icons.call_outlined,
                          onTap: () => AppUtils.showInfo(
                            '${AppStrings.callingDriver} ${ride.driver.phone}',
                          ),
                        ),
                      if (ride.id.isNotEmpty) ...[
                        if (ride.driver.phone.isNotEmpty)
                          const SizedBox(width: AppDimensions.paddingSmall),
                        CircleIconButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: () => Get.toNamed(
                            AppRoutes.rideChat,
                            arguments: ride,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (ride.total > 0 || ride.baseFare > 0) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              FareDetailsCard(
                baseFare: ride.baseFare,
                gst: ride.gst,
                cgst: ride.cgst,
                sgst: ride.sgst,
                igst: ride.igst,
                distanceFare: ride.distanceFare,
                waitingCharge: ride.waitingCharge,
                discount: ride.discount,
                total: ride.total,
              ),
            ],
          ],
        ),
      ),
    );
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

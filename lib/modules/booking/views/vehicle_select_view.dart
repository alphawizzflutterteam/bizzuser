import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/ride_location.dart';
import '../../../data/models/vehicle_option.dart';
import '../../home/controllers/home_controller.dart';
import '../widgets/route_map_background.dart';

class VehicleSelectView extends GetView<HomeController> {
  const VehicleSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RouteMapBackground(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RouteMapControls(onBack: Get.back),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _VehicleSelectSheet(),
          ),
        ],
      ),
    );
  }
}

class _VehicleSelectSheet extends GetView<HomeController> {
  const _VehicleSelectSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.homeSheetPadding,
        22,
        AppDimensions.homeSheetPadding,
        16 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.sheetRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => _RouteLocationCard(
              pickup: controller.pickup.value,
              drop: controller.drop.value,
              distance: controller.estimateDistance.value,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.isLoadingVehicles.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: AppPageLoader(),
              );
            }
            final options = controller.availableVehicles;
            if (options.isEmpty && controller.vehiclesLoadFailed.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    AppText(
                      text: AppStrings.vehiclesLoadFailed,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      title: AppStrings.retry,
                      backgroundColor: AppColors.brandBlack,
                      textColor: AppColors.white,
                      borderRadius: AppDimensions.searchButtonRadius,
                      onPressed: controller.retryLoadVehicles,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final option in options) ...[
                  _VehicleOptionTile(
                    option: option,
                    selected: controller.vehicle?.id == option.id,
                    onTap: () => controller.selectVehicle(option),
                  ),
                  const SizedBox(height: 10),
                ],
                AppButton(
                  title: AppStrings.reviewBooking,
                  backgroundColor: AppColors.brandBlack,
                  textColor: AppColors.white,
                  borderRadius: AppDimensions.searchButtonRadius,
                  onPressed: options.isEmpty ? null : controller.reviewBooking,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _RouteLocationCard extends StatelessWidget {
  const _RouteLocationCard({
    required this.pickup,
    required this.drop,
    this.distance = '',
  });

  final RideLocation pickup;
  final RideLocation drop;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.locationCardRadius),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.brandYellow,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledPlace(
                  label: AppStrings.pickupLocation,
                  value: pickup.routeLine,
                ),
              ),
              if (distance.trim().isNotEmpty)
                AppText(
                  text: distance,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.brandBlack,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledPlace(
                  label: AppStrings.dropLocation,
                  value: drop.routeLine,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabeledPlace extends StatelessWidget {
  const _LabeledPlace({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: AppDimensions.fontXs,
          ),
        ),
        const SizedBox(height: 2),
        AppText(
          text: value.isEmpty ? AppStrings.fieldPlaceholder : value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.2,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _VehicleOptionTile extends StatelessWidget {
  const _VehicleOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final VehicleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedVehicleFill : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.brandYellow : AppColors.fieldBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.selectedVehicleFill
                    : AppColors.fieldFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: option.imageUrl != null && option.imageUrl!.isNotEmpty
                  ? Image.network(
                      option.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        if (option.imageAsset != null) {
                          return Image.asset(
                            option.imageAsset!,
                            fit: BoxFit.contain,
                          );
                        }
                        return Icon(
                          option.icon,
                          color: AppColors.brandBlack,
                        );
                      },
                    )
                  : option.imageAsset != null
                  ? Image.asset(option.imageAsset!, fit: BoxFit.contain)
                  : Icon(option.icon, color: AppColors.brandBlack),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        text: option.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                      if (option.badge.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: AppText(
                            text: option.badge,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.brandYellow,
                              fontWeight: FontWeight.w600,
                              fontSize: AppDimensions.fontTiny,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: option.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: AppDimensions.fontTiny,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            AppText(
              text: AppUtils.rupee(option.price),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            _RadioMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandYellow, width: 5.5),
        ),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.brandBlack,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.fieldBorder, width: 1.6),
      ),
    );
  }
}

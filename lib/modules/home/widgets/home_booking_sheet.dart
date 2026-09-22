import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/ride_location.dart';
import '../../../data/models/vehicle_category.dart';
import '../controllers/home_controller.dart';

class HomeBookingSheet extends GetView<HomeController> {
  const HomeBookingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navReserve =
        AppDimensions.homeNavHeight +
        AppDimensions.homeNavBottomGap +
        bottomInset;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.homeSheetPadding,
        24,
        AppDimensions.homeSheetPadding,
        navReserve,
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
            () => HomePickupDropCard(
              pickup: controller.pickup.value,
              drop: controller.drop.value,
              pickupTitle: controller.usingCurrentPickup.value
                  ? AppStrings.currentLocationTitle
                  : null,
              onTapPickup: controller.openPickupPicker,
              onTapDrop: controller.openDropPicker,
              onClearPickup: controller.clearPickup,
              onClearDrop: controller.clearDrop,
            ),
          ),
          const SizedBox(height: 14),
          const VehicleCategoryRow(),
          const SizedBox(height: 14),
          AppButton(
            title: AppStrings.searchRide,
            backgroundColor: AppColors.brandBlack,
            textColor: AppColors.white,
            borderRadius: AppDimensions.searchButtonRadius,
            onPressed: controller.searchRide,
          ),
        ],
      ),
    );
  }
}

class HomePickupDropCard extends StatelessWidget {
  const HomePickupDropCard({
    super.key,
    required this.pickup,
    required this.drop,
    this.pickupTitle,
    this.onTapPickup,
    this.onTapDrop,
    this.onClearPickup,
    this.onClearDrop,
  });

  final RideLocation pickup;
  final RideLocation drop;
  final String? pickupTitle;
  final VoidCallback? onTapPickup;
  final VoidCallback? onTapDrop;
  final VoidCallback? onClearPickup;
  final VoidCallback? onClearDrop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 12, 16),
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
          InkWell(
            onTap: onTapPickup,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 18,
                  child: Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Center(child: _PickupDot()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LocationTexts(
                    label: AppStrings.pickupLocation,
                    location: pickup,
                    displayTitle: pickupTitle,
                  ),
                ),
                _ClearButton(onTap: onClearPickup),
              ],
            ),
          ),
          const Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(painter: _DottedLinePainter()),
              ),
              SizedBox(width: 12),
              Expanded(child: Divider(height: 1, color: AppColors.fieldBorder)),
              SizedBox(width: 28),
            ],
          ),
          InkWell(
            onTap: onTapDrop,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 18,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.brandBlack,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LocationTexts(
                    label: AppStrings.dropLocation,
                    location: drop,
                    placeholder: AppStrings.dropLocation,
                  ),
                ),
                if (!drop.isBlank)
                  _ClearButton(onTap: onClearDrop)
                else
                  const SizedBox(width: AppDimensions.closeButtonSize),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupDot extends StatelessWidget {
  const _PickupDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.locationDotSize,
      height: AppDimensions.locationDotSize,
      decoration: const BoxDecoration(
        color: AppColors.brandYellow,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.brandBlack,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fieldBorder
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dash = 3.0;
    const gap = 3.0;
    var y = 4.0;
    final x = size.width / 2;
    while (y < size.height - 4) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationTexts extends StatelessWidget {
  const _LocationTexts({
    required this.label,
    required this.location,
    this.displayTitle,
    this.placeholder,
  });

  final String label;
  final RideLocation location;
  final String? displayTitle;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = location.isBlank && (placeholder ?? '').isNotEmpty;
    final title = isPlaceholder
        ? placeholder!
        : (displayTitle != null && displayTitle!.trim().isNotEmpty
              ? displayTitle!
              : (location.title.isEmpty
                    ? AppStrings.fieldPlaceholder
                    : location.title));
    final subtitle = isPlaceholder
        ? ''
        : (location.subtitle.isEmpty ? '' : location.subtitle);
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
          text: title,
          style: AppTextStyles.heading.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.2,
            color: isPlaceholder ? AppColors.textHint : AppColors.textPrimary,
          ),
          maxLines: 1,
        ),
        if (subtitle.isNotEmpty)
          AppText(
            text: subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: AppDimensions.fontXs,
            ),
            maxLines: 1,
          ),
      ],
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.closeButtonSize,
        height: AppDimensions.closeButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: const Icon(Icons.close, size: 12, color: AppColors.navInactive),
      ),
    );
  }
}

class LocationField extends StatelessWidget {
  const LocationField({
    super.key,
    required this.label,
    required this.location,
    required this.icon,
    required this.iconColor,
    this.filledDot = false,
    this.onClear,
  });

  final String label;
  final RideLocation location;
  final IconData icon;
  final Color iconColor;
  final bool filledDot;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: filledDot
              ? Container(
                  width: AppDimensions.locationDotSize,
                  height: AppDimensions.locationDotSize,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                )
              : Icon(
                  icon,
                  color: iconColor,
                  size: AppDimensions.iconSizeSmall + 2,
                ),
        ),
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
                text: location.title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              AppText(
                text: location.subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close_rounded,
              size: AppDimensions.iconSizeSmall,
              color: AppColors.navInactive,
            ),
          ),
      ],
    );
  }
}

class VehicleCategoryRow extends GetView<HomeController> {
  const VehicleCategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        controller.vehicleTypes.length;
        controller.selectedCategoryId.value;
        final items = controller.categories;
        if (items.length > 3) {
          return SizedBox(
            height: AppDimensions.vehicleCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = items[index];
                return SizedBox(
                  width: 108,
                  child: _CategoryCard(
                    category: category,
                    selected:
                        controller.selectedCategoryId.value == category.id,
                    onTap: () => controller.selectCategory(category.id),
                  ),
                );
              },
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i != 0) const SizedBox(width: 10),
              Expanded(
                child: _CategoryCard(
                  category: items[i],
                  selected:
                      controller.selectedCategoryId.value == items[i].id,
                  onTap: () => controller.selectCategory(items[i].id),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final VehicleCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedVehicleFill : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.vehicleCardRadius),
          border: Border.all(
            color: selected ? AppColors.brandYellow : AppColors.fieldBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: AppDimensions.vehicleCardImageHeight,
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? Image.network(
                      category.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        if (category.imageAsset != null) {
                          return Image.asset(
                            category.imageAsset!,
                            fit: BoxFit.contain,
                          );
                        }
                        return Icon(
                          category.icon,
                          color: AppColors.brandBlack,
                          size: 36,
                        );
                      },
                    )
                  : category.imageAsset != null
                  ? Image.asset(category.imageAsset!, fit: BoxFit.contain)
                  : Icon(category.icon, color: AppColors.brandBlack, size: 36),
            ),
            const SizedBox(height: 6),
            AppText(
              text: category.title,
              style: AppTextStyles.label.copyWith(
                color: AppColors.brandBlack,
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.fontSm,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            AppText(
              text: category.subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: AppDimensions.fontTiny,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            _SelectionDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.brandYellow,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 14,
          color: AppColors.white,
        ),
      );
    }
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.fieldBorder, width: 1.4),
      ),
    );
  }
}

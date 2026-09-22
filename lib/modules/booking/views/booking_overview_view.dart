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
import '../../home/controllers/home_controller.dart';
import '../widgets/coupon_sheet.dart';

class BookingOverviewView extends GetView<HomeController> {
  const BookingOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _OverviewHeader(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Obx(
                    () => _OverviewLocationCard(
                      pickup: controller.pickup.value,
                      drop: controller.drop.value,
                      distance: controller.estimateDistance.value.isNotEmpty
                          ? controller.estimateDistance.value
                          : AppStrings.distanceSample,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SelectedVehicleCard(),
                  const SizedBox(height: 12),
                  const _CouponBanner(),
                  const SizedBox(height: 12),
                  const _OverviewFareCard(),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
            child: Obx(
              () => AppButton(
                title: AppStrings.confirmBooking,
                backgroundColor: AppColors.brandBlack,
                textColor: AppColors.white,
                borderRadius: AppDimensions.searchButtonRadius,
                isLoading: controller.isEstimating.value ||
                    controller.isConfirmingBooking.value,
                onPressed: (controller.isEstimating.value ||
                        controller.isConfirmingBooking.value)
                    ? null
                    : controller.confirmBooking,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.brandBlack,
            ),
          ),
          Expanded(
            child: AppText(
              text: AppStrings.bookingOverview,
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.child,
    this.padding,
    this.borderColor,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OverviewLocationCard extends StatelessWidget {
  const _OverviewLocationCard({
    required this.pickup,
    required this.drop,
    required this.distance,
  });

  final RideLocation pickup;
  final RideLocation drop;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return _OverviewCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: _PickupDot(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LabeledPlace(
                  label: AppStrings.pickupLocation,
                  value: pickup.routeLine,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  text: distance,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 2,
                height: 16,
                child: CustomPaint(painter: _DottedPainter()),
              ),
            ),
          ),
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
              const SizedBox(width: 10),
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

class _PickupDot extends StatelessWidget {
  const _PickupDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: AppColors.brandYellow,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DottedPainter extends CustomPainter {
  const _DottedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fieldBorder
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    var y = 1.0;
    final x = size.width / 2;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 2.5), paint);
      y += 5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _SelectedVehicleCard extends GetView<HomeController> {
  const _SelectedVehicleCard();

  @override
  Widget build(BuildContext context) {
    return _OverviewCard(
      child: Obx(() {
        final vehicle = controller.vehicle;
        final image = controller.selectedVehicleImage;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    vehicle?.icon ?? Icons.electric_rickshaw,
                    size: 16,
                    color: AppColors.brandBlack,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    text: AppStrings.selectedVehicle,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (vehicle != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 96,
                    height: 68,
                    child: image != null
                        ? Image.asset(image, fit: BoxFit.contain)
                        : Icon(
                            vehicle.icon,
                            size: 48,
                            color: AppColors.brandBlack,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: controller.selectedVehicleLabel,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: 1.2,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          text: controller.selectedCategory.subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppText(
                          text: vehicle.badge.isNotEmpty
                              ? vehicle.badge
                              : vehicle.eta,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _CouponBanner extends GetView<HomeController> {
  const _CouponBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          const CouponSheet(),
          isScrollControlled: true,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.sheetRadius),
            ),
          ),
        );
      },
      child: _OverviewCard(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        borderColor: AppColors.brandYellow,
        color: AppColors.selectedVehicleFill,
        child: Row(
          children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.brandYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.percent_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text:
                          controller.appliedCoupon.value?.code ??
                          AppStrings.applyCouponCode,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: AppStrings.couponBannerHint,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.brandBlack,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewFareCard extends GetView<HomeController> {
  const _OverviewFareCard();

  @override
  Widget build(BuildContext context) {
    return _OverviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: AppColors.brandBlack,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                text: AppStrings.fareDetails,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isEstimating.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: AppPageLoader(),
              );
            }
            final discount = controller.discount;
            return Column(
              children: [
                _FareRow(
                  label: AppStrings.baseFare,
                  value: AppUtils.rupee(controller.baseFare, decimals: true),
                ),
                if (controller.distanceFare > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.distanceFare,
                    value: AppUtils.rupee(
                      controller.distanceFare,
                      decimals: true,
                    ),
                  ),
                ],
                if (controller.waitingCharge > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.waitingCharge,
                    value: AppUtils.rupee(
                      controller.waitingCharge,
                      decimals: true,
                    ),
                  ),
                ],
                if (controller.fareTax > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.tax,
                    value: AppUtils.rupee(controller.fareTax, decimals: true),
                  ),
                ],
                if (controller.cgst > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.cgst,
                    value: AppUtils.rupee(controller.cgst, decimals: true),
                  ),
                ],
                if (controller.sgst > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.sgst,
                    value: AppUtils.rupee(controller.sgst, decimals: true),
                  ),
                ],
                if (controller.igst > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.igst,
                    value: AppUtils.rupee(controller.igst, decimals: true),
                  ),
                ],
                if (discount > 0) ...[
                  const SizedBox(height: 10),
                  _FareRow(
                    label: AppStrings.applied,
                    value: '- ${AppUtils.rupee(discount, decimals: true)}',
                    valueColor: AppColors.couponGreen,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CustomPaint(
                    painter: _HorizontalDotsPainter(),
                    child: SizedBox(width: double.infinity, height: 1),
                  ),
                ),
                _FareRow(
                  label: AppStrings.totalAmount,
                  value: AppUtils.rupee(controller.totalAmount, decimals: true),
                  bold: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HorizontalDotsPainter extends CustomPainter {
  const _HorizontalDotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fieldBorder
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + 3, y), paint);
      x += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final color = bold ? AppColors.textPrimary : AppColors.textSecondary;
    final style = AppTextStyles.body.copyWith(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
      color: color,
      fontSize: bold ? 16 : 14,
    );
    return Row(
      children: [
        Expanded(
          child: AppText(text: label, style: style),
        ),
        AppText(
          text: value,
          style: style.copyWith(color: valueColor ?? color),
        ),
      ],
    );
  }
}

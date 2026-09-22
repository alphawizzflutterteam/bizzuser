import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/ride_chips.dart';
import '../../../data/models/ride_booking.dart';
import '../controllers/rides_controller.dart';

class RidesView extends GetView<RidesController> {
  const RidesView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final bottomInset = embedded
        ? 24.0
        : MediaQuery.paddingOf(context).bottom +
            AppDimensions.homeNavBottomGap +
            AppDimensions.homeNavHeight +
            AppDimensions.paddingMedium;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!embedded) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: AppText(
              text: AppStrings.myBookings,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
        ],
        const _BookingsTabs(),
        Expanded(
          child: Obx(() {
            if (controller.isPageLoading.value) {
              return const AppPageLoader();
            }
            final bookings = controller.bookings;
            if (bookings.isEmpty) {
              return const _EmptyBookings();
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingCard(
                  booking: booking,
                  onTap: () => controller.openBooking(booking),
                );
              },
            );
          }),
        ),
      ],
    );

    if (embedded) return content;

    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(bottom: false, child: content),
    );
  }
}

class _BookingsTabs extends StatefulWidget {
  const _BookingsTabs();

  static const labels = [
    AppStrings.ongoing,
    AppStrings.completed,
    AppStrings.cancelledTab,
  ];

  @override
  State<_BookingsTabs> createState() => _BookingsTabsState();
}

class _BookingsTabsState extends State<_BookingsTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Worker? _sync;

  RidesController get _rides => Get.find<RidesController>();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: _BookingsTabs.labels.length,
      vsync: this,
      initialIndex: _rides.tabIndex.value,
    );
    _tabs.addListener(_onTab);
    _sync = ever<int>(_rides.tabIndex, (index) {
      if (!mounted || _tabs.index == index) return;
      _tabs.animateTo(index);
    });
  }

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    _rides.changeTab(_tabs.index);
  }

  @override
  void dispose() {
    _sync?.dispose();
    _tabs.removeListener(_onTab);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: TabBar(
        controller: _tabs,
        onTap: _rides.changeTab,
        labelColor: AppColors.brandYellow,
        unselectedLabelColor: AppColors.tabInactive,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.brandYellow,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.fieldBorder,
        tabs: [
          for (final label in _BookingsTabs.labels) Tab(text: label),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.brandYellow,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AppText(text: AppStrings.noRidesYet, style: AppTextStyles.heading),
            const SizedBox(height: AppDimensions.paddingSmall),
            const AppText(
              text: AppStrings.noRidesHint,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});

  final RideBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.fieldBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: AppColors.tabInactive,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        text: '${AppStrings.bookingIdPrefix}${booking.bookingCode}',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tabInactive,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: booking.isCompleted
                            ? AppColors.completedFill
                            : AppColors.onTheWayFill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        text: booking.statusLabel,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: booking.isCompleted
                            ? AppColors.completedText
                            : AppColors.onTheWayText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _LocationRow(
                  iconColor: AppColors.brandYellow,
                  label: AppStrings.pickupLocation,
                  value: booking.pickup.routeLine,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      text: booking.distance,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tabInactive,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LocationRow(
                  iconColor: AppColors.brandBlack,
                  label: AppStrings.dropLocation,
                  value: booking.drop.routeLine,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: _DashedDivider(),
                ),
                Row(
                  children: [
                    DriverAvatar(
                      size: 44,
                      imageAsset: booking.driver.photoAsset ?? '',
                      imageUrl: booking.driver.photoUrl.isNotEmpty
                          ? booking.driver.resolvedPhoto
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: booking.driverDisplayName,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                          ),
                          if (booking.driver.rating.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => const Padding(
                                    padding: EdgeInsets.only(right: 1),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: AppColors.brandYellow,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AppText(
                                  text: booking.driver.rating,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.tabInactive,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (booking.vehicleLabel.isNotEmpty)
                            AppText(
                              text: booking.vehicleLabel,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tabInactive,
                              maxLines: 1,
                            ),
                          if (booking.driver.vehicleNumber.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.chipFill,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                text: booking.driver.vehicleNumber,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandBlack,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.iconColor,
    required this.label,
    required this.value,
    this.trailing,
  });

  final Color iconColor;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_rounded, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: label,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.tabInactive,
              ),
              const SizedBox(height: 2),
              AppText(
                text: value,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                maxLines: 2,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashGap = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
        return Row(
          children: List.generate(
            count,
            (index) => Container(
              width: dashWidth,
              height: 1,
              margin: const EdgeInsets.only(right: dashGap),
              color: AppColors.fieldBorder,
            ),
          ),
        );
      },
    );
  }
}

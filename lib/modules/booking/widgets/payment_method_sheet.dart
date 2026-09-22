import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/ride_payment.dart';
import '../../home/controllers/home_controller.dart';

class PaymentMethodPanel extends GetView<HomeController> {
  const PaymentMethodPanel({super.key});

  static IconData _iconFor(String method) {
    switch (method) {
      case 'online':
        return Icons.change_history_rounded;
      case 'wallet':
        return Icons.work_outline_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  static void show() {
    Get.bottomSheet(
      const PaymentMethodPanel(),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: AppColors.brandBlack,
                    ),
                    SizedBox(width: 8),
                    AppText(
                      text: AppStrings.choosePaymentMethod,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Obx(() {
                  if (controller.isRidePaid) {
                    return const AppText(
                      text: AppStrings.alreadyPaid,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.completedText,
                    );
                  }
                  if (controller.awaitingDriverCash.value) {
                    return const AppText(
                      text: AppStrings.waitingDriverCash,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    );
                  }
                  final selected = controller.paymentMethod.value;
                  final options = controller.paymentOptions;
                  return Row(
                    children: [
                      for (final option in options)
                        Expanded(
                          child: _PaymentTile(
                            label: option.label,
                            icon: _iconFor(option.method),
                            selected: selected == option.method,
                            enabled: option.available,
                            caption: _captionFor(option),
                            onTap: () =>
                                controller.selectPaymentMethod(option.method),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isRidePaid) {
              return AppButton(
                title: AppStrings.rateAndReview,
                backgroundColor: AppColors.brandBlack,
                textColor: AppColors.white,
                borderRadius: 28,
                height: 54,
                onPressed: controller.openRateReview,
              );
            }
            if (controller.awaitingDriverCash.value) {
              return AppButton(
                title: AppStrings.payCashToDriver,
                backgroundColor: AppColors.brandBlack,
                textColor: AppColors.white,
                borderRadius: 28,
                height: 54,
                onPressed: null,
              );
            }
            return AppButton(
              title: AppStrings.payNow,
              backgroundColor: AppColors.brandBlack,
              textColor: AppColors.white,
              borderRadius: 28,
              height: 54,
              isLoading: controller.isPaying.value,
              onPressed: controller.payNow,
            );
          }),
        ],
      ),
    );
  }

  static String? _captionFor(RidePaymentOption option) {
    if (!option.available && option.shortfall > 0) {
      return '₹${option.shortfall.toStringAsFixed(0)} short';
    }
    if (option.isWallet && option.walletBalance > 0) {
      return '₹${option.walletBalance.toStringAsFixed(0)}';
    }
    return null;
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.caption,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.brandBlack : AppColors.tabInactive;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: selected
                          ? Border.all(color: AppColors.brandYellow, width: 2)
                          : null,
                    ),
                    child: Icon(icon, size: 26, color: color),
                  ),
                  if (selected)
                    const Positioned(
                      top: 2,
                      right: 2,
                      child: _SelectedMark(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              text: label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              AppText(
                text: caption!,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: enabled ? AppColors.tabInactive : AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  const _SelectedMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.brandYellow,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 12,
        color: AppColors.white,
      ),
    );
  }
}

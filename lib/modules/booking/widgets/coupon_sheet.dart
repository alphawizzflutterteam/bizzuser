import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/ride_coupon.dart';
import '../../home/controllers/home_controller.dart';

class CouponSheet extends StatefulWidget {
  const CouponSheet({super.key});

  @override
  State<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<CouponSheet> {
  final codeController = TextEditingController();
  final HomeController controller = Get.find<HomeController>();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _applyListedCoupon(RideCoupon coupon) async {
    await controller.applyCoupon(coupon);
    _closeIfApplied(coupon.code);
  }

  Future<void> _applyTypedCode() async {
    final code = codeController.text.trim();
    await controller.applyTypedCoupon(code);
    _closeIfApplied(code);
  }

  void _closeIfApplied(String code) {
    if (!mounted) return;
    final applied = controller.appliedCoupon.value?.code.trim() ?? '';
    if (applied.isEmpty || code.trim().isEmpty) return;
    if (applied.toLowerCase() != code.trim().toLowerCase()) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => _CouponCodeField(
                      controller: codeController,
                      onApply: controller.isApplyingCoupon.value
                          ? null
                          : () => _applyTypedCode(),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppText(
                    text: AppStrings.availableCoupons,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandBlack,
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    if (controller.isCouponsLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: AppPageLoader(),
                      );
                    }
                    final items = controller.coupons;
                    final appliedCode = controller.appliedCoupon.value?.code;
                    final applying = controller.isApplyingCoupon.value;
                    return Column(
                      children: [
                        for (final coupon in items) ...[
                          _CouponTile(
                            title: coupon.title,
                            subtitle: coupon.subtitle,
                            applied: appliedCode == coupon.code,
                            onApply: applying
                                ? null
                                : () => _applyListedCoupon(coupon),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
            Obx(() {
              if (!controller.isApplyingCoupon.value) {
                return const SizedBox.shrink();
              }
              return const Positioned.fill(
                child: ColoredBox(
                  color: AppColors.overlay,
                  child: AppPageLoader(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CouponCodeField extends StatelessWidget {
  const _CouponCodeField({
    required this.controller,
    this.onApply,
  });

  final TextEditingController controller;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          const _CouponIcon(),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              cursorColor: AppColors.brandBlack,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
                color: AppColors.brandBlack,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: AppColors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: AppStrings.enterCouponCode,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textHint,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CouponActionButton(
            label: AppStrings.apply,
            filled: true,
            onTap: onApply,
          ),
        ],
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.title,
    required this.subtitle,
    required this.applied,
    this.onApply,
  });

  final String title;
  final String subtitle;
  final bool applied;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          const _CouponIcon(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlack,
                ),
                const SizedBox(height: 2),
                AppText(
                  text: subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.walletCreditBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: AppColors.couponGreen,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            text: AppStrings.validOnAllRides,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.couponGreen,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CouponActionButton(
            label: applied ? AppStrings.applied : AppStrings.apply,
            filled: !applied,
            onTap: applied ? null : onApply,
          ),
        ],
      ),
    );
  }
}

class _CouponIcon extends StatelessWidget {
  const _CouponIcon({this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.confirmation_number_outlined,
        color: AppColors.brandYellow,
        size: 18,
      ),
    );
  }
}

class _CouponActionButton extends StatelessWidget {
  const _CouponActionButton({
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppColors.brandYellow : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandYellow),
        ),
        child: AppText(
          text: label,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: filled ? AppColors.brandBlack : AppColors.brandYellow,
        ),
      ),
    );
  }
}

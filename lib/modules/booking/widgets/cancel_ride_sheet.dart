import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../home/controllers/home_controller.dart';

class CancelRideSheet extends StatelessWidget {
  const CancelRideSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const SafeArea(top: false, child: CancelRideSheet()),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.sheetRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppText(
                  text: AppStrings.cancelRide,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlack,
                ),
              ),
              GestureDetector(
                onTap: Get.back,
                child: const Icon(
                  Icons.close,
                  size: 22,
                  color: AppColors.brandBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(
            () => Column(
              children: [
                for (final reason in controller.cancelReasons) ...[
                  _CancelReasonTile(
                    title: reason.title,
                    icon: reason.icon,
                    selected: controller.cancelReasonId.value == reason.id,
                    onTap: () => controller.selectCancelReason(reason.id),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => AppButton(
              title: AppStrings.submit,
              backgroundColor: AppColors.brandBlack,
              textColor: AppColors.white,
              borderRadius: 28,
              height: 52,
              isLoading: controller.isCancellingRide.value,
              onPressed: controller.submitCancelRide,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelReasonTile extends StatelessWidget {
  const _CancelReasonTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandBlack, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: title,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlack,
              ),
            ),
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
        width: 22,
        height: 22,
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
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.fieldBorder, width: 1.6),
      ),
    );
  }
}

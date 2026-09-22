import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/repositories/safety_catalog.dart';
import '../controllers/sos_controller.dart';

class ReportSafetyDialog extends StatelessWidget {
  const ReportSafetyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SosController>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: AppStrings.reportSafetyIssue,
                      style: AppTextStyles.heading.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
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
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: [
                    for (final reason in SafetyCatalog.reasons) ...[
                      _ReasonTile(
                        title: reason.title,
                        icon: reason.icon,
                        selected:
                            controller.selectedReasonId.value == reason.id,
                        onTap: () => controller.selectReason(reason.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                title: AppStrings.submit,
                backgroundColor: AppColors.brandBlack,
                textColor: AppColors.white,
                borderRadius: AppDimensions.searchButtonRadius,
                height: 48,
                onPressed: () async {
                  final submitted = await controller.submitReport();
                  if (!submitted || !context.mounted) return;
                  Navigator.of(context).maybePop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandBlack, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
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

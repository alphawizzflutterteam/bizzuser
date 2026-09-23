import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/safety_models.dart';
import '../../../data/repositories/safety_catalog.dart';
import '../../../data/services/sos_service.dart';
import '../controllers/sos_controller.dart';
import '../widgets/report_safety_dialog.dart';

class SosView extends GetView<SosController> {
  const SosView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.isRegistered<SosService>()
        ? Get.find<SosService>()
        : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _SosHeader(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isPageLoading.value) {
                return const AppPageLoader();
              }
              final alert = service?.activeSos.value;
              if (alert == null || !alert.isOpen) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: AppText(
                      text: AppStrings.noActiveSos,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final numbers = service?.dialNumbers() ?? const <String>[];
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.sosEmergencyBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const AppText(
                                  text: AppStrings.sosOpen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.sosButton,
                                ),
                              ),
                              const SizedBox(width: 10),
                              AppText(
                                text: alert.timeLabel,
                                fontSize: 12,
                                color: AppColors.tabInactive,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AppText(
                            text: alert.message.isEmpty
                                ? AppStrings.yourSafetyMatters
                                : alert.message,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandBlack,
                          ),
                          if (alert.location.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            AppText(
                              text: alert.location,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                          const SizedBox(height: 20),
                          for (final number in numbers) ...[
                            _DialTile(
                              number: number,
                              onTap: () => service?.callNumber(number),
                            ),
                            const SizedBox(height: 10),
                          ],
                          _SafetyActionTile(
                            action: SafetyCatalog.actions[1],
                            onTap: () => service?.shareActive(),
                          ),
                          const SizedBox(height: 10),
                          _SafetyActionTile(
                            action: SafetyCatalog.actions[2],
                            onTap: () {
                              Get.bottomSheet(
                                const SafeArea(
                                  top: false,
                                  child: ReportSafetyDialog(),
                                ),
                                isScrollControlled: true,
                                backgroundColor: AppColors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                      AppDimensions.sheetRadius,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (alert.contactsNotified.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            const AppText(
                              text: AppStrings.emergencyContactsTitle,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            const SizedBox(height: 8),
                            for (final contact in alert.contactsNotified)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        text: contact.name.isEmpty
                                            ? contact.phone
                                            : '${contact.name} · ${contact.smsStatus}',
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          service?.textContact(contact),
                                      child: const AppText(
                                        text: AppStrings.smsContact,
                                        fontSize: 12,
                                        color: AppColors.sosShareIcon,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: AppButton(
                        title: AppStrings.falseAlarm,
                        isLoading: service?.isCancelling.value ?? false,
                        outlined: true,
                        borderColor: AppColors.sosButton,
                        textColor: AppColors.sosButton,
                        backgroundColor: AppColors.white,
                        borderRadius: 28,
                        height: 50,
                        onPressed: service?.cancelActive,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SosHeader extends StatelessWidget {
  const _SosHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.fieldBorder),
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
          AppText(
            text: AppStrings.sosActiveTitle,
            style: AppTextStyles.heading.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialTile extends StatelessWidget {
  const _DialTile({required this.number, required this.onTap});

  final String number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sosEmergencyBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.sosButton,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: number,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sos),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyActionTile extends StatelessWidget {
  const _SafetyActionTile({required this.action, required this.onTap});

  final SafetyAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: action.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: action.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: action.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.navInactive,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

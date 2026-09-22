import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../signup/widgets/signup_labeled_field.dart';
import '../controllers/emergency_contacts_controller.dart';

class EmergencyContactsView extends GetView<EmergencyContactsController> {
  const EmergencyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: AppStrings.emergencyContactsTitle),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  const AppText(
                    text: AppStrings.emergencyContactsHint,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final items = controller.contacts;
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: AppText(
                          text: AppStrings.needEmergencyContact,
                          color: AppColors.tabInactive,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.fieldBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        text: items[i].name,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      AppText(
                                        text: items[i].phone,
                                        fontSize: 13,
                                        color: AppColors.tabInactive,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.startEdit(i),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                ),
                                IconButton(
                                  onPressed: () => controller.removeAt(i),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppColors.logoutText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                  SignupLabeledField(
                    label: AppStrings.contactName,
                    controller: controller.nameController,
                    textCapitalization: TextCapitalization.words,
                    fillColor: AppColors.white,
                    validator: controller.validateName,
                  ),
                  const SizedBox(height: 12),
                  SignupPhoneField(
                    controller: controller.phoneController,
                    validator: controller.validatePhone,
                    fillColor: AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => AppButton(
                      title: AppStrings.saveContact,
                      isLoading: controller.isSaving.value,
                      backgroundColor: AppColors.brandBlack,
                      textColor: AppColors.white,
                      borderRadius: 28,
                      height: 52,
                      onPressed: controller.saveContact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

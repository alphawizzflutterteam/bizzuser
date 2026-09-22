import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../signup/widgets/signup_labeled_field.dart';
import '../controllers/add_ticket_controller.dart';

class AddTicketView extends GetView<AddTicketController> {
  const AddTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: PillHeader(title: AppStrings.addSupportTicket),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isPageLoading.value) {
                    return const AppPageLoader();
                  }
                  return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                    children: [
                      SignupLabeledField(
                        label: AppStrings.issueCategory,
                        controller: controller.categoryController,
                        readOnly: true,
                        fillColor: AppColors.white,
                        onTap: controller.openCategoryPicker,
                        suffixIcon: const IgnorePointer(
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.tabInactive,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SignupLabeledField(
                        label: AppStrings.subject,
                        controller: controller.subjectController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        fillColor: AppColors.white,
                      ),
                      const SizedBox(height: 14),
                      SignupLabeledField(
                        label: AppStrings.description,
                        controller: controller.descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        fillColor: AppColors.white,
                        maxLines: 4,
                        minLines: 3,
                      ),
                      const SizedBox(height: 14),
                      SignupLabeledField(
                        label: AppStrings.imageUpload,
                        controller: controller.imageController,
                        fillColor: AppColors.white,
                        readOnly: true,
                        onTap: controller.pickImage,
                      ),
                      const SizedBox(height: 28),
                      Obx(
                        () => AppButton(
                          title: AppStrings.raiseSupportTicket,
                          isLoading: controller.isLoading.value,
                          backgroundColor: AppColors.brandBlack,
                          textColor: AppColors.white,
                          borderRadius: 28,
                          height: 52,
                          onPressed: controller.raiseTicket,
                        ),
                      ),
                    ],
                  ),
                );
                }),
              ),
            ],
          ),
        ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../signup/widgets/signup_labeled_field.dart';
import '../controllers/personal_information_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_avatar.dart';

class PersonalInformationView extends GetView<PersonalInformationController> {
  const PersonalInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.brandBlack,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isPageLoading.value) {
                    return const AppPageLoader();
                  }
                  return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        const _PersonalHeader(),
                        const SizedBox(height: 28),
                        SignupLabeledField(
                          label: AppStrings.name,
                          controller: controller.nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: controller.validateName,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintFullName,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SignupPhoneField(
                          controller: controller.phoneController,
                          validator: controller.validatePhone,
                          fillColor: AppColors.white,
                          readOnly: true,
                        ),
                        const SizedBox(height: 14),
                        SignupLabeledField(
                          label: AppStrings.emailOptional,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: controller.validateEmail,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintEmail,
                        ),
                        const SizedBox(height: 14),
                        SignupLabeledField(
                          label: AppStrings.referralCodeOptional,
                          controller: controller.referralController,
                          textInputAction: TextInputAction.done,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintReferralCode,
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => AppButton(
                            title: AppStrings.updateProfile,
                            isLoading: controller.isLoading.value,
                            backgroundColor: AppColors.brandBlack,
                            textColor: AppColors.white,
                            borderRadius: 28,
                            height: 52,
                            onPressed: controller.updateProfile,
                          ),
                        ),
                      ],
                    ),
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

/// Avatar on the left, name / phone / email left-aligned on the right
/// (same layout as the Profile tab header).
class _PersonalHeader extends StatelessWidget {
  const _PersonalHeader();

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    return Obx(() {
      final name = profile.displayName;
      final phone = profile.displayPhone;
      return Row(
        children: [
          ProfileAvatar(
            imagePath: profile.avatarPath,
            onEdit: profile.showPhotoPicker,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty) ...[
                  AppText(
                    text: name,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandBlack,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                ],
                if (phone.isNotEmpty) ...[
                  _ContactLine(icon: Icons.phone_outlined, text: phone),
                  const SizedBox(height: 6),
                ],
                _ContactLine(
                  icon: Icons.mail_outline_rounded,
                  text: profile.displayEmail,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.tabInactive),
        const SizedBox(width: 6),
        Flexible(
          child: AppText(
            text: text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.tabInactive,
            textAlign: TextAlign.start,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/phone_code_prefix.dart';
import '../../../core/widgets/pill_header.dart';
import '../../signup/widgets/signup_labeled_field.dart';
import '../controllers/bank_details_controller.dart';

class BankDetailsView extends GetView<BankDetailsController> {
  const BankDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: PillHeader(title: AppStrings.bankDetails),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        SignupLabeledField(
                          label: AppStrings.accountHolderName,
                          controller: controller.holderController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintAccountHolder,
                        ),
                        const SizedBox(height: 14),
                        SignupLabeledField(
                          label: AppStrings.accountNumber,
                          controller: controller.numberController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintAccountNumber,
                          prefix: const PhoneCodePrefix(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(18),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SignupLabeledField(
                          label: AppStrings.ifscCode,
                          controller: controller.ifscController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintIfsc,
                        ),
                        const SizedBox(height: 14),
                        SignupLabeledField(
                          label: AppStrings.bankName,
                          controller: controller.bankController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          fillColor: AppColors.white,
                          hintText: AppStrings.hintBankName,
                        ),
                        const SizedBox(height: 14),
                        SignupLabeledField(
                          label: AppStrings.accountType,
                          controller: controller.typeController,
                          hintText: AppStrings.hintAccountType,
                          readOnly: true,
                          fillColor: AppColors.white,
                          onTap: controller.openAccountTypePicker,
                          suffixIcon: const IgnorePointer(
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.tabInactive,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => AppButton(
                            title: AppStrings.updateBankDetails,
                            isLoading: controller.isLoading.value,
                            backgroundColor: AppColors.brandBlack,
                            textColor: AppColors.white,
                            borderRadius: 28,
                            height: 52,
                            onPressed: controller.updateBankDetails,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

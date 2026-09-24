import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_text.dart';
import 'profile_controller.dart';

class BankDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final holderController = TextEditingController();
  final numberController = TextEditingController();
  final ifscController = TextEditingController();
  final bankController = TextEditingController();
  final typeController = TextEditingController();
  final isLoading = false.obs;

  static const types = [AppStrings.savings, AppStrings.currentAccount];

  @override
  void onInit() {
    super.onInit();
    _fillFromProfile();
  }

  void _fillFromProfile() {
    if (!Get.isRegistered<ProfileController>()) return;
    final bank = Get.find<ProfileController>().user.value.bankAccount;
    if (bank == null || bank.isEmpty) return;
    holderController.text = bank.accountName;
    numberController.text = bank.accountNumber;
    ifscController.text = bank.ifsc;
    bankController.text = bank.bankName;
    typeController.text = bank.displayType;
  }

  void selectAccountType(String value) {
    typeController.text = value;
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void openAccountTypePicker() {
    AppUtils.hideKeyboard();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24 + MediaQuery.viewPaddingOf(Get.context!).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final type in types)
              ListTile(
                title: AppText(text: type),
                onTap: () => selectAccountType(type),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> updateBankDetails() async {
    AppUtils.hideKeyboard();
    try {
      isLoading.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      AppUtils.showSuccess(AppStrings.bankDetailsUpdated);
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    holderController.dispose();
    numberController.dispose();
    ifscController.dispose();
    bankController.dispose();
    typeController.dispose();
    super.onClose();
  }
}

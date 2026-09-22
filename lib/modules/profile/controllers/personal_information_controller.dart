import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/media_url.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_controller.dart';

class PersonalInformationController extends GetxController
    with PageLoadingMixin {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final referralController = TextEditingController();
  final isLoading = false.obs;

  String? validateName(String? value) => AppValidators.required(value);

  String? validatePhone(String? value) => AppValidators.phone(value);

  String? validateEmail(String? value) => AppValidators.optionalEmail(value);

  ProfileController get _profile => Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    _fillFromProfile();
    if (!Get.isRegistered<ProfileRepository>()) {
      stopPageLoading();
      return;
    }
    _refreshThenFill();
  }

  Future<void> _refreshThenFill() async {
    await runPageLoad(() async {
      await _profile.refreshProfile(showLoader: false);
      if (isClosed) return;
      _fillFromProfile();
    });
  }

  void _fillFromProfile() {
    final current = _profile.user.value;
    nameController.text = current.name;
    phoneController.text = PhoneUtils.localNumber(current.phone);
    emailController.text = current.email;
    referralController.text = current.referralCode;
  }

  Future<void> updateProfile() async {
    AppUtils.hideKeyboard();
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!Get.isRegistered<ProfileRepository>()) {
      AppUtils.showError(AppStrings.somethingWentWrong);
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final current = _profile.user.value;

    try {
      isLoading.value = true;
      final repo = Get.find<ProfileRepository>();
      final avatar = current.avatar.trim();
      final result = await runApi(
        () => repo.updateProfile(
          name: name,
          email: email,
          avatar: MediaUrl.isRemote(avatar) ? avatar : null,
        ),
      );
      if (result == null) return;
      _profile.applyUser(result.user);
      AppUtils.showSuccess(result.message);
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    referralController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../data/models/sos_alert.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_controller.dart';

class EmergencyContactsController extends GetxController with PageLoadingMixin {
  final contacts = <EmergencyContact>[].obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final isSaving = false.obs;
  int? editingIndex;

  String? validateName(String? value) => AppValidators.required(value);

  String? validatePhone(String? value) => AppValidators.phone(value);

  @override
  void onInit() {
    super.onInit();
    _fill();
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().refreshProfile(showLoader: false).then((_) {
        if (!isClosed) _fill();
      });
    }
    stopPageLoading();
  }

  void _fill() {
    if (Get.isRegistered<ProfileController>()) {
      contacts.assignAll(
        Get.find<ProfileController>().user.value.emergencyContacts,
      );
    }
  }

  void startAdd() {
    if (contacts.length >= 3) {
      AppUtils.showError(AppStrings.maxEmergencyContacts);
      return;
    }
    editingIndex = null;
    nameController.clear();
    phoneController.clear();
  }

  void startEdit(int index) {
    editingIndex = index;
    final item = contacts[index];
    nameController.text = item.name;
    phoneController.text = PhoneUtils.localNumber(item.phone);
  }

  Future<void> saveContact() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (AppValidators.required(name) != null) {
      AppUtils.showError(AppStrings.enterName);
      return;
    }
    if (AppValidators.phone(phone) != null) {
      AppUtils.showError(AppStrings.enterMobileNumber);
      return;
    }
    final next = EmergencyContact(
      name: name,
      phone: PhoneUtils.toApiPhone(phone),
    );
    final items = [...contacts];
    if (editingIndex != null && editingIndex! < items.length) {
      items[editingIndex!] = next;
    } else {
      if (items.length >= 3) {
        AppUtils.showError(AppStrings.maxEmergencyContacts);
        return;
      }
      items.add(next);
    }
    await _persist(items);
  }

  Future<void> removeAt(int index) async {
    final items = [...contacts]..removeAt(index);
    await _persist(items);
  }

  Future<void> _persist(List<EmergencyContact> items) async {
    if (!Get.isRegistered<ProfileRepository>()) {
      contacts.assignAll(items);
      return;
    }
    isSaving.value = true;
    try {
      final result = await runApi(
        () => Get.find<ProfileRepository>().updateEmergencyContacts(items),
      );
      if (result == null) return;
      contacts.assignAll(result.user.emergencyContacts);
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().applyUser(result.user);
      }
      AppUtils.showSuccess(result.message);
      nameController.clear();
      phoneController.clear();
      editingIndex = null;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}

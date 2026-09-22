import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/support_category.dart';
import '../../../data/repositories/support_catalog.dart';
import '../../../data/repositories/support_repository.dart';
import 'help_support_controller.dart';

class AddTicketController extends GetxController with PageLoadingMixin {
  final categoryController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final isLoading = false.obs;
  final categories = <SupportCategory>[...SupportCatalog.categories].obs;
  String _selectedSlug = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final items = await Get.find<SupportRepository>().fetchCategories();
      if (items.isNotEmpty) {
        categories.assignAll(items);
      }
    });
  }

  void selectCategory(SupportCategory category) {
    _selectedSlug = category.slug.isNotEmpty ? category.slug : _slugFor(category.name);
    categoryController.text = category.name;
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  String _slugFor(String name) {
    final value = name.trim().toLowerCase();
    if (value.contains('lost')) return 'lost_found';
    if (value.contains('payment')) return 'payment';
    if (value.contains('ride')) return 'ride';
    return value.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  void openCategoryPicker() {
    AppUtils.hideKeyboard();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final category in categories)
                ListTile(
                  title: AppText(text: category.name),
                  onTap: () => selectCategory(category),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    AppUtils.hideKeyboard();
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      imageController.text = file.name;
    } catch (_) {
      AppUtils.showError(AppStrings.photoPickFailed);
    }
  }

  Future<void> raiseTicket() async {
    AppUtils.hideKeyboard();
    final category = _selectedSlug.isNotEmpty
        ? _selectedSlug
        : _slugFor(categoryController.text);
    if (category.isEmpty) {
      AppUtils.showError(AppStrings.selectCategory);
      return;
    }
    final subject = subjectController.text.trim();
    final message = descriptionController.text.trim();
    if (subject.isEmpty) {
      AppUtils.showError(AppStrings.enterSubject);
      return;
    }
    if (message.isEmpty) {
      AppUtils.showError(AppStrings.enterMessage);
      return;
    }

    if (!Get.isRegistered<SupportRepository>()) {
      _leaveAfterSuccess(AppStrings.ticketRaised);
      return;
    }

    try {
      isLoading.value = true;
      final ticket = await runApi(
        () => Get.find<SupportRepository>().createTicket(
          category: category,
          subject: subject,
          message: message,
        ),
      );
      if (ticket == null) return;
      if (Get.isRegistered<HelpSupportController>()) {
        Get.find<HelpSupportController>().loadTickets();
      }
      _leaveAfterSuccess(AppStrings.ticketCreated);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    categoryController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.onClose();
  }

  void _leaveAfterSuccess(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.until(
      (route) =>
          route.settings.name == AppRoutes.helpSupport || route.isFirst,
    );
    AppUtils.showSuccess(message);
  }
}

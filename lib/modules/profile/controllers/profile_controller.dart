import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/media_url.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/models/auth_session.dart';
import '../../../data/models/profile_menu_item.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/sos_service.dart';
import '../widgets/photo_source_sheet.dart';

class ProfileController extends GetxController with PageLoadingMixin {
  final user = AuthUser.placeholder().obs;
  final photoPath = RxnString();
  final ImagePicker _picker = ImagePicker();

  String get displayName {
    final name = user.value.name.trim();
    return name.isEmpty ? AppStrings.profileUserName : name;
  }

  String get displayPhone {
    final phone = user.value.phone.trim();
    if (phone.isEmpty) return AppStrings.profileUserPhone;
    return PhoneUtils.displayPhone(phone);
  }

  String get displayEmail {
    final email = user.value.email.trim();
    return email.isEmpty ? AppStrings.profileUserEmail : email;
  }

  String? get avatarPath {
    final local = photoPath.value;
    if (local != null && local.isNotEmpty) return local;
    final avatar = user.value.avatar.trim();
    if (avatar.isEmpty) return null;
    return MediaUrl.resolve(avatar);
  }

  @override
  void onInit() {
    super.onInit();
    _applyCached();
    if (!Get.isRegistered<ProfileRepository>()) {
      stopPageLoading();
      return;
    }
    refreshProfile();
  }

  Future<void> refreshProfile({bool showLoader = true}) async {
    if (!Get.isRegistered<ProfileRepository>()) {
      stopPageLoading();
      return;
    }
    Future<void> request() async {
      final result = await Get.find<ProfileRepository>().getProfile();
      applyUser(result.user);
    }

    if (showLoader) {
      await runPageLoad(request);
      return;
    }
    try {
      await request();
    } catch (_) {}
  }

  void applyUser(AuthUser next) {
    user.value = next;
  }

  void _applyCached() {
    if (!Get.isRegistered<ProfileRepository>()) return;
    final cached = Get.find<ProfileRepository>().cachedUser();
    if (cached != null) {
      user.value = cached;
    }
  }

  void openItem(ProfileMenuItem item) {
    if (item.id == 'personal') {
      Get.toNamed(AppRoutes.personalInformation);
      return;
    }
    if (item.id == 'emergency') {
      Get.toNamed(AppRoutes.emergencyContacts);
      return;
    }
    if (item.id == 'wallet') {
      Get.toNamed(AppRoutes.wallet);
      return;
    }
    if (item.id == 'referral') {
      Get.toNamed(AppRoutes.referAndEarn);
      return;
    }
    if (item.id == 'bank') {
      Get.toNamed(AppRoutes.bankDetails);
      return;
    }
    if (item.id == 'history') {
      Get.toNamed(AppRoutes.rideHistory);
      return;
    }
    if (item.id == 'sosHistory') {
      Get.toNamed(AppRoutes.sosHistory);
      return;
    }
    if (item.id == 'help') {
      Get.toNamed(AppRoutes.helpSupport);
      return;
    }
    if (item.id == 'privacy') {
      Get.toNamed(AppRoutes.privacyPolicy);
      return;
    }
    if (item.id == 'terms') {
      Get.toNamed(AppRoutes.termsConditions);
      return;
    }
    if (item.id == 'faqs') {
      Get.toNamed(AppRoutes.faqs);
      return;
    }
    AppUtils.showInfo(item.title);
  }

  void showPhotoPicker() {
    PhotoSourceSheet.show(
      onCamera: () => pickPhoto(ImageSource.camera),
      onGallery: () => pickPhoto(ImageSource.gallery),
    );
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      photoPath.value = file.path;
      AppUtils.showSuccess(AppStrings.photoUpdated);
    } catch (_) {
      AppUtils.showError(AppStrings.photoPickFailed);
    }
  }

  Future<void> logout() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.logout,
      message: AppStrings.logoutConfirm,
    );
    if (confirmed != true) return;

    String message = AppStrings.loggedOut;
    if (Get.isRegistered<AuthRepository>()) {
      message = await Get.find<AuthRepository>().logout();
    }
    Get.offAllNamed(AppRoutes.login);
    SosService.clearActive();
    AppUtils.showSuccess(message);
  }

  Future<void> deleteAccount() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.deleteAccount,
      message: AppStrings.deleteAccountConfirm,
    );
    if (confirmed != true) return;
    if (!Get.isRegistered<AuthRepository>()) {
      Get.offAllNamed(AppRoutes.login);
      SosService.clearActive();
      return;
    }
    final message = await runApi(
      () => Get.find<AuthRepository>().deleteAccount(),
    );
    if (message == null) return;
    Get.offAllNamed(AppRoutes.login);
    SosService.clearActive();
    AppUtils.showSuccess(message);
  }
}

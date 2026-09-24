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
import '../../home/controllers/home_controller.dart';
import '../widgets/photo_source_sheet.dart';

class ProfileController extends GetxController with PageLoadingMixin {
  final user = AuthUser.placeholder().obs;
  final photoPath = RxnString();
  final isUploadingPhoto = false.obs;
  final ImagePicker _picker = ImagePicker();

  /// Real profile values only – no demo fallbacks.
  String get displayName => user.value.name.trim();

  String get displayPhone {
    final phone = user.value.phone.trim();
    if (phone.isEmpty) return '';
    return PhoneUtils.displayPhone(phone);
  }

  String get displayEmail {
    final email = user.value.email.trim();
    return email.isEmpty ? AppStrings.addEmail : email;
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
    // Live mode: never show the offline demo profile while loading.
    user.value = cached ??
        const AuthUser(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          city: '',
          status: '',
          walletBalance: 0,
          rating: 0,
          referralCode: '',
        );
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
    XFile? file;
    try {
      file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
    } catch (_) {
      AppUtils.showError(AppStrings.photoPickFailed);
      return;
    }
    if (file == null || isUploadingPhoto.value) return;
    // Show it right away; saved on the server so drivers see it too.
    photoPath.value = file.path;
    if (!Get.isRegistered<ProfileRepository>()) return;
    isUploadingPhoto.value = true;
    try {
      final path = file.path;
      final result = await runApi(
        () => Get.find<ProfileRepository>().uploadAvatar(path),
      );
      if (result == null) return;
      applyUser(result.user);
      AppUtils.showSuccess(AppStrings.photoUpdated);
    } finally {
      // Server photo from now on; a failed upload falls back to the old one.
      photoPath.value = null;
      isUploadingPhoto.value = false;
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
    _endSession();
    AppUtils.showSuccess(message);
  }

  /// Back to login and drop the session-wide ride state (HomeController is
  /// permanent), so the next account starts clean.
  void _endSession() {
    Get.offAllNamed(AppRoutes.login);
    SosService.clearActive();
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
  }

  Future<void> deleteAccount() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.deleteAccount,
      message: AppStrings.deleteAccountConfirm,
    );
    if (confirmed != true) return;
    if (!Get.isRegistered<AuthRepository>()) {
      _endSession();
      return;
    }
    final message = await runApi(
      () => Get.find<AuthRepository>().deleteAccount(),
    );
    if (message == null) return;
    _endSession();
    AppUtils.showSuccess(message);
  }
}

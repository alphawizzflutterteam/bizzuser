import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../../data/services/fcm_service.dart';
import '../../../data/services/push_notification_service.dart';
import '../../../data/services/ride_socket_service.dart';
import '../../../data/services/sos_service.dart';
import '../../../data/services/storage_service.dart';

class SplashController extends GetxController {
  static const Duration splashDuration = Duration(seconds: 2);

  final appName = AppStrings.appName.obs;
  final tagline = AppStrings.splashTagline.obs;
  final logoUrl = ''.obs;
  final rewardCopy = ''.obs;
  Timer? _navigationTimer;

  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void onReady() {
    super.onReady();
    _loadConfig();
    _navigationTimer = Timer(splashDuration, () {
      if (isClosed) return;
      _goNext();
    });
  }

  Future<void> _loadConfig() async {
    if (!Get.isRegistered<AppConfigRepository>()) return;
    try {
      final config = await Get.find<AppConfigRepository>().fetch().timeout(
        splashDuration,
      );
      if (isClosed) return;
      appName.value = config.displayName;
      tagline.value = config.displayTagline;
      logoUrl.value = config.mobileLogoUrl;
      if (config.referralRewardAmount > 0) {
        rewardCopy.value = AppStrings.referEarnSplash(
          AppUtils.rupee(config.referralRewardAmount),
        );
      }
    } catch (_) {}
  }

  void _goNext() {
    _restoreSystemUi();
    final loggedIn =
        Get.isRegistered<StorageService>() &&
        Get.find<StorageService>().hasSession;
    Get.offAllNamed(loggedIn ? AppRoutes.home : AppRoutes.login);
    if (loggedIn) {
      SosService.refreshIfLoggedIn();
      if (Get.isRegistered<RideSocketService>()) {
        Get.find<RideSocketService>().connect(force: true);
      }
      if (Get.isRegistered<FcmService>()) {
        Get.find<FcmService>().syncToken();
      }
    }
    if (!Get.isRegistered<PushNotificationService>()) return;
    if (loggedIn) {
      Get.find<PushNotificationService>().consumeLaunchTap();
    }
  }

  void _restoreSystemUi() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }
}

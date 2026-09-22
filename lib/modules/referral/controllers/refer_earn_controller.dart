import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/referral_info.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/referral_repository.dart';
import '../../profile/controllers/profile_controller.dart';

class ReferEarnController extends GetxController with PageLoadingMixin {
  final info = const ReferralInfo().obs;

  String get code {
    final value = info.value.code.trim();
    if (value.isNotEmpty) return value;
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>().user.value.referralCode.trim();
    }
    return '';
  }

  num get rewardAmount => info.value.rewardAmount;

  String get rewardLabel =>
      rewardAmount > 0 ? AppUtils.rupee(rewardAmount) : '';

  String get bodyCopy => rewardLabel.isEmpty
      ? AppStrings.referAndEarnHint
      : AppStrings.referEarnBody(rewardLabel);

  String get shareMessage {
    final custom = info.value.shareText.trim();
    if (custom.isNotEmpty) return custom;
    return AppStrings.referShareMessage(
      code: code.isEmpty ? AppStrings.fieldPlaceholder : code,
      amount: rewardLabel.isEmpty ? AppStrings.referralReward : rewardLabel,
      url: info.value.shareUrl,
    );
  }

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<ReferralRepository>()) {
      _applyFallbacks();
      stopPageLoading();
      return;
    }
    _load();
  }

  Future<void> _load() async {
    await runPageLoad(() async {
      if (Get.isRegistered<AppConfigRepository>() &&
          Get.find<AppConfigRepository>().cached == null) {
        try {
          await Get.find<AppConfigRepository>().fetch();
        } catch (_) {}
      }
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refreshProfile(showLoader: false);
      }
      var next = await Get.find<ReferralRepository>().fetch();
      if (next.code.isEmpty && Get.isRegistered<ProfileRepository>()) {
        next = next.copyWith(
          code: Get.find<ProfileRepository>().cachedUser()?.referralCode ?? '',
        );
      }
      info.value = next;
    });
  }

  void _applyFallbacks() {
    var amount = 0.0;
    if (Get.isRegistered<AppConfigRepository>()) {
      amount =
          (Get.find<AppConfigRepository>().cached?.referralRewardAmount ?? 0)
              .toDouble();
    }
    var nextCode = '';
    if (Get.isRegistered<ProfileController>()) {
      nextCode = Get.find<ProfileController>().user.value.referralCode;
    }
    info.value = ReferralInfo(code: nextCode, rewardAmount: amount);
  }

  Future<void> copyCode() async {
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    AppUtils.showSuccess(AppStrings.codeCopied);
  }

  Future<void> shareInvite() async {
    if (code.isEmpty && info.value.shareUrl.isEmpty) {
      await copyCode();
      return;
    }
    try {
      await SharePlus.instance.share(ShareParams(text: shareMessage));
    } catch (_) {
      await copyCode();
    }
  }
}

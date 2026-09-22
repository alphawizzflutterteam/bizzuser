import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: PopScope(
        canPop: false,
        child: SafeArea(child: SizedBox.expand(child: _SplashBody())),
      ),
    );
  }
}

class _SplashBody extends GetView<SplashController> {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.splashBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                final url = controller.logoUrl.value;
                if (url.isEmpty) {
                  return Image.asset(
                    AppAssets.logo,
                    width: 180,
                    fit: BoxFit.contain,
                  );
                }
                return Image.network(
                  url,
                  width: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    AppAssets.logo,
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                );
              }),
              const SizedBox(height: 18),
              Obx(
                () => AppText(
                  text: controller.appName.value,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlack,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => AppText(
                  text: controller.tagline.value,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              Obx(() {
                if (controller.rewardCopy.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AppText(
                    text: controller.rewardCopy.value,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlack,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

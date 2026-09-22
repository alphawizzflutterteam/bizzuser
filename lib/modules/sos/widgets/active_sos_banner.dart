import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/services/sos_service.dart';

class ActiveSosBanner extends StatelessWidget {
  const ActiveSosBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SosService>()) return const SizedBox.shrink();
    return Obx(() {
      final service = Get.find<SosService>();
      if (!service.hasActiveSos) return const SizedBox.shrink();
      return Material(
        color: AppColors.sosEmergencyBg,
        child: InkWell(
          onTap: service.openActive,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.sos_rounded,
                    color: AppColors.sosButton,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: AppText(
                      text: AppStrings.sosActiveBanner,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sosButton,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.sosButton,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../controllers/legal_document_controller.dart';

class LegalDocumentView extends GetView<LegalDocumentController> {
  const LegalDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Obx(() => PillHeader(title: controller.title.value)),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isPageLoading.value) {
                  return const AppPageLoader();
                }
                final items = controller.sections;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  children: [
                    AppText(
                      text: controller.updatedOn.value,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.tabInactive,
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      text: controller.intro.value,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.brandBlack,
                      height: 1.45,
                    ),
                    if (items.isNotEmpty) const SizedBox(height: 18),
                    for (final section in items) ...[
                      AppText(
                        text: section.title,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandBlack,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        text: section.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.tabInactive,
                        height: 1.5,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

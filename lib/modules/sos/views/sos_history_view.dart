import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../controllers/sos_history_controller.dart';

class SosHistoryView extends GetView<SosHistoryController> {
  const SosHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: AppStrings.sosHistory),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isPageLoading.value) {
                  return const AppPageLoader();
                }
                final items = controller.items;
                if (items.isEmpty) {
                  return const Center(
                    child: AppText(
                      text: AppStrings.noSosHistory,
                      color: AppColors.tabInactive,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () => controller.open(item),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.fieldBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: item.message.isEmpty
                                        ? AppStrings.sos
                                        : item.message,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  const SizedBox(height: 4),
                                  AppText(
                                    text: item.status.toUpperCase(),
                                    fontSize: 12,
                                    color: item.isOpen
                                        ? AppColors.sosButton
                                        : AppColors.tabInactive,
                                  ),
                                ],
                              ),
                            ),
                            AppText(
                              text: item.timeLabel,
                              fontSize: 11,
                              color: AppColors.tabInactive,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

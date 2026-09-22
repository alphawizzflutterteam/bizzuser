import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../data/models/legal_content.dart';
import '../controllers/faqs_controller.dart';

class FaqsView extends GetView<FaqsController> {
  const FaqsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: PillHeader(title: AppStrings.faqs),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isPageLoading.value) {
                    return const AppPageLoader();
                  }
                  final expanded = controller.expandedIndex.value;
                  final faqs = controller.items;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    itemCount: faqs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _FaqTile(
                        item: faqs[index],
                        expanded: expanded == index,
                        onTap: () => controller.toggle(index),
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

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final FaqItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: expanded ? AppColors.white : AppColors.fieldFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: expanded ? AppColors.white : AppColors.fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: expanded ? AppColors.fieldBorder : AppColors.transparent,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: item.title,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandBlack,
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.tabInactive,
                    ),
                  ],
                ),
                if (expanded) ...[
                  const SizedBox(height: 8),
                  AppText(
                    text: item.answer,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.tabInactive,
                    height: 1.45,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

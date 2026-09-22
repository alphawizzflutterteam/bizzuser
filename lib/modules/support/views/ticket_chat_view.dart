import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/support_ticket.dart';
import '../controllers/ticket_chat_controller.dart';

class TicketChatView extends GetView<TicketChatController> {
  const TicketChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() {
          final ticket = controller.ticket.value;
          return AppText(
            text: ticket?.title.isNotEmpty == true
                ? ticket!.title
                : AppStrings.helpAndSupport,
            style: AppTextStyles.heading,
            maxLines: 1,
          );
        }),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isPageLoading.value) {
                return const AppPageLoader();
              }
              final items = controller.messages;
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _TicketBubble(message: items[index]);
                },
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMedium,
                AppDimensions.paddingSmall,
                AppDimensions.paddingMedium,
                AppDimensions.paddingSmall,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.messageController,
                      hintText: AppStrings.typeHere,
                      fillColor: AppColors.fieldFill,
                      borderColor: AppColors.transparent,
                      borderRadius: AppDimensions.radiusXLarge,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.send(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Material(
                    color: AppColors.brandYellow,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: controller.send,
                      child: const SizedBox(
                        width: AppDimensions.sendButtonSize,
                        height: AppDimensions.sendButtonSize,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketBubble extends StatelessWidget {
  const _TicketBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.72,
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: mine ? AppColors.chatMine : AppColors.brandBlack,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: AppText(
                text: message.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: mine ? AppColors.brandBlack : AppColors.white,
                ),
              ),
            ),
            if (message.time.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingXSmall),
              AppText(
                text: message.time,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/ride_chips.dart';
import '../../../data/models/chat_message.dart';
import '../controllers/ride_chat_controller.dart';

class RideChatView extends GetView<RideChatController> {
  const RideChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() {
          final driver = controller.driver;
          return Row(
            children: [
              DriverAvatar(
                imageAsset: driver.photoAsset ?? '',
                imageUrl: driver.photoUrl.isNotEmpty
                    ? driver.resolvedPhoto
                    : null,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: AppText(
                  text: driver.hasName ? driver.name : AppStrings.yourDriver,
                  style: AppTextStyles.heading,
                  maxLines: 1,
                ),
              ),
            ],
          );
        }),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        actions: [
          IconButton(
            onPressed: controller.callDriver,
            icon: const Icon(Icons.call_outlined, color: AppColors.brandBlack),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isPageLoading.value) {
                return const AppPageLoader();
              }
              final items = controller.messages.toList();
              return ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                children: [
                  Center(
                    child: AppText(
                      text: AppStrings.chatDate,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  if (items.isNotEmpty) _ChatBubble(message: items.first),
                  if (items.length > 1) _ChatBubble(message: items[1]),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                          ),
                          child: AppText(
                            text: AppStrings.newMessage,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  ...items
                      .skip(2)
                      .map((message) => _ChatBubble(message: message)),
                ],
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
                  Obx(() {
                    final sending = controller.isSending.value;
                    return Material(
                      color: AppColors.brandYellow,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: sending ? null : controller.send,
                        child: SizedBox(
                          width: AppDimensions.sendButtonSize,
                          height: AppDimensions.sendButtonSize,
                          child: sending
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.white,
                                ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.hasAttachment)
                    _ChatPhoto(url: message.attachmentUrl, mine: mine),
                  if (message.hasAttachment && message.text.isNotEmpty)
                    const SizedBox(height: AppDimensions.paddingSmall),
                  if (message.text.isNotEmpty)
                    AppText(
                      text: message.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: mine ? AppColors.brandBlack : AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXSmall),
            AppText(
              text: message.time,
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

/// Photo sent in chat; tap opens it full screen (pinch to zoom).
class _ChatPhoto extends StatelessWidget {
  const _ChatPhoto({required this.url, required this.mine});

  final String url;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final iconColor = mine ? AppColors.brandBlack : AppColors.white;
    return GestureDetector(
      onTap: () => Get.to<void>(
        () => _PhotoPreview(url: url),
        fullscreenDialog: true,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Image.network(
          url,
          width: 220,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: 220,
              height: 160,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              ),
            );
          },
          errorBuilder: (_, _, _) => SizedBox(
            width: 220,
            height: 120,
            child: Icon(Icons.broken_image_outlined, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const CircularProgressIndicator(color: Colors.white);
              },
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white70,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

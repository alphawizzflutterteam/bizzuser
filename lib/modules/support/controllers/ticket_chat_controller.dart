import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/models/support_ticket.dart';
import '../../../data/repositories/support_repository.dart';

class TicketChatController extends GetxController with PageLoadingMixin {
  final ticket = Rxn<SupportTicket>();
  final messages = <SupportMessage>[].obs;
  final isLoading = false.obs;
  final messageController = TextEditingController();

  String get ticketId {
    final current = ticket.value;
    if (current == null) return '';
    return current.id.isNotEmpty ? current.id : current.ticketCode;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is SupportTicket) {
      ticket.value = args;
      messages.assignAll(args.messages);
    }
    if (ticketId.isEmpty || !Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    if (ticketId.isEmpty || !Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final result = await Get.find<SupportRepository>().fetchTicket(ticketId);
      ticket.value = result;
      if (result.messages.isNotEmpty) {
        messages.assignAll(result.messages);
      }
    });
  }

  Future<void> send() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    AppUtils.hideKeyboard();
    if (!Get.isRegistered<SupportRepository>()) {
      messages.add(
        SupportMessage(text: text, isMine: true, time: AppStrings.chatTime),
      );
      messageController.clear();
      return;
    }
    try {
      isLoading.value = true;
      final result = await runApi(
        () => Get.find<SupportRepository>().sendMessage(
          ticketId: ticketId,
          text: text,
        ),
      );
      if (result == null) return;
      messages.add(result);
      messageController.clear();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

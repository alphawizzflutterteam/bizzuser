import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/ride_booking.dart';
import '../../../data/models/ride_driver.dart';
import '../../../data/repositories/ride_catalog.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../data/services/ride_socket_service.dart';
import '../../home/controllers/home_controller.dart';

class RideChatController extends GetxController with PageLoadingMixin {
  final ride = Rxn<RideBooking>();
  final messages = <ChatMessage>[].obs;
  final isSending = false.obs;
  final messageController = TextEditingController();
  Worker? _chatWorker;

  String get rideId {
    final current = ride.value;
    if (current != null && current.id.isNotEmpty) return current.id;
    final args = Get.arguments;
    if (args is String) return args;
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().liveRide?.id ?? '';
    }
    return '';
  }

  RideDriver get driver => ride.value?.driver ?? RideCatalog.driver;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RideBooking) {
      ride.value = args;
    } else if (Get.isRegistered<HomeController>()) {
      ride.value = Get.find<HomeController>().liveRide;
    }
    _listenSocket();
    if (rideId.isEmpty || !Get.isRegistered<RideRepository>()) {
      messages.assignAll(RideCatalog.chatThread);
      stopPageLoading();
      return;
    }
    loadMessages();
  }

  void _listenSocket() {
    if (!Get.isRegistered<RideSocketService>()) return;
    _chatWorker = ever(Get.find<RideSocketService>().incomingChat, (message) {
      if (message == null || message.text.isEmpty) return;
      final currentRideId = rideId;
      if (message.rideId.isNotEmpty &&
          currentRideId.isNotEmpty &&
          message.rideId != currentRideId) {
        return;
      }
      final exists = messages.any(
        (item) => item.id.isNotEmpty && item.id == message.id,
      );
      if (exists) return;
      messages.add(message);
    });
  }

  Future<void> loadMessages() async {
    if (rideId.isEmpty || !Get.isRegistered<RideRepository>()) {
      messages.assignAll(RideCatalog.chatThread);
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      messages.assignAll(
        await Get.find<RideRepository>().fetchMessages(rideId),
      );
    });
  }

  Future<void> send() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;
    AppUtils.hideKeyboard();
    if (!Get.isRegistered<RideRepository>() || rideId.isEmpty) {
      messages.add(
        ChatMessage(text: text, isMine: true, time: AppStrings.chatTime),
      );
      messageController.clear();
      return;
    }
    try {
      isSending.value = true;
      final result = await runApi(
        () => Get.find<RideRepository>().sendMessage(
          rideId: rideId,
          text: text,
        ),
      );
      if (result == null) return;
      if (Get.isRegistered<RideSocketService>()) {
        Get.find<RideSocketService>().sendChat(rideId: rideId, text: text);
      }
      if (result.text.isEmpty) {
        messages.assignAll(
          await Get.find<RideRepository>().fetchMessages(rideId),
        );
      } else {
        messages.add(result);
      }
      messageController.clear();
    } finally {
      isSending.value = false;
    }
  }

  void callDriver() {
    final phone = driver.phone.trim();
    if (phone.isNotEmpty) {
      AppUtils.showInfo('${AppStrings.callingDriver} $phone');
      return;
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().callDriver();
      return;
    }
    AppUtils.showInfo(
      '${AppStrings.callingDriver} ${RideCatalog.driver.phone}',
    );
  }

  @override
  void onClose() {
    _chatWorker?.dispose();
    messageController.dispose();
    super.onClose();
  }
}

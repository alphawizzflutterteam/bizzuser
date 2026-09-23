import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/phone_call.dart';
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

  static final Random _random = Random();

  RideDriver get driver =>
      ride.value?.driver ??
      const RideDriver(name: '', rating: '', phone: '', vehicleNumber: '');

  /// One id per outgoing message, shared by the socket send and the REST
  /// fallback so the server stores it only once.
  static String _newClientId() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 32).toRadixString(36);
    return 'u-$now-$salt';
  }

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
      _addUnique(message);
    });
  }

  /// Adds [message] unless a message with the same `_id` is already shown
  /// (socket echo of our own send, REST + socket, reconnect replays).
  void _addUnique(ChatMessage message) {
    if (message.text.isEmpty) return;
    final id = message.id.trim();
    if (id.isNotEmpty && messages.any((item) => item.id == id)) return;
    messages.add(message);
  }

  List<ChatMessage> _dedupe(List<ChatMessage> items) {
    final seen = <String>{};
    final out = <ChatMessage>[];
    for (final item in items) {
      final id = item.id.trim();
      if (id.isNotEmpty && !seen.add(id)) continue;
      out.add(item);
    }
    return out;
  }

  Future<void> loadMessages() async {
    if (rideId.isEmpty || !Get.isRegistered<RideRepository>()) {
      messages.assignAll(RideCatalog.chatThread);
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final fetched = await Get.find<RideRepository>().fetchMessages(rideId);
      // Keep socket messages that arrived while the request was in flight.
      messages.assignAll(_dedupe([...fetched, ...messages]));
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
    final id = rideId;
    final clientId = _newClientId();
    try {
      isSending.value = true;
      // Socket first (with ack). REST only when the ack fails / times out,
      // so a message is never sent twice.
      ChatMessage? sent;
      if (Get.isRegistered<RideSocketService>()) {
        sent = await Get.find<RideSocketService>().sendChat(
          rideId: id,
          text: text,
          clientId: clientId,
        );
      }
      sent ??= await runApi(
        () => Get.find<RideRepository>().sendMessage(
          rideId: id,
          text: text,
          clientId: clientId,
        ),
      );
      if (sent == null) return;
      messageController.clear();
      if (sent.text.isEmpty) {
        final fetched = await Get.find<RideRepository>().fetchMessages(id);
        messages.assignAll(_dedupe(fetched));
      } else {
        _addUnique(sent);
      }
    } catch (_) {
      // fetchMessages failure after a successful send – message is saved.
    } finally {
      isSending.value = false;
    }
  }

  void callDriver() {
    final phone = driver.phone.trim();
    if (phone.isEmpty && Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      if (home.activeRideId.isNotEmpty && home.activeRideId == rideId) {
        home.callDriver();
        return;
      }
    }
    unawaited(launchDialer(phone));
  }

  @override
  void onClose() {
    _chatWorker?.dispose();
    messageController.dispose();
    super.onClose();
  }
}

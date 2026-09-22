import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/chat_message.dart';
import '../repositories/notification_repository.dart';
import 'storage_service.dart';

class RideSocketService extends GetxService {
  io.Socket? _socket;
  String _authToken = '';
  String _activeRideId = '';

  final lastRideId = ''.obs;
  final lastLat = 0.0.obs;
  final lastLng = 0.0.obs;
  final lastLocationAt = ''.obs;
  final lastStatus = ''.obs;
  final lastPaymentStatus = ''.obs;
  final incomingChat = Rxn<ChatMessage>();
  final notificationTick = 0.obs;

  String get activeRideId => _activeRideId;

  bool get isConnected => _socket?.connected == true;

  void connect({bool force = false}) {
    final token = Get.isRegistered<StorageService>()
        ? Get.find<StorageService>().accessToken?.trim() ?? ''
        : '';
    if (token.isEmpty) {
      disconnect();
      return;
    }
    if (!force && _socket != null && _authToken == token) return;
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
    _authToken = token;
    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );
    _socket!
      ..onConnect((_) {
        if (_activeRideId.isNotEmpty) {
          _socket?.emit('ride:join', _activeRideId);
        }
      })
      ..on('ride:status', _onStatus)
      ..on('ride:payment', _onPayment)
      ..on('ride:location', _onLocation)
      ..on('chat:message', _onChat)
      ..on('notification', _onNotification);
  }

  void joinRide(String rideId) {
    final id = rideId.trim();
    if (id.isEmpty) return;
    connect();
    _activeRideId = id;
    if (isConnected) {
      _socket?.emit('ride:join', id);
    }
  }

  void leaveRide() {
    _activeRideId = '';
    lastRideId.value = '';
    lastStatus.value = '';
    lastPaymentStatus.value = '';
    lastLat.value = 0;
    lastLng.value = 0;
    lastLocationAt.value = '';
  }

  void sendChat({required String rideId, required String text}) {
    final id = rideId.trim();
    final message = text.trim();
    if (id.isEmpty || message.isEmpty) return;
    connect();
    _socket?.emit('chat:send', {'rideId': id, 'text': message});
  }

  void disconnect() {
    leaveRide();
    _socket?.dispose();
    _socket = null;
    _authToken = '';
  }

  /// Testable filter used by unit tests and socket handlers.
  bool acceptsRideId(String payloadRideId) {
    final active = _activeRideId.trim();
    if (active.isEmpty) return false;
    final id = payloadRideId.trim();
    if (id.isEmpty) return false;
    return id == active;
  }

  static String rideIdFrom(Map<String, dynamic> map) {
    final direct = (map['rideId'] ?? map['ride_id'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;
    final nested = ApiBody.asMap(map['ride']);
    if (nested == null) return '';
    return (nested['_id'] ?? nested['id'] ?? '').toString().trim();
  }

  void _onStatus(dynamic raw) {
    final map = ApiBody.asMap(raw) ?? {};
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    lastRideId.value = rideId;
    lastStatus.value = (map['status'] ?? '').toString();
    final payment = (map['paymentStatus'] ?? '').toString();
    if (payment.isNotEmpty) lastPaymentStatus.value = payment;
  }

  void _onPayment(dynamic raw) {
    final map = ApiBody.asMap(raw) ?? {};
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    lastRideId.value = rideId;
    lastPaymentStatus.value = (map['paymentStatus'] ?? '').toString();
    final status = (map['status'] ?? '').toString();
    if (status.isNotEmpty) lastStatus.value = status;
  }

  void _onLocation(dynamic raw) {
    final map = ApiBody.asMap(raw) ?? {};
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    lastRideId.value = rideId;
    lastLat.value = ApiBody.asNum(map['lat'] ?? map['latitude']).toDouble();
    lastLng.value = ApiBody.asNum(map['lng'] ?? map['longitude']).toDouble();
    lastLocationAt.value = (map['at'] ?? map['updatedAt'] ?? '').toString();
  }

  void _onChat(dynamic raw) {
    final map = ApiBody.asMap(raw);
    if (map == null || map.isEmpty) return;
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    lastRideId.value = rideId;
    incomingChat.value = ChatMessage.fromJson(map);
  }

  void _onNotification(dynamic raw) {
    notificationTick.value++;
    if (!Get.isRegistered<NotificationRepository>()) return;
    // Fire-and-forget refresh; HomeController / Notifications listen via tick.
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

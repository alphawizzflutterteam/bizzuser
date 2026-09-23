import 'dart:async';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/chat_message.dart';
import 'storage_service.dart';

/// Latest filtered [ride:status] payload for the active ride.
///
/// See Backend `docs/ride-events.md` – extras per status:
/// - `searching`: `wave`, `radiusKm`, `driversNotified`
/// - `accepted`: `driverId`, `otp`, `driver{}`, `vehicle{}`
/// - `completed`: `fare`
/// - `cancelled`: `reason`, `cancelledBy`
class RideStatusEvent {
  const RideStatusEvent({
    required this.rideId,
    required this.status,
    this.otp = '',
    this.paymentStatus = '',
    this.reason = '',
    this.cancelledBy = '',
    this.fare,
    this.driverId = '',
    this.driver,
    this.vehicle,
    this.wave,
    this.radiusKm,
    this.driversNotified,
  });

  final String rideId;
  final String status;
  final String otp;
  final String paymentStatus;
  final String reason;
  final String cancelledBy;
  final double? fare;
  final String driverId;
  final Map<String, dynamic>? driver;
  final Map<String, dynamic>? vehicle;
  final int? wave;
  final double? radiusKm;
  final int? driversNotified;

  String get normalizedStatus => status.trim().toLowerCase();
}

/// Single driver GPS sample – applied as ONE observable update so the map
/// moves once per event (no lat/lng half-updates).
class DriverLocationEvent {
  const DriverLocationEvent({
    required this.rideId,
    required this.lat,
    required this.lng,
    this.heading,
    this.at = '',
  });

  final String rideId;
  final double lat;
  final double lng;
  final double? heading;
  final String at;

  bool get isValid => lat != 0 || lng != 0;
}

/// Latest [ride:payment] payload for the active ride.
class RidePaymentEvent {
  const RidePaymentEvent({
    required this.rideId,
    required this.paymentStatus,
    this.paymentMethod = '',
  });

  final String rideId;
  final String paymentStatus;
  final String paymentMethod;
}

class RideSocketService extends GetxService {
  static const Duration chatAckTimeout = Duration(seconds: 5);

  io.Socket? _socket;
  String _authToken = '';
  String _activeRideId = '';

  final lastRideId = ''.obs;
  final lastLocation = Rxn<DriverLocationEvent>();
  final lastStatus = ''.obs;
  final lastOtp = ''.obs;
  final lastPaymentStatus = ''.obs;
  final lastPaymentEvent = Rxn<RidePaymentEvent>();
  final lastCancelReason = ''.obs;
  final lastStatusEvent = Rxn<RideStatusEvent>();
  final incomingChat = Rxn<ChatMessage>();
  final notificationTick = 0.obs;

  /// True while the socket is connected (updated from connect / disconnect /
  /// connect_error handlers).
  final isConnected = false.obs;

  String get activeRideId => _activeRideId;

  String _currentToken() {
    if (!Get.isRegistered<StorageService>()) return '';
    return Get.find<StorageService>().accessToken?.trim() ?? '';
  }

  /// Connects only when needed. No-op when a socket for the same token is
  /// already connected or connecting. A new socket is created only when the
  /// token changed (e.g. after login). Without a token the socket is closed.
  void ensureConnected() {
    final token = _currentToken();
    if (token.isEmpty) {
      disconnect();
      return;
    }
    final socket = _socket;
    if (socket != null && _authToken == token) {
      // Connected, or the manager is (re)connecting – nothing to do.
      if (socket.connected || socket.active) return;
      socket.connect();
      return;
    }
    _open(token);
  }

  void _open(String token) {
    _disposeSocket();
    _authToken = token;
    final socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );
    _socket = socket;
    socket
      ..onConnect((_) {
        isConnected.value = true;
        // Legacy no-op on the server (personal rooms), kept for compatibility.
        if (_activeRideId.isNotEmpty) {
          socket.emit('ride:join', _activeRideId);
        }
      })
      ..onDisconnect((_) {
        isConnected.value = false;
      })
      ..onConnectError((_) {
        isConnected.value = false;
      })
      ..on('ride:status', _onStatus)
      ..on('ride:payment', _onPayment)
      ..on('ride:location', _onLocation)
      ..on('chat:message', _onChat)
      ..on('notification', _onNotification);
  }

  void _disposeSocket() {
    final socket = _socket;
    _socket = null;
    if (socket != null) {
      socket.clearListeners();
      socket.dispose();
    }
    isConnected.value = false;
  }

  void joinRide(String rideId) {
    final id = rideId.trim();
    if (id.isEmpty) return;
    ensureConnected();
    if (_activeRideId != id) {
      _resetRideState();
    }
    _activeRideId = id;
    if (isConnected.value) {
      _socket?.emit('ride:join', id);
    }
  }

  void leaveRide() {
    _activeRideId = '';
    _resetRideState();
  }

  void _resetRideState() {
    lastRideId.value = '';
    lastStatus.value = '';
    lastOtp.value = '';
    lastPaymentStatus.value = '';
    lastPaymentEvent.value = null;
    lastCancelReason.value = '';
    lastStatusEvent.value = null;
    lastLocation.value = null;
  }

  /// Sends a chat message over the socket and waits for the server ack.
  ///
  /// Returns the saved message on success, or `null` when the socket is not
  /// connected, the ack reports a failure, or no ack arrives within
  /// [chatAckTimeout]. Callers should fall back to REST only on `null`.
  Future<ChatMessage?> sendChat({
    required String rideId,
    required String text,
    String clientId = '',
  }) async {
    final id = rideId.trim();
    final message = text.trim();
    if (id.isEmpty || message.isEmpty) return null;
    final socket = _socket;
    // Never buffer: a buffered emit could be flushed later and duplicate a
    // REST fallback message.
    if (socket == null || !socket.connected) return null;

    final completer = Completer<ChatMessage?>();
    void finish(ChatMessage? value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    socket
        .timeout(chatAckTimeout.inMilliseconds)
        .emitWithAck(
          'chat:send',
          {
            'rideId': id,
            'text': message,
            if (clientId.trim().isNotEmpty) 'clientId': clientId.trim(),
          },
          ack: ([dynamic first, dynamic second]) {
            if (first != null) {
              // Timeout / transport error.
              finish(null);
              return;
            }
            final map = ApiBody.asMap(second);
            if (map == null || map['success'] != true) {
              finish(null);
              return;
            }
            final data = ApiBody.asMap(map['data']) ?? const {};
            finish(
              ChatMessage.fromJson({
                ...data,
                if (!data.containsKey('rideId')) 'rideId': id,
              }),
            );
          },
        );
    // Safety net in case the ack callback is never invoked.
    return completer.future.timeout(
      chatAckTimeout + const Duration(seconds: 1),
      onTimeout: () => null,
    );
  }

  /// Closes the socket (logout / session cleared).
  void disconnect() {
    leaveRide();
    _disposeSocket();
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

  /// Reads `rideId` / `ride_id`, or `ride` as a plain id string or a map with
  /// `_id` / `id` (chat:message docs carry `ride`).
  static String rideIdFrom(Map<String, dynamic> map) {
    final direct = (map['rideId'] ?? map['ride_id'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;
    final ride = map['ride'];
    if (ride is String) return ride.trim();
    final nested = ApiBody.asMap(ride);
    if (nested == null) return '';
    return (nested['_id'] ?? nested['id'] ?? '').toString().trim();
  }

  static double? _optDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static int? _optInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  void _onStatus(dynamic raw) {
    final map = ApiBody.asMap(raw) ?? {};
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    final status = (map['status'] ?? '').toString().trim();
    if (status.isEmpty) return;
    final otp = (map['otp'] ?? '').toString().trim();
    final payment = (map['paymentStatus'] ?? '').toString().trim();
    final reason =
        (map['reason'] ?? map['cancelReason'] ?? '').toString().trim();
    final fare = _optDouble(map['fare'] ?? map['total']);

    lastRideId.value = rideId;
    lastStatus.value = status;
    if (otp.isNotEmpty) lastOtp.value = otp;
    if (payment.isNotEmpty) lastPaymentStatus.value = payment;
    if (reason.isNotEmpty) lastCancelReason.value = reason;
    lastStatusEvent.value = RideStatusEvent(
      rideId: rideId,
      status: status,
      otp: otp.isNotEmpty ? otp : lastOtp.value,
      paymentStatus: payment,
      reason: reason,
      cancelledBy: (map['cancelledBy'] ?? '').toString().trim(),
      fare: fare,
      driverId: (map['driverId'] ?? '').toString().trim(),
      driver: ApiBody.asMap(map['driver']),
      vehicle: ApiBody.asMap(map['vehicle']),
      wave: _optInt(map['wave']),
      radiusKm: _optDouble(map['radiusKm']),
      driversNotified: _optInt(map['driversNotified']),
    );
  }

  void _onPayment(dynamic raw) {
    final map = ApiBody.asMap(raw) ?? {};
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    final status = (map['paymentStatus'] ?? '').toString().trim();
    lastRideId.value = rideId;
    lastPaymentStatus.value = status;
    lastPaymentEvent.value = RidePaymentEvent(
      rideId: rideId,
      paymentStatus: status,
      paymentMethod: (map['paymentMethod'] ?? '').toString().trim(),
    );
  }

  void _onLocation(dynamic raw) {
    final map = ApiBody.asMap(raw) ?? {};
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    final lat = ApiBody.asNum(map['lat'] ?? map['latitude']).toDouble();
    final lng = ApiBody.asNum(map['lng'] ?? map['longitude']).toDouble();
    if (lat == 0 && lng == 0) return;
    lastRideId.value = rideId;
    lastLocation.value = DriverLocationEvent(
      rideId: rideId,
      lat: lat,
      lng: lng,
      heading: _optDouble(map['heading']),
      at: (map['at'] ?? map['updatedAt'] ?? '').toString(),
    );
  }

  void _onChat(dynamic raw) {
    final map = ApiBody.asMap(raw);
    if (map == null || map.isEmpty) return;
    final rideId = rideIdFrom(map);
    if (!acceptsRideId(rideId)) return;
    lastRideId.value = rideId;
    incomingChat.value = ChatMessage.fromJson({...map, 'rideId': rideId});
  }

  void _onNotification(dynamic raw) {
    notificationTick.value++;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

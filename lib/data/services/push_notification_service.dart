import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/notifications/controllers/notifications_controller.dart';
import 'fcm_service.dart';
import 'sos_service.dart';
import 'storage_service.dart';

const _channelId = 'bizz_user_notifications';
const _channelName = 'Bizz alerts';
const _channelDesc = 'Ride and account notifications';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  if (message.notification == null) {
    await PushNotificationService.showLocalFromRemote(message);
  }
}

class PushNotificationService extends GetxService {
  PushNotificationService();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _localReady = false;
  static Map<String, dynamic>? _pendingPayload;

  Future<PushNotificationService> init() async {
    if (!_supported) return this;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {
      return this;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initLocal();
    await _requestPermission();
    await _createAndroidChannel();

    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    final launched = await FirebaseMessaging.instance.getInitialMessage();
    if (launched != null) {
      _pendingPayload = _payloadOf(launched);
    }

    if (Get.isRegistered<FcmService>()) {
      await Get.find<FcmService>().init();
      await Get.find<FcmService>().syncToken();
    }
    return this;
  }

  static bool get _supported {
    if (kIsWeb) return false;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _initLocal() async {
    if (_localReady) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = _decodePayload(response.payload);
        if (payload.isEmpty) return;
        if (Get.currentRoute == AppRoutes.splash || Get.currentRoute.isEmpty) {
          _pendingPayload = payload;
          return;
        }
        openFromPayload(payload);
      },
    );
    _localReady = true;
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> onAppResumed() async {
    if (Get.isRegistered<FcmService>()) {
      await Get.find<FcmService>().syncToken();
    }
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshUnreadCount();
    }
    if (Get.isRegistered<NotificationsController>()) {
      await Get.find<NotificationsController>().loadNotifications();
    }
  }

  void consumeLaunchTap() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    if (payload == null || payload.isEmpty) return;
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      openFromPayload(payload);
    });
  }

  Future<void> _onForeground(RemoteMessage message) async {
    await showLocalFromRemote(message);
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshUnreadCount();
    }
    if (Get.isRegistered<NotificationsController>()) {
      await Get.find<NotificationsController>().loadNotifications();
    }
  }

  void _onOpened(RemoteMessage message) {
    openFromPayload(_payloadOf(message));
  }

  static Future<void> showLocalFromRemote(RemoteMessage message) async {
    if (!_localReady) {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _local.initialize(
        const InitializationSettings(
          android: android,
          iOS: DarwinInitializationSettings(),
        ),
      );
      _localReady = true;
    }
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Bizz';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';
    if (title.isEmpty && body.isEmpty) return;
    final id = message.hashCode & 0x7fffffff;
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(_payloadOf(message)),
    );
  }

  static Map<String, dynamic> _payloadOf(RemoteMessage message) {
    return {
      ...message.data,
      if (message.notification?.title != null)
        'title': message.notification!.title,
      if (message.notification?.body != null)
        'body': message.notification!.body,
    };
  }

  static Map<String, dynamic> _decodePayload(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return const {};
  }

  static void openFromPayload(Map<String, dynamic> data) {
    if (!Get.isRegistered<StorageService>() ||
        !Get.find<StorageService>().hasSession) {
      return;
    }
    final type = (data['type'] ?? '').toString().trim().toLowerCase();
    final rideId = (data['rideId'] ?? '').toString().trim();
    final sosId = (data['sosId'] ?? '').toString().trim();

    if (type == 'sos' || sosId.isNotEmpty) {
      if (Get.isRegistered<SosService>()) {
        Get.find<SosService>().refreshActive(silent: true).then((_) {
          Get.find<SosService>().openActive();
        });
        return;
      }
      Get.toNamed(AppRoutes.sosHelp);
      return;
    }

    if (type == 'booking' || rideId.isNotEmpty) {
      if (rideId.isNotEmpty) {
        // Load the real ride (live → live screens, finished → detail page)
        // instead of opening Booking Detail with placeholder driver data.
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().openRideById(rideId);
          return;
        }
        if (Get.currentRoute != AppRoutes.home) {
          Get.offAllNamed(AppRoutes.home);
        }
        return;
      }
      if (Get.currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
      return;
    }

    if (Get.currentRoute == AppRoutes.notifications) {
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().loadNotifications();
      }
      return;
    }
    Get.toNamed(AppRoutes.notifications);
  }
}

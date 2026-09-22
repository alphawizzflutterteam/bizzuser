import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'data/services/fcm_service.dart';
import 'data/services/push_notification_service.dart';
import 'data/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final fcm = Get.put<FcmService>(FcmService(), permanent: true);
  final push = PushNotificationService();
  Get.put<PushNotificationService>(push, permanent: true);
  await push.init();

  final authToken = GetStorage().read<String>(StorageKeys.accessToken) ?? '';
  final fcmToken = await fcm.getToken();
  print('FCM token: $fcmToken');
  print('Auth token: $authToken');

  runApp(const MyApp());
}

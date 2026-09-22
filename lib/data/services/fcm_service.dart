import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../repositories/profile_repository.dart';
import 'storage_service.dart';

class FcmService extends GetxService {
  FcmService();

  Future<FcmService> init() async {
    if (!_supported) return this;
    try {
      if (Firebase.apps.isEmpty) return this;
      FirebaseMessaging.instance.onTokenRefresh.listen(syncToken);
    } catch (_) {}
    return this;
  }

  Future<String> getToken() async {
    if (_supported) {
      try {
        if (Firebase.apps.isNotEmpty) {
          final token =
              (await FirebaseMessaging.instance.getToken())?.trim() ?? '';
          if (token.isNotEmpty) {
            if (Get.isRegistered<StorageService>()) {
              Get.find<StorageService>().write(StorageKeys.fcmToken, token);
            }
            return token;
          }
        }
      } catch (_) {}
    }
    return _storedToken();
  }

  String _storedToken() {
    if (!Get.isRegistered<StorageService>()) return '';
    return Get.find<StorageService>().read<String>(StorageKeys.fcmToken)?.trim() ??
        '';
  }

  Future<void> syncToken([String? next]) async {
    final token = (next ?? await getToken()).trim();
    if (token.isEmpty) return;
    if (!Get.isRegistered<StorageService>()) return;
    final storage = Get.find<StorageService>();
    storage.write(StorageKeys.fcmToken, token);
    if (!storage.hasSession) return;
    final uploaded = storage.read<String>(StorageKeys.uploadedFcmToken) ?? '';
    if (uploaded == token) return;
    if (!Get.isRegistered<ProfileRepository>()) return;
    try {
      await Get.find<ProfileRepository>().updateFcmToken(token);
      markUploaded(token);
    } catch (_) {}
  }

  void markUploaded(String token) {
    final value = token.trim();
    if (value.isEmpty || !Get.isRegistered<StorageService>()) return;
    final storage = Get.find<StorageService>();
    storage.write(StorageKeys.fcmToken, value);
    storage.write(StorageKeys.uploadedFcmToken, value);
  }

  Future<void> clearOnLogout() async {
    try {
      if (_supported && Firebase.apps.isNotEmpty) {
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (_) {}
    if (!Get.isRegistered<StorageService>()) return;
    final storage = Get.find<StorageService>();
    await storage.remove(StorageKeys.fcmToken);
    await storage.remove(StorageKeys.uploadedFcmToken);
  }

  static bool get _supported {
    if (kIsWeb) return false;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}

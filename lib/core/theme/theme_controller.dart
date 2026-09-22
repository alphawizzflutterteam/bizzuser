import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/storage_service.dart';

class ThemeController extends GetxController {
  ThemeController({StorageService? storageService})
    : _storage = storageService ?? Get.find<StorageService>();

  final StorageService _storage;

  final isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read<bool>(StorageKeys.themeDark) ?? false;
    Get.changeThemeMode(themeMode);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(StorageKeys.themeDark, isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }
}

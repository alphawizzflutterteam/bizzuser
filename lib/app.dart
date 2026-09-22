import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/bindings/initial_binding.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/push_notification_service.dart';
import 'data/services/ride_socket_service.dart';
import 'data/services/sos_service.dart';
import 'modules/home/controllers/home_controller.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().onAppResumed();
    }
    SosService.refreshIfLoggedIn();
    if (Get.isRegistered<RideSocketService>()) {
      Get.find<RideSocketService>().connect(force: true);
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().resumeActiveRide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.isRegistered<ThemeController>()
          ? Get.find<ThemeController>().themeMode
          : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
    );
  }
}

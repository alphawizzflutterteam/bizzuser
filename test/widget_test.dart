import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bizzuser/app.dart';
import 'package:bizzuser/core/constants/app_strings.dart';
import 'package:bizzuser/modules/splash/controllers/splash_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return '.';
            }
            return null;
          },
        );
    await GetStorage.init();
    await GetStorage().erase();
  });

  tearDown(Get.reset);

  testWidgets('Splash screen is shown first', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text(AppStrings.loginTitle), findsNothing);
    expect(find.text(AppStrings.getOtp), findsNothing);
  });

  testWidgets('Splash navigates to login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(SplashController.splashDuration);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.getOtp), findsOneWidget);
    expect(find.text(AppStrings.mobileNumber), findsOneWidget);
  });
}

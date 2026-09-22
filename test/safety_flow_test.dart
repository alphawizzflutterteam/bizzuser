import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:bizzuser/core/constants/app_strings.dart';
import 'package:bizzuser/core/routes/app_pages.dart';
import 'package:bizzuser/core/theme/app_theme.dart';
import 'package:bizzuser/data/models/sos_alert.dart';
import 'package:bizzuser/data/services/sos_service.dart';
import 'package:bizzuser/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:bizzuser/modules/dashboard/views/dashboard_view.dart';
import 'package:bizzuser/modules/home/controllers/home_controller.dart';
import 'package:bizzuser/modules/sos/controllers/sos_controller.dart';
import 'package:bizzuser/modules/sos/views/sos_view.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('Notifications and SOS confirm sheet', (tester) async {
    Get.put(DashboardController());
    Get.put(HomeController());

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        getPages: AppPages.pages,
        home: const DashboardView(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.notificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.rideConfirmed), findsOneWidget);
    expect(find.text(AppStrings.driverAssigned), findsOneWidget);
    expect(find.text(AppStrings.paymentSuccessful), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.sos));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.sosConfirmTitle), findsOneWidget);
    expect(find.text(AppStrings.sosConfirmMessage), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.sosConfirmMessage), findsNothing);
  });

  testWidgets('Active SOS screen shows dial, share, report, and cancel', (
    tester,
  ) async {
    Get.put(SosService()).activeSos.value = const SosAlert(
      id: 'sos-1',
      status: 'open',
      message: 'Need help',
      lat: 22.74,
      lng: 75.88,
      mapsUrl: 'https://www.google.com/maps?q=22.74,75.88',
      shareUrl: 'https://example.com/public/rides/share/abc',
      sosNumbers: ['112', '100'],
    );
    Get.put(SosController());

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        getPages: AppPages.pages,
        home: const SosView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.sosActiveTitle), findsOneWidget);
    expect(find.text(AppStrings.sosOpen), findsOneWidget);
    expect(find.text('Need help'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text(AppStrings.shareLiveRide), findsOneWidget);
    expect(find.text(AppStrings.reportSafetyIssue), findsOneWidget);
    expect(find.text(AppStrings.falseAlarm), findsOneWidget);

    await tester.ensureVisible(find.text(AppStrings.reportSafetyIssue));
    await tester.tap(find.text(AppStrings.reportSafetyIssue));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.harassment), findsOneWidget);
    expect(find.text(AppStrings.otherReason), findsOneWidget);

    await tester.tap(find.text(AppStrings.submit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.sosActiveTitle), findsOneWidget);
    expect(find.text(AppStrings.falseAlarm), findsOneWidget);
  });
}

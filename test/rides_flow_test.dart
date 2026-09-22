import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:bizzuser/core/constants/app_strings.dart';
import 'package:bizzuser/core/routes/app_pages.dart';
import 'package:bizzuser/core/theme/app_theme.dart';
import 'package:bizzuser/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:bizzuser/modules/dashboard/views/dashboard_view.dart';
import 'package:bizzuser/modules/home/controllers/home_controller.dart';

void main() {
  tearDown(Get.reset);

  Future<void> pumpDashboard(WidgetTester tester) async {
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
  }

  testWidgets('Rides tab shows My Bookings ongoing card', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text(AppStrings.ridesTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.myBookings), findsOneWidget);
    expect(find.text(AppStrings.ongoing), findsOneWidget);
    expect(find.text(AppStrings.completed), findsOneWidget);
    expect(find.text(AppStrings.cancelledTab), findsOneWidget);
    expect(
      find.text('${AppStrings.bookingIdPrefix}${AppStrings.bookingIdValue}'),
      findsOneWidget,
    );
    expect(find.text(AppStrings.onTheWay), findsOneWidget);
    expect(find.text(AppStrings.driverName), findsWidgets);
    expect(find.text(AppStrings.vehicleNumber), findsOneWidget);
    expect(find.text(AppStrings.distanceSample), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Completed and Cancelled tabs show empty state', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.ridesTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.completed));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noRidesYet), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancelledTab));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noRidesYet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ongoing booking opens ride detail', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.ridesTitle));
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('${AppStrings.bookingIdPrefix}${AppStrings.bookingIdValue}'),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.bookingDetail), findsOneWidget);
    expect(find.text(AppStrings.driverOnTheWay), findsNothing);
    expect(find.text(AppStrings.onTheWay), findsWidgets);
    expect(find.text(AppStrings.vehicleNumber), findsOneWidget);
    expect(find.text(AppStrings.driverName), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

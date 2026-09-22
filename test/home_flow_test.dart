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

  testWidgets('Home booking flow reaches ride completed and review', (
    tester,
  ) async {
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

    expect(find.text(AppStrings.searchRide), findsOneWidget);
    expect(find.text(AppStrings.pickupDefaultTitle), findsWidgets);
    expect(find.text(AppStrings.threeWheeler), findsOneWidget);

    await tester.tap(find.text(AppStrings.searchRide));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.reviewBooking), findsOneWidget);
    expect(find.text(AppStrings.vehicleToto), findsOneWidget);
    expect(find.text(AppStrings.vehicleAuto), findsOneWidget);

    await tester.tap(find.text(AppStrings.reviewBooking));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.bookingOverview), findsOneWidget);
    expect(find.text(AppStrings.confirmBooking), findsOneWidget);

    await tester.tap(find.text(AppStrings.confirmBooking));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(AppStrings.searchingDriver), findsOneWidget);
    expect(find.text(AppStrings.findingDriver), findsOneWidget);

    await tester.tap(find.text(AppStrings.findingDriver));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.bookingDetail), findsOneWidget);
    expect(find.text(AppStrings.driverOnTheWay), findsOneWidget);
    expect(find.text(AppStrings.cancelRide), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.chat_bubble_outline_rounded));
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.typeHere), findsOneWidget);
    expect(find.text(AppStrings.newMessage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.driverOnTheWay));
    await tester.tap(find.text(AppStrings.driverOnTheWay));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.rideCompletedTitle), findsOneWidget);
    expect(find.text(AppStrings.choosePaymentMethod), findsOneWidget);

    await tester.tap(find.text(AppStrings.choosePaymentMethod));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.rateAndReview), findsOneWidget);
    expect(find.text(AppStrings.submit), findsOneWidget);

    await tester.tap(find.text(AppStrings.submit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.searchRide), findsOneWidget);
  });

  testWidgets('Phone layout can open coupon and report sheets', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    expect(find.text(AppStrings.searchRide), findsOneWidget);

    await tester.tap(find.text(AppStrings.searchRide));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.reviewBooking));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.applyCouponCode));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.availableCoupons), findsOneWidget);
    expect(find.text(AppStrings.enterCouponCode), findsOneWidget);
    expect(find.text(AppStrings.couponFirst50), findsWidgets);
    expect(find.text(AppStrings.validOnAllRides), findsWidgets);
    expect(find.text(AppStrings.apply), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancel ride opens reason sheet and can submit', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    await tester.tap(find.text(AppStrings.searchRide));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.reviewBooking));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.confirmBooking));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(AppStrings.findingDriver));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.cancelRide));
    await tester.tap(find.text(AppStrings.cancelRide));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.driverTakingTooLong), findsOneWidget);
    expect(find.text(AppStrings.changeInMyPlans), findsOneWidget);
    expect(find.text(AppStrings.fareTooHigh), findsOneWidget);
    expect(find.text(AppStrings.safetyConcerns), findsOneWidget);
    expect(find.text(AppStrings.otherReason), findsOneWidget);
    expect(find.text(AppStrings.submit), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.changeInMyPlans));
    await tester.pump();
    await tester.tap(find.text(AppStrings.submit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.searchRide), findsOneWidget);
  });
}

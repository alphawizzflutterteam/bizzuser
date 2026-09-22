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

  testWidgets('Profile tab matches account menu layout', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.profileUserName), findsOneWidget);
    expect(find.text(AppStrings.profileUserPhone), findsOneWidget);
    expect(find.text(AppStrings.profileUserEmail), findsOneWidget);
    expect(find.text(AppStrings.personalInformation), findsOneWidget);
    expect(find.text(AppStrings.savedAddresses), findsNothing);
    expect(find.text(AppStrings.wallet), findsOneWidget);
    expect(find.text(AppStrings.bankDetail), findsNothing);
    expect(find.text(AppStrings.rideHistory), findsOneWidget);
    expect(find.text(AppStrings.helpAndSupport), findsOneWidget);
    expect(find.text(AppStrings.privacyPolicy), findsOneWidget);
    expect(find.text(AppStrings.termsAndConditions), findsOneWidget);
    expect(find.text(AppStrings.faqs), findsOneWidget);

    await tester.ensureVisible(find.text(AppStrings.logout));
    expect(find.text(AppStrings.logoutHint), findsOneWidget);
    await tester.ensureVisible(find.text(AppStrings.deleteAccount));
    expect(find.text(AppStrings.deletePermanently), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Personal information opens edit profile screen', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.personalInformation));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.updateProfile), findsOneWidget);
    expect(find.text(AppStrings.emailOptional), findsOneWidget);
    expect(find.text(AppStrings.referralCodeOptional), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text(AppStrings.fieldPlaceholder), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.camera), findsOneWidget);
    expect(find.text(AppStrings.gallery), findsOneWidget);

    Navigator.of(tester.element(find.text(AppStrings.camera))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.personalInformation), findsOneWidget);
  });

  testWidgets('Ride history opens bookings from profile', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.rideHistory));
    await tester.tap(find.text(AppStrings.rideHistory));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.ongoing), findsOneWidget);
    expect(find.text(AppStrings.completed), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.personalInformation), findsOneWidget);
  });

  testWidgets('Home pickup opens address picker form', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.pickupLocation));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.pickupLocation), findsWidgets);
    expect(find.text(AppStrings.confirmLocation), findsOneWidget);
    expect(find.text(AppStrings.addressLine), findsOneWidget);
    expect(find.text(AppStrings.savedAddresses), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wallet opens balance and history screen', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.wallet));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.currentBalance), findsOneWidget);
    expect(find.text(AppStrings.walletBalanceValue), findsOneWidget);
    expect(find.text(AppStrings.addAmount), findsOneWidget);
    expect(find.text(AppStrings.walletHistory), findsOneWidget);
    expect(find.text(AppStrings.addedMoney), findsWidgets);
    expect(find.text(AppStrings.walletPayment), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.credit));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.walletPayment), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.personalInformation), findsOneWidget);
  });

  testWidgets('Bank details is hidden on profile', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.bankDetail), findsNothing);
    expect(find.text(AppStrings.bankDetails), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help support shows ticket and can add a new one', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.helpAndSupport));
    await tester.tap(find.text(AppStrings.helpAndSupport));
    await tester.pumpAndSettle();

    expect(
      find.text('${AppStrings.ticketIdPrefix}${AppStrings.ticketIdValue}'),
      findsOneWidget,
    );
    expect(find.text(AppStrings.lostAndFoundRequest), findsOneWidget);
    expect(find.text(AppStrings.pending), findsOneWidget);
    expect(find.text(AppStrings.chat), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.addSupportTicket), findsOneWidget);
    expect(find.text(AppStrings.issueCategory), findsOneWidget);
    expect(find.text(AppStrings.subject), findsOneWidget);
    expect(find.text(AppStrings.description), findsOneWidget);
    expect(find.text(AppStrings.imageUpload), findsOneWidget);
    expect(find.text(AppStrings.raiseSupportTicket), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Privacy, terms and FAQs match legal screens', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.privacyPolicy));
    await tester.tap(find.text(AppStrings.privacyPolicy));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.updatedOn), findsOneWidget);
    expect(find.text(AppStrings.dataCollection), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.termsAndConditions));
    await tester.tap(find.text(AppStrings.termsAndConditions));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.legalIntro), findsOneWidget);
    expect(find.text(AppStrings.dataUsage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.faqs));
    await tester.tap(find.text(AppStrings.faqs));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.faqItemTitle), findsWidgets);
    expect(find.text(AppStrings.faqItemAnswer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Logout from profile returns to login', (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.text(AppStrings.profileTitle));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.logout));
    await tester.tap(find.text(AppStrings.logout));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.logoutConfirm), findsOneWidget);
    await tester.tap(find.text(AppStrings.confirm));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.getOtp), findsOneWidget);
  });
}

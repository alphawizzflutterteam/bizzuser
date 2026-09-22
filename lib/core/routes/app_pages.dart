import 'package:get/get.dart';

import '../constants/app_strings.dart';
import '../../modules/booking/bindings/ride_chat_binding.dart';
import '../../modules/booking/controllers/searching_driver_controller.dart';
import '../../modules/booking/views/booking_detail_view.dart';
import '../../modules/booking/views/booking_overview_view.dart';
import '../../modules/booking/views/chat_view.dart';
import '../../modules/booking/views/ride_completed_view.dart';
import '../../modules/booking/views/searching_driver_view.dart';
import '../../modules/booking/views/vehicle_select_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/legal/bindings/faqs_binding.dart';
import '../../modules/legal/controllers/legal_document_controller.dart';
import '../../modules/legal/views/faqs_view.dart';
import '../../modules/legal/views/legal_document_view.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/profile/bindings/address_form_binding.dart';
import '../../modules/profile/bindings/bank_details_binding.dart';
import '../../modules/profile/bindings/personal_information_binding.dart';
import '../../modules/profile/bindings/saved_addresses_binding.dart';
import '../../modules/profile/controllers/emergency_contacts_controller.dart';
import '../../modules/profile/views/address_form_view.dart';
import '../../modules/profile/views/bank_details_view.dart';
import '../../modules/profile/views/emergency_contacts_view.dart';
import '../../modules/profile/views/personal_information_view.dart';
import '../../modules/profile/views/saved_addresses_view.dart';
import '../../modules/register/bindings/register_binding.dart';
import '../../modules/register/views/register_view.dart';
import '../../modules/notifications/bindings/notifications_binding.dart';
import '../../modules/notifications/views/notifications_view.dart';
import '../../modules/sos/controllers/sos_controller.dart';
import '../../modules/sos/controllers/sos_history_controller.dart';
import '../../modules/sos/views/sos_history_view.dart';
import '../../modules/sos/views/sos_view.dart';
import '../../modules/signup/bindings/signup_binding.dart';
import '../../modules/signup/views/signup_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/verify_otp/bindings/verify_otp_binding.dart';
import '../../modules/verify_otp/views/verify_otp_view.dart';
import '../../modules/support/bindings/add_ticket_binding.dart';
import '../../modules/support/bindings/help_support_binding.dart';
import '../../modules/support/bindings/ticket_chat_binding.dart';
import '../../modules/support/views/add_ticket_view.dart';
import '../../modules/support/views/help_support_view.dart';
import '../../modules/support/views/ticket_chat_view.dart';
import '../../modules/referral/bindings/refer_earn_binding.dart';
import '../../modules/referral/views/refer_earn_view.dart';
import '../../modules/wallet/bindings/wallet_binding.dart';
import '../../modules/wallet/views/wallet_view.dart';
import '../../modules/rides/bindings/ride_detail_binding.dart';
import '../../modules/rides/controllers/rides_controller.dart';
import '../../modules/rides/views/ride_history_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.vehicleSelect,
      page: () => const VehicleSelectView(),
    ),
    GetPage(
      name: AppRoutes.bookingOverview,
      page: () => const BookingOverviewView(),
    ),
    GetPage(
      name: AppRoutes.searchingDriver,
      page: () => const SearchingDriverView(),
      binding: SearchingDriverBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingDetail,
      page: () => const BookingDetailView(),
      binding: RideDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.rideCompleted,
      page: () => const RideCompletedView(),
    ),
    GetPage(
      name: AppRoutes.rideChat,
      page: () => const RideChatView(),
      binding: RideChatBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.sosHelp,
      page: () => const SosView(),
      binding: SosBinding(),
    ),
    GetPage(
      name: AppRoutes.emergencyContacts,
      page: () => const EmergencyContactsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmergencyContactsController>(
          EmergencyContactsController.new,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.sosHistory,
      page: () => const SosHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SosHistoryController>(SosHistoryController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.personalInformation,
      page: () => const PersonalInformationView(),
      binding: PersonalInformationBinding(),
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.referAndEarn,
      page: () => const ReferEarnView(),
      binding: ReferEarnBinding(),
    ),
    GetPage(
      name: AppRoutes.bankDetails,
      page: () => const BankDetailsView(),
      binding: BankDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportView(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: AppRoutes.addSupportTicket,
      page: () => const AddTicketView(),
      binding: AddTicketBinding(),
    ),
    GetPage(
      name: AppRoutes.supportTicketChat,
      page: () => const TicketChatView(),
      binding: TicketChatBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const LegalDocumentView(),
      binding: BindingsBuilder(() {
        Get.put(
          LegalDocumentController(
            slug: 'privacy',
            fallbackTitle: AppStrings.privacyPolicy,
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const LegalDocumentView(),
      binding: BindingsBuilder(() {
        Get.put(
          LegalDocumentController(
            slug: 'terms',
            fallbackTitle: AppStrings.termsAndConditions,
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.faqs,
      page: () => const FaqsView(),
      binding: FaqsBinding(),
    ),
    GetPage(
      name: AppRoutes.rideHistory,
      page: () => const RideHistoryView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RidesController>()) {
          Get.lazyPut<RidesController>(RidesController.new, fenix: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.savedAddresses,
      page: () => const SavedAddressesView(),
      binding: SavedAddressesBinding(),
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: () => const AddressFormView(),
      binding: AddressFormBinding(),
    ),
  ];
}

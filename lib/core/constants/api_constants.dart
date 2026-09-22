class ApiConstants {
  ApiConstants._();

  // static const String baseUrl = 'https://bizzcab.developmentalphawizz.com/api';
  static const String baseUrl = 'http://192.168.1.229:5001/api';
  static const String socketUrl = 'http://192.168.1.229:5001';
  // static const String socketUrl = 'https://bizzcab.developmentalphawizz.com';
  static const int timeoutSeconds = 30;

  static const String sendOtp = '/user/auth/send-otp';
  static const String resendOtp = '/user/auth/resend-otp';
  static const String verifyOtp = '/user/auth/verify-otp';
  static const String registerSendOtp = '/user/auth/register/send-otp';
  static const String registerResendOtp = '/user/auth/register/resend-otp';
  static const String registerVerifyOtp = '/user/auth/register/verify-otp';
  static const String register = '/user/auth/register';
  static const String logout = '/user/auth/logout';
  static const String deleteAccount = '/user/account';
  static const String profile = '/user/profile';
  static const String profilePhoneSendOtp = '/user/profile/phone/send-otp';
  static const String profilePhoneConfirm = '/user/profile/phone/confirm';

  static const String notifications = '/user/notifications';
  static String notificationRead(String id) => '/user/notifications/$id/read';
  static const String sos = '/user/sos';
  static const String sosActive = '/user/sos/active';
  static String sosCancel(String id) => '/user/sos/$id/cancel';
  static const String reports = '/user/reports';
  static const String supportFaq = '/user/support/faq';
  static const String supportCategories = '/user/support/categories';
  static const String supportTickets = '/user/support/tickets';
  static const String referral = '/user/referral';
  static const String referralHistory = '/user/referral/history';
  static const String wallet = '/user/wallet';
  static const String walletAddMoney = '/user/wallet/add-money';
  static const String walletVerify = '/user/wallet/verify';
  static const String walletTransactions = '/user/wallet/transactions';
  static String supportTicket(String id) => '/user/support/tickets/$id';
  static String supportTicketMessages(String id) =>
      '/user/support/tickets/$id/messages';
  static const String appConfig = '/public/app-config';
  static const String vehicleTypes = '/public/vehicle-types';
  static const String publicCities = '/public/cities';
  static const String cms = '/public/cms';
  static const String addresses = '/user/addresses';
  static String address(String id) => '/user/addresses/$id';
  static const String placesReverse = '/user/places/reverse';
  static const String placesSearch = '/user/places/search';
  static const String placesGeocode = '/user/places/geocode';
  static const String rides = '/user/rides';
  static String ride(String id) => '/user/rides/$id';
  static String rideMessages(String id) => '/user/rides/$id/messages';
  static const String rideOffers = '/user/rides/offers';
  static const String rideVehicles = '/user/rides/vehicles';
  static const String rideEstimate = '/user/rides/estimate';
  static const String rideApplyCoupon = '/user/rides/apply-coupon';
  static const String rideActive = '/user/rides/active';
  static const String rideCancelReasons = '/user/rides/cancel-reasons';
  static const String rideRecentDestinations =
      '/user/rides/recent-destinations';
  static String rideCancel(String id) => '/user/rides/$id/cancel';
  static String ridePay(String id) => '/user/rides/$id/pay';
  static String rideVerifyPayment(String id) =>
      '/user/rides/$id/verify-payment';
  static String rideShare(String token) => '/public/rides/share/$token';
  static const String ratings = '/user/ratings';
  static String cmsPage(String slug) => '/public/cms/$slug';

  static const String headerAccept = 'Accept';
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String jsonContentType = 'application/json';
}

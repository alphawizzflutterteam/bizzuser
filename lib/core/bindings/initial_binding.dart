import 'package:get/get.dart';

import '../../data/repositories/address_repository.dart';
import '../../data/repositories/app_config_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cms_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/places_repository.dart';
import '../../data/repositories/referral_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/repositories/safety_repository.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/fcm_service.dart';
import '../../data/services/places_service.dart';
import '../../data/services/push_notification_service.dart';
import '../../data/services/ride_socket_service.dart';
import '../../data/services/sos_service.dart';
import '../../data/services/storage_service.dart';
import '../theme/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<PlacesService>(PlacesService(), permanent: true);
    Get.put<AppConfigRepository>(
      AppConfigRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepository(Get.find<ApiService>(), Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<ProfileRepository>(
      ProfileRepository(Get.find<ApiService>(), Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<NotificationRepository>(
      NotificationRepository(Get.find<ApiService>()),
      permanent: true,
    );
    if (!Get.isRegistered<FcmService>()) {
      Get.put<FcmService>(FcmService(), permanent: true);
    }
    if (!Get.isRegistered<PushNotificationService>()) {
      Get.put<PushNotificationService>(
        PushNotificationService(),
        permanent: true,
      );
    }
    Get.put<SafetyRepository>(
      SafetyRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<SupportRepository>(
      SupportRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<CmsRepository>(
      CmsRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<WalletRepository>(
      WalletRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<VehicleRepository>(
      VehicleRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<AddressRepository>(
      AddressRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<ReferralRepository>(
      ReferralRepository(
        Get.find<ApiService>(),
        profileRepository: Get.find<ProfileRepository>(),
        appConfigRepository: Get.find<AppConfigRepository>(),
      ),
      permanent: true,
    );
    Get.put<RideRepository>(
      RideRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<PlacesRepository>(
      PlacesRepository(Get.find<ApiService>()),
      permanent: true,
    );
    Get.put<RideSocketService>(RideSocketService(), permanent: true);
    Get.put<SosService>(SosService(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}

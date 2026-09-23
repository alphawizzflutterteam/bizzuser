import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_utils.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../repositories/auth_repository.dart';
import 'sos_service.dart';

/// A signed-in request came back 401 (token expired, revoked, or from another
/// server): drop the session once and send the rider to login instead of
/// leaving every screen failing.
class SessionExpiry {
  SessionExpiry._();

  static bool _handling = false;

  static Future<void> handle() async {
    if (_handling) return;
    _handling = true;
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().clearSession();
      }
      SosService.clearActive();
      Get.offAllNamed(AppRoutes.login);
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }
      AppUtils.showError(AppStrings.unauthorized);
    } finally {
      _handling = false;
    }
  }
}

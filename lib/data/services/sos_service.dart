import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/run_api.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../modules/sos/widgets/sos_confirm_sheet.dart';
import '../models/sos_alert.dart';
import '../repositories/app_config_repository.dart';
import '../repositories/places_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/safety_repository.dart';
import 'storage_service.dart';

class SosService extends GetxService {
  SosService();

  final activeSos = Rxn<SosAlert>();
  final isRaising = false.obs;
  final isCancelling = false.obs;

  bool get hasActiveSos => activeSos.value?.isOpen == true;

  static Future<void> raiseOrConfirm({
    String? rideId,
    bool requireRideId = false,
  }) {
    if (Get.isRegistered<SosService>()) {
      return Get.find<SosService>().raiseFromUi(
        rideId: rideId,
        requireRideId: requireRideId,
      );
    }
    return SosConfirmSheet.show();
  }

  static void refreshIfLoggedIn() {
    if (!Get.isRegistered<SosService>()) return;
    Get.find<SosService>().refreshActive(silent: true);
  }

  static void clearActive() {
    if (!Get.isRegistered<SosService>()) return;
    Get.find<SosService>().activeSos.value = null;
  }

  Future<SosService> init() async {
    await refreshActive(silent: true);
    return this;
  }

  Future<void> refreshActive({bool silent = false}) async {
    if (!Get.isRegistered<SafetyRepository>()) return;
    if (!Get.isRegistered<StorageService>() ||
        !Get.find<StorageService>().hasSession) {
      activeSos.value = null;
      return;
    }
    try {
      activeSos.value = await Get.find<SafetyRepository>().fetchActive();
    } on ApiException catch (error) {
      if (!silent) AppUtils.showError(error.message);
    } catch (_) {
      if (!silent) AppUtils.showError(AppStrings.unableToReachServer);
    }
  }

  Future<void> raiseFromUi({String? rideId, bool requireRideId = false}) async {
    if (hasActiveSos) {
      openActive();
      return;
    }
    if (isRaising.value) return;
    final confirmed = await SosConfirmSheet.show();
    if (confirmed != true) return;

    if (!await _ensureEmergencyContact()) return;
    final coords = await _requireLocation();
    if (coords == null) return;

    var tripId = rideId?.trim() ?? '';
    if (requireRideId && tripId.isEmpty) {
      tripId = _liveRideId() ?? '';
    } else if (!requireRideId && tripId.isEmpty) {
      tripId = '';
    } else if (tripId.isEmpty) {
      tripId = _liveRideId() ?? '';
    }

    isRaising.value = true;
    try {
      final alert = await runApi(
        () => Get.find<SafetyRepository>().raiseSos(
          rideId: requireRideId
              ? (tripId.isEmpty ? _liveRideId() : tripId)
              : (tripId.isEmpty ? null : tripId),
          lat: coords.$1,
          lng: coords.$2,
          location: coords.$3,
        ),
      );
      if (alert == null) return;
      activeSos.value = alert;
      openActive();
    } finally {
      isRaising.value = false;
    }
  }

  Future<void> cancelActive() async {
    final alert = activeSos.value;
    if (alert == null || !alert.isOpen || isCancelling.value) return;
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.falseAlarm,
      message: AppStrings.cancelSosConfirm,
      confirmText: AppStrings.confirm,
    );
    if (confirmed != true) return;
    isCancelling.value = true;
    try {
      final message = await runApi(
        () => Get.find<SafetyRepository>().cancelSos(
          alert.id,
          reason: AppStrings.falseAlarmReason,
        ),
      );
      if (message == null) return;
      activeSos.value = null;
      AppUtils.showSuccess(message);
      if (Get.currentRoute == AppRoutes.sosHelp) {
        Get.back();
      }
    } finally {
      isCancelling.value = false;
    }
  }

  void openActive() {
    if (Get.currentRoute == AppRoutes.sosHelp) return;
    Get.toNamed(AppRoutes.sosHelp);
  }

  Future<void> callNumber(String number) async {
    final value = number.trim();
    if (value.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: value);
    final launched = await launchUrl(uri);
    if (!launched) {
      AppUtils.showInfo('${AppStrings.callingEmergency} $value');
    }
  }

  Future<void> shareActive() async {
    final alert = activeSos.value;
    if (alert == null) return;
    try {
      await SharePlus.instance.share(ShareParams(text: alert.shareText));
    } catch (_) {
      AppUtils.showInfo(alert.shareText);
    }
  }

  Future<void> textContact(SosNotifiedContact contact) async {
    final alert = activeSos.value;
    if (alert == null || contact.phone.trim().isEmpty) return;
    final uri = Uri(
      scheme: 'sms',
      path: contact.phone.trim(),
      queryParameters: {'body': alert.shareText},
    );
    final launched = await launchUrl(uri);
    if (!launched) AppUtils.showInfo(alert.shareText);
  }

  List<String> dialNumbers() {
    final fromAlert = activeSos.value?.sosNumbers ?? const <String>[];
    if (fromAlert.isNotEmpty) return fromAlert;
    if (Get.isRegistered<AppConfigRepository>()) {
      return Get.find<AppConfigRepository>().cached?.sosNumbers ?? const [];
    }
    return const [];
  }

  Future<bool> _ensureEmergencyContact() async {
    var hasContact = false;
    if (Get.isRegistered<ProfileController>()) {
      hasContact = Get.find<ProfileController>().user.value.hasEmergencyContact;
    }
    if (!hasContact && Get.isRegistered<ProfileRepository>()) {
      try {
        final result = await Get.find<ProfileRepository>().getProfile();
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().applyUser(result.user);
        }
        hasContact = result.user.hasEmergencyContact;
      } catch (_) {}
    }
    if (hasContact) return true;
    AppUtils.showError(AppStrings.needEmergencyContact);
    Get.toNamed(AppRoutes.emergencyContacts);
    return false;
  }

  Future<(double lat, double lng, String location)> currentLocation() async {
    try {
      if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever &&
            await Geolocator.isLocationServiceEnabled()) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 12),
            ),
          );
          if (position.latitude != 0 || position.longitude != 0) {
            return (
              position.latitude,
              position.longitude,
              await _addressFor(position.latitude, position.longitude),
            );
          }
        }
      }
    } catch (_) {}
    final alert = activeSos.value;
    if (alert != null && (alert.lat != 0 || alert.lng != 0)) {
      final address = alert.location.isNotEmpty
          ? alert.location
          : await _addressFor(alert.lat, alert.lng);
      return (alert.lat, alert.lng, address);
    }
    if (Get.isRegistered<HomeController>()) {
      final pickup = Get.find<HomeController>().pickup.value;
      if (pickup.hasCoordinates) {
        return (pickup.lat, pickup.lng, pickup.routeLine);
      }
    }
    return (0.0, 0.0, '');
  }

  Future<String> _addressFor(double lat, double lng) async {
    if (Get.isRegistered<PlacesRepository>()) {
      try {
        final details = await Get.find<PlacesRepository>().reverse(
          lat: lat,
          lng: lng,
        );
        final address = details?.address.trim() ?? '';
        if (address.isNotEmpty) return address;
      } catch (_) {}
    }
    if (Get.isRegistered<HomeController>()) {
      final pickup = Get.find<HomeController>().pickup.value;
      if (pickup.routeLine.isNotEmpty) return pickup.routeLine;
    }
    return activeSos.value?.location ?? '';
  }

  Future<(double, double, String)?> _requireLocation() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      AppUtils.showError(AppStrings.locationRequired);
      return null;
    }
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        AppUtils.showError(AppStrings.locationRequired);
        await Geolocator.openLocationSettings();
        return null;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        AppUtils.showError(AppStrings.locationRequired);
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        AppUtils.showError(AppStrings.locationDeniedForever);
        await Geolocator.openAppSettings();
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (position.latitude == 0 && position.longitude == 0) {
        AppUtils.showError(AppStrings.locationRequired);
        return null;
      }
      var address = '';
      if (Get.isRegistered<HomeController>()) {
        final pickup = Get.find<HomeController>().pickup.value;
        if (pickup.hasCoordinates) address = pickup.routeLine;
      }
      return (position.latitude, position.longitude, address);
    } catch (_) {
      AppUtils.showError(AppStrings.locationRequired);
      return null;
    }
  }

  String? _liveRideId() {
    if (!Get.isRegistered<HomeController>()) return null;
    final id = Get.find<HomeController>().liveRide?.id.trim() ?? '';
    return id.isEmpty ? null : id;
  }
}

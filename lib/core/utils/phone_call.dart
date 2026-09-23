import 'package:url_launcher/url_launcher.dart';

import '../constants/app_strings.dart';
import 'app_utils.dart';

/// Opens the system dialer for [phone]. Never dials a placeholder: an empty
/// number shows a toast instead.
Future<void> launchDialer(String phone) async {
  final value = phone.replaceAll(RegExp(r'\s+'), '').trim();
  if (value.isEmpty) {
    AppUtils.showInfo(AppStrings.driverPhoneUnavailable);
    return;
  }
  try {
    final launched = await launchUrl(Uri(scheme: 'tel', path: value));
    if (!launched) AppUtils.showError(AppStrings.unableToStartCall);
  } catch (_) {
    AppUtils.showError(AppStrings.unableToStartCall);
  }
}

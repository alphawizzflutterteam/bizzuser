import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../models/app_notification.dart';
import '../models/safety_models.dart';

class SafetyCatalog {
  SafetyCatalog._();

  static const List<AppNotification> notifications = [
    AppNotification(
      title: AppStrings.rideConfirmed,
      body: AppStrings.rideConfirmedBody,
      time: AppStrings.twoMinsAgo,
    ),
    AppNotification(
      title: AppStrings.driverAssigned,
      body: AppStrings.driverAssignedBody,
      time: AppStrings.twoMinsAgo,
    ),
    AppNotification(
      title: AppStrings.paymentSuccessful,
      body: AppStrings.paymentSuccessfulBody,
      time: AppStrings.twoMinsAgo,
    ),
  ];

  static const List<SafetyAction> actions = [
    SafetyAction(
      title: AppStrings.emergencyContact,
      subtitle: AppStrings.emergencyContactHint,
      icon: Icons.call_rounded,
      background: AppColors.sosEmergencyBg,
      iconColor: AppColors.sosButton,
    ),
    SafetyAction(
      title: AppStrings.shareLiveRide,
      subtitle: AppStrings.shareLiveRideHint,
      icon: Icons.location_on_rounded,
      background: AppColors.sosShareBg,
      iconColor: AppColors.sosShareIcon,
    ),
    SafetyAction(
      title: AppStrings.reportSafetyIssue,
      subtitle: AppStrings.reportSafetyIssueHint,
      icon: Icons.error_outline_rounded,
      background: AppColors.sosReportBg,
      iconColor: AppColors.sosReportIcon,
    ),
  ];

  static const List<SafetyReason> reasons = [
    SafetyReason(
      id: 'harassment',
      title: AppStrings.harassment,
      icon: Icons.access_time_rounded,
    ),
    SafetyReason(
      id: 'suspicious',
      title: AppStrings.suspiciousActivity,
      icon: Icons.location_on_outlined,
    ),
    SafetyReason(
      id: 'unsafe',
      title: AppStrings.unsafeDriving,
      icon: Icons.currency_rupee,
    ),
    SafetyReason(
      id: 'safety',
      title: AppStrings.safetyConcerns,
      icon: Icons.location_on_outlined,
    ),
    SafetyReason(
      id: 'other',
      title: AppStrings.otherReason,
      icon: Icons.more_horiz_rounded,
    ),
  ];
}

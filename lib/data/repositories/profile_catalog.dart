import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../models/profile_menu_item.dart';

class ProfileCatalog {
  ProfileCatalog._();

  static const String name = AppStrings.profileUserName;
  static const String phone = AppStrings.profileUserPhone;
  static const String email = AppStrings.profileUserEmail;

  static const List<ProfileMenuItem> accountItems = [
    ProfileMenuItem(
      id: 'personal',
      title: AppStrings.personalInformation,
      subtitle: AppStrings.personalInformationHint,
      icon: Icons.person_outline_rounded,
      background: AppColors.profilePurpleBg,
      iconColor: AppColors.profilePurpleIcon,
    ),
    ProfileMenuItem(
      id: 'emergency',
      title: AppStrings.emergencyContactsTitle,
      subtitle: AppStrings.emergencyContactsHint,
      icon: Icons.contact_emergency_outlined,
      background: AppColors.profilePinkBg,
      iconColor: AppColors.profilePinkIcon,
    ),
    ProfileMenuItem(
      id: 'wallet',
      title: AppStrings.wallet,
      subtitle: AppStrings.walletHint,
      icon: Icons.account_balance_wallet_outlined,
      background: AppColors.profileBlueBg,
      iconColor: AppColors.profileBlueIcon,
    ),
    ProfileMenuItem(
      id: 'referral',
      title: AppStrings.referAndEarn,
      subtitle: AppStrings.referAndEarnHint,
      icon: Icons.card_giftcard_outlined,
      background: AppColors.profileGreenBg,
      iconColor: AppColors.profileGreenIcon,
    ),
    ProfileMenuItem(
      id: 'history',
      title: AppStrings.rideHistory,
      subtitle: AppStrings.findAnswersHint,
      icon: Icons.assignment_outlined,
      background: AppColors.profileOrangeBg,
      iconColor: AppColors.profileOrangeIcon,
    ),
    ProfileMenuItem(
      id: 'sosHistory',
      title: AppStrings.sosHistory,
      subtitle: AppStrings.sosHistoryHint,
      icon: Icons.sos_rounded,
      background: AppColors.sosEmergencyBg,
      iconColor: AppColors.sosButton,
    ),
    ProfileMenuItem(
      id: 'help',
      title: AppStrings.helpAndSupport,
      subtitle: AppStrings.findAnswersHint,
      icon: Icons.help_outline_rounded,
      background: AppColors.profilePinkBg,
      iconColor: AppColors.profilePinkIcon,
    ),
  ];

  static const List<ProfileMenuItem> legalItems = [
    ProfileMenuItem(
      id: 'privacy',
      title: AppStrings.privacyPolicy,
      subtitle: AppStrings.privacyPolicyHint,
      icon: Icons.verified_user_outlined,
      background: AppColors.profilePurpleBg,
      iconColor: AppColors.profilePurpleIcon,
    ),
    ProfileMenuItem(
      id: 'terms',
      title: AppStrings.termsAndConditions,
      subtitle: AppStrings.termsAndConditionsHint,
      icon: Icons.description_outlined,
      background: AppColors.profileGreenBg,
      iconColor: AppColors.profileGreenIcon,
    ),
    ProfileMenuItem(
      id: 'faqs',
      title: AppStrings.faqs,
      subtitle: AppStrings.findAnswersHint,
      icon: Icons.help_outline_rounded,
      background: AppColors.profileBlueBg,
      iconColor: AppColors.profileBlueIcon,
    ),
  ];
}

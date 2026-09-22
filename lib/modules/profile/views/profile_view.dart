import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../data/models/profile_menu_item.dart';
import '../../../data/repositories/profile_catalog.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_avatar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.paddingOf(context).bottom +
        AppDimensions.homeNavBottomGap +
        AppDimensions.homeNavHeight +
        AppDimensions.paddingMedium;

    return CreamWashBackground(
      child: SafeArea(
        bottom: false,
        child: Obx(
          () => AppPageLoadingGate(
            loading: controller.isPageLoading.value,
            child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset),
          child: Column(
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 28),
              _MenuCard(
                items: ProfileCatalog.accountItems,
                onTap: controller.openItem,
              ),
              const SizedBox(height: 14),
              _MenuCard(
                items: ProfileCatalog.legalItems,
                onTap: controller.openItem,
              ),
              const SizedBox(height: 14),
              _DangerCard(
                icon: Icons.logout_rounded,
                title: AppStrings.logout,
                subtitle: AppStrings.logoutHint,
                onTap: controller.logout,
              ),
              const SizedBox(height: 10),
              _DangerCard(
                icon: Icons.delete_outline_rounded,
                title: AppStrings.deleteAccount,
                subtitle: AppStrings.deletePermanently,
                onTap: controller.deleteAccount,
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends GetView<ProfileController> {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => ProfileAvatar(
            imagePath: controller.avatarPath,
            onEdit: controller.showPhotoPicker,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: controller.displayName,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlack,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                _ContactLine(
                  icon: Icons.phone_outlined,
                  text: controller.displayPhone,
                ),
                const SizedBox(height: 6),
                _ContactLine(
                  icon: Icons.mail_outline_rounded,
                  text: controller.displayEmail,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.tabInactive),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(
            text: text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.tabInactive,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items, required this.onTap});

  final List<ProfileMenuItem> items;
  final ValueChanged<ProfileMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _MenuRow(item: items[i], onTap: () => onTap(items[i])),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final ProfileMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: item.title,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlack,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: item.subtitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.tabInactive,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.navInactive,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.logoutFill,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.logoutFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.logoutBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.logoutIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.logoutText, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: title,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.logoutText,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        text: subtitle,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.logoutSubtitle,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.navInactive,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

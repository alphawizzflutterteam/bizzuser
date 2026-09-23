import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../data/models/referral_info.dart';
import '../controllers/refer_earn_controller.dart';

class ReferEarnView extends GetView<ReferEarnController> {
  const ReferEarnView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: AppStrings.referAndEarn),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isPageLoading.value) {
                  return const AppPageLoader();
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: const [
                    _RewardCard(),
                    SizedBox(height: 14),
                    _CodeCard(),
                    SizedBox(height: 18),
                    _PendingSection(),
                    SizedBox(height: 18),
                    _ReferralList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends GetView<ReferEarnController> {
  const _RewardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.brandBlack,
            ),
          ),
          const SizedBox(height: 12),
          const AppText(
            text: AppStrings.referAndEarn,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.brandBlack,
          ),
          const SizedBox(height: 8),
          Obx(
            () => AppText(
              text: controller.bodyCopy,
              fontSize: 14,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              height: 1.35,
            ),
          ),
          Obx(() {
            if (controller.rewardAmount <= 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AppText(
                text: controller.rewardLabel,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.brandBlack,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CodeCard extends GetView<ReferEarnController> {
  const _CodeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: AppStrings.yourReferralCode,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.tabInactive,
          ),
          const SizedBox(height: 8),
          Obx(
            () => AppText(
              text: controller.code.isEmpty
                  ? AppStrings.fieldPlaceholder
                  : controller.code,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  title: AppStrings.copyCode,
                  outlined: true,
                  borderColor: AppColors.fieldBorder,
                  textColor: AppColors.brandBlack,
                  backgroundColor: AppColors.white,
                  borderRadius: 28,
                  height: 48,
                  onPressed: controller.copyCode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  title: AppStrings.shareInvite,
                  backgroundColor: AppColors.brandBlack,
                  textColor: AppColors.white,
                  borderRadius: 28,
                  height: 48,
                  onPressed: controller.shareInvite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingSection extends GetView<ReferEarnController> {
  const _PendingSection();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _InviteSection(
        title: AppStrings.pendingRewards,
        emptyText: AppStrings.noPendingReferrals,
        invites: controller.info.value.pendingInvites,
        amountColor: AppColors.warning,
      ),
    );
  }
}

class _ReferralList extends GetView<ReferEarnController> {
  const _ReferralList();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _InviteSection(
        title: AppStrings.referralList,
        emptyText: AppStrings.noRewardedReferrals,
        invites: controller.info.value.rewardedInvites,
        amountColor: AppColors.walletCredit,
      ),
    );
  }
}

class _InviteSection extends StatelessWidget {
  const _InviteSection({
    required this.title,
    required this.emptyText,
    required this.invites,
    required this.amountColor,
  });

  final String title;
  final String emptyText;
  final List<ReferralInvite> invites;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.brandBlack,
        ),
        const SizedBox(height: 10),
        if (invites.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: AppText(
              text: emptyText,
              fontSize: 13,
              color: AppColors.tabInactive,
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final invite in invites)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: invite.name.trim().isEmpty
                              ? AppStrings.fieldPlaceholder
                              : invite.name,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                        ),
                        AppText(
                          text: invite.timelineLabel,
                          fontSize: 12,
                          color: AppColors.tabInactive,
                        ),
                      ],
                    ),
                  ),
                  if (invite.amount > 0)
                    invite.isRewarded
                        ? AppText(
                            text: '+${AppUtils.rupee(invite.amount)}',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          )
                        : AppText(
                            text:
                                '${AppStrings.earnLabel} ${AppUtils.rupee(invite.amount)}',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tabInactive,
                          ),
                ],
              ),
            ),
      ],
    );
  }
}

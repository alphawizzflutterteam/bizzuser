import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: AppStrings.wallet),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isPageLoading.value) {
                  return const AppPageLoader();
                }
                final items = controller.transactions;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const _WalletTop();
                    }
                    return _TxnRow(transaction: items[index - 1]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTop extends GetView<WalletController> {
  const _WalletTop();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BalanceCard(),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: AppText(
                text: AppStrings.walletHistory,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.brandBlack,
              ),
            ),
            const AppText(
              text: AppStrings.filter,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brandYellow,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.filter_alt_outlined,
              size: 16,
              color: AppColors.brandYellow,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(
          () => Row(
            children: [
              _FilterChip(
                label: AppStrings.all,
                selected: controller.filter.value == WalletFilter.all,
                color: AppColors.brandBlack,
                onTap: () => controller.selectFilter(WalletFilter.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: AppStrings.credit,
                selected: controller.filter.value == WalletFilter.credit,
                color: AppColors.walletCredit,
                onTap: () => controller.selectFilter(WalletFilter.credit),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: AppStrings.debit,
                selected: controller.filter.value == WalletFilter.debit,
                color: AppColors.brandBlack,
                onTap: () => controller.selectFilter(WalletFilter.debit),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BalanceCard extends GetView<WalletController> {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.profileHeader,
            AppColors.white,
            AppColors.white,
          ],
          stops: [0, 0.45, 1],
        ),
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
          const AppText(
            text: AppStrings.currentBalance,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.tabInactive,
          ),
          const SizedBox(height: 8),
          Obx(
            () {
              controller.balance.value;
              if (Get.isRegistered<ProfileController>()) {
                Get.find<ProfileController>().user.value;
              }
              return AppText(
                text: controller.balanceLabel,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.brandBlack,
              );
            },
          ),
          const SizedBox(height: 16),
          Obx(
            () => AppButton(
              title: AppStrings.addAmount,
              width: 168,
              height: 44,
              borderRadius: 24,
              backgroundColor: AppColors.brandBlack,
              textColor: AppColors.white,
              isLoading: controller.isAdding.value,
              onPressed: controller.addAmount,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAll = label == AppStrings.all;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected && isAll
              ? AppColors.walletChipSelected
              : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected && isAll
                ? AppColors.walletChipSelected
                : selected
                ? color
                : AppColors.fieldBorder,
          ),
        ),
        child: AppText(
          text: label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isCredit
        ? AppColors.walletCredit
        : AppColors.walletDebit;
    final bg = transaction.isCredit
        ? AppColors.walletCreditBg
        : AppColors.walletDebitBg;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(
              transaction.isCredit ? Icons.add : Icons.remove,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: transaction.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlack,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                AppText(
                  text: transaction.subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.tabInactive,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                AppText(
                  text: transaction.date,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.navInactive,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                text: transaction.amountLabel,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              const SizedBox(height: 4),
              AppText(
                text: transaction.balanceLabel,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.tabInactive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

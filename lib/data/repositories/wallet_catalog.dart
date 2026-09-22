import '../../core/constants/app_strings.dart';
import '../models/wallet_transaction.dart';

class WalletCatalog {
  WalletCatalog._();

  static const List<WalletTransaction> transactions = [
    WalletTransaction(
      title: AppStrings.addedMoney,
      subtitle: AppStrings.walletRecharge,
      date: AppStrings.walletCreditDate,
      amountLabel: AppStrings.walletCreditAmount,
      balanceLabel: AppStrings.walletCreditBalance,
      isCredit: true,
    ),
    WalletTransaction(
      title: AppStrings.walletPayment,
      subtitle: AppStrings.tripIdValue,
      date: AppStrings.walletDebitDate,
      amountLabel: AppStrings.walletDebitAmount,
      balanceLabel: AppStrings.walletDebitBalance,
      isCredit: false,
    ),
    WalletTransaction(
      title: AppStrings.addedMoney,
      subtitle: AppStrings.walletRecharge,
      date: AppStrings.walletCreditDate,
      amountLabel: AppStrings.walletCreditAmount,
      balanceLabel: AppStrings.walletCreditBalance,
      isCredit: true,
    ),
    WalletTransaction(
      title: AppStrings.addedMoney,
      subtitle: AppStrings.walletRecharge,
      date: AppStrings.walletCreditDate,
      amountLabel: AppStrings.walletCreditAmount,
      balanceLabel: AppStrings.walletCreditBalance,
      isCredit: true,
    ),
    WalletTransaction(
      title: AppStrings.walletPayment,
      subtitle: AppStrings.tripIdValue,
      date: AppStrings.walletDebitDate,
      amountLabel: AppStrings.walletDebitAmount,
      balanceLabel: AppStrings.walletDebitBalance,
      isCredit: false,
    ),
  ];
}

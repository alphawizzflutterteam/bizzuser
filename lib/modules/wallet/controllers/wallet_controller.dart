import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../../data/repositories/wallet_catalog.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/services/razorpay_checkout.dart';
import '../../profile/controllers/profile_controller.dart';
import '../widgets/add_amount_dialog.dart';

enum WalletFilter { all, credit, debit }

class WalletController extends GetxController with PageLoadingMixin {
  WalletController({RazorpayCheckout? checkout})
    : _checkout = checkout ?? RazorpayCheckout();

  final RazorpayCheckout _checkout;
  final filter = WalletFilter.all.obs;
  final balance = Rx<num>(1250);
  final isAdding = false.obs;
  final transactions = <WalletTransaction>[...WalletCatalog.transactions].obs;

  String get balanceLabel => AppUtils.groupedRupee(balance.value);

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<ProfileController>()) {
      balance.value = Get.find<ProfileController>().user.value.walletBalance;
    }
    if (!Get.isRegistered<WalletRepository>()) {
      stopPageLoading();
      return;
    }
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await runPageLoad(() async {
      await Future.wait([loadWallet(), loadTransactions()]);
    });
  }

  Future<void> loadWallet() async {
    if (!Get.isRegistered<WalletRepository>()) return;
    try {
      final wallet = await Get.find<WalletRepository>().fetchWallet();
      if (wallet.hasBalance) {
        _applyBalance(wallet.balance);
      }
    } catch (_) {}
  }

  Future<void> loadTransactions() async {
    if (!Get.isRegistered<WalletRepository>()) {
      transactions.assignAll(_catalogFor(filter.value));
      return;
    }
    try {
      final items = await Get.find<WalletRepository>().fetchTransactions(
        type: _queryType(filter.value),
      );
      transactions.assignAll(items);
    } catch (_) {}
  }

  void selectFilter(WalletFilter value) {
    filter.value = value;
    loadTransactions();
  }

  Future<void> addAmount() async {
    final amount = await AddAmountDialog.show();
    if (amount == null) return;

    if (!Get.isRegistered<WalletRepository>()) {
      AppUtils.showSuccess(AppStrings.moneyAdded);
      return;
    }

    final repo = Get.find<WalletRepository>();
    try {
      isAdding.value = true;
      final order = await runApi(() => repo.addMoney(amount));
      if (order == null) return;
      if (order.paymentId.isEmpty) {
        AppUtils.showError(AppStrings.unableToStartPayment);
        return;
      }

      var key = order.key.trim();
      if (key.isEmpty) {
        key = (order.checkoutOptions['key'] ?? '').toString().trim();
      }
      if (key.isEmpty) {
        key = (await repo.fetchRazorpayKey()).trim();
      }

      if (key.isNotEmpty) {
        await _payWithRazorpay(repo, order, amount, key);
      } else {
        await _confirmPayment(
          repo,
          paymentId: order.paymentId,
          razorpayOrderId: order.razorpayOrderId,
          razorpayPaymentId: order.razorpayPaymentId.isEmpty
              ? 'pay_dev'
              : order.razorpayPaymentId,
          razorpaySignature: order.razorpaySignature.isEmpty
              ? 'dev'
              : order.razorpaySignature,
        );
      }
    } on ApiException catch (error) {
      AppUtils.showError(error.message);
    } catch (_) {
      AppUtils.showError(AppStrings.paymentFailed);
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> _payWithRazorpay(
    WalletRepository repo,
    WalletOrder order,
    num rupees,
    String key,
  ) async {
    isAdding.value = false;
    final payment = await _checkout.open(_checkoutOptions(order, rupees, key));
    isAdding.value = true;
    if (payment.paymentId.isEmpty || payment.signature.isEmpty) {
      AppUtils.showError(AppStrings.paymentFailed);
      return;
    }
    await _confirmPayment(
      repo,
      paymentId: order.paymentId,
      razorpayOrderId: payment.orderId.isNotEmpty
          ? payment.orderId
          : order.razorpayOrderId,
      razorpayPaymentId: payment.paymentId,
      razorpaySignature: payment.signature,
    );
  }

  Future<void> _confirmPayment(
    WalletRepository repo, {
    required String paymentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final verified = await runApi(
      () => repo.verify(
        paymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      ),
    );
    if (verified == null) return;

    if (verified.hasBalance) {
      _applyBalance(verified.balance);
    } else {
      await loadWallet();
    }
    await loadTransactions();
    AppUtils.showSuccess(
      verified.message.isNotEmpty ? verified.message : AppStrings.moneyAdded,
    );
  }

  Map<String, dynamic> _checkoutOptions(
    WalletOrder order,
    num rupees,
    String key,
  ) {
    final user = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().user.value
        : null;
    final contact = user == null ? '' : PhoneUtils.localNumber(user.phone);
    final email = user?.email.trim() ?? '';
    final name = user?.name.trim() ?? '';
    final orderId = order.razorpayOrderId;
    final options = <String, dynamic>{
      ...order.checkoutOptions,
      'key': key,
      'amount': order.amountInPaise(rupees),
      'currency': 'INR',
      'name': AppStrings.appName,
      'description': AppStrings.walletRecharge,
      'prefill': {
        if (contact.length == 10) 'contact': contact,
        if (email.isNotEmpty) 'email': email,
        if (name.isNotEmpty) 'name': name,
      },
      'theme': {'color': '#111111'},
    };
    if (orderId.isNotEmpty && !orderId.startsWith('order_dev')) {
      options['order_id'] = orderId;
    } else {
      options.remove('order_id');
    }
    return options;
  }

  void _applyBalance(num value) {
    balance.value = value;
    if (!Get.isRegistered<ProfileController>()) return;
    final profile = Get.find<ProfileController>();
    profile.applyUser(profile.user.value.copyWith(walletBalance: value));
  }

  String? _queryType(WalletFilter value) {
    switch (value) {
      case WalletFilter.all:
        return null;
      case WalletFilter.credit:
        return 'credit';
      case WalletFilter.debit:
        return 'debit';
    }
  }

  List<WalletTransaction> _catalogFor(WalletFilter value) {
    final items = WalletCatalog.transactions;
    switch (value) {
      case WalletFilter.all:
        return items;
      case WalletFilter.credit:
        return items.where((item) => item.isCredit).toList();
      case WalletFilter.debit:
        return items.where((item) => !item.isCredit).toList();
    }
  }

  @override
  void onClose() {
    _checkout.dispose();
    super.onClose();
  }
}

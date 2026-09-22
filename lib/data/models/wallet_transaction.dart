import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/date_format_utils.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amountLabel,
    required this.balanceLabel,
    required this.isCredit,
    this.id = '',
    this.amount = 0,
    this.balanceAfter = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String date;
  final String amountLabel;
  final String balanceLabel;
  final bool isCredit;
  final num amount;
  final num balanceAfter;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString().toLowerCase() ?? '';
    final amount = ApiBody.asNum(json['amount']);
    final isCredit = type.isEmpty ? amount >= 0 : type != 'debit';
    final signedAmount = amount.abs();
    final rupee = AppUtils.rupee(signedAmount, decimals: true);
    final balanceAfter = ApiBody.asNum(json['balanceAfter'] ?? json['balance']);
    final title = json['title']?.toString().trim() ?? '';
    final subtitle = json['subtitle']?.toString().trim() ?? '';
    final note = json['note']?.toString().trim() ?? '';
    final reason = (json['reason'] ?? json['typeReason'] ?? '')
        .toString()
        .trim();
    final isReferral = reason.toLowerCase() == 'referral_reward' ||
        reason.toLowerCase().contains('referral');

    return WalletTransaction(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: title.isNotEmpty
          ? title
          : (isReferral
              ? AppStrings.referralReward
              : (isCredit ? AppStrings.addedMoney : AppStrings.walletPayment)),
      subtitle: subtitle.isNotEmpty
          ? subtitle
          : note.isNotEmpty
          ? note
          : (isReferral
              ? AppStrings.referralRewardHint
              : _reasonLabel(reason, isCredit: isCredit)),
      date: DateFormatUtils.walletDate(
        json['createdAt']?.toString(),
        fallback: isCredit
            ? AppStrings.walletCreditDate
            : AppStrings.walletDebitDate,
      ),
      amountLabel: isCredit ? '+ $rupee' : '- $rupee',
      balanceLabel: 'Balance: ${AppUtils.rupee(balanceAfter, decimals: true)}',
      isCredit: isCredit,
      amount: signedAmount,
      balanceAfter: balanceAfter,
    );
  }

  static String _reasonLabel(String reason, {required bool isCredit}) {
    if (reason.isEmpty) {
      return isCredit ? AppStrings.walletRecharge : AppStrings.walletPayment;
    }
    return reason
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class WalletInfo {
  const WalletInfo({
    required this.balance,
    this.message = '',
    this.hasBalance = false,
  });

  final num balance;
  final String message;
  final bool hasBalance;

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final nested = ApiBody.asMap(data['wallet']) ?? {};
    final user = ApiBody.asMap(data['user']) ?? {};
    final raw = data['walletBalance'] ??
        data['balance'] ??
        data['availableBalance'] ??
        nested['walletBalance'] ??
        nested['balance'] ??
        user['walletBalance'] ??
        json['walletBalance'] ??
        json['balance'];
    return WalletInfo(
      balance: ApiBody.asNum(raw),
      message: ApiBody.message(json, fallback: ''),
      hasBalance: raw != null,
    );
  }
}

class WalletOrder {
  const WalletOrder({
    required this.paymentId,
    required this.razorpayOrderId,
    this.key = '',
    this.amount = 0,
    this.razorpayPaymentId = '',
    this.razorpaySignature = '',
    this.checkoutOptions = const {},
    this.isMock = false,
    this.currency = 'INR',
  });

  final String paymentId;
  final String razorpayOrderId;
  final String key;
  final num amount;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final Map<String, dynamic> checkoutOptions;
  final bool isMock;
  final String currency;

  bool get hasRazorpayKey => key.trim().startsWith('rzp_');

  factory WalletOrder.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final nestedData = ApiBody.asMap(data['data']) ?? {};
    final paymentMap = ApiBody.asMap(data['payment']) ??
        ApiBody.asMap(json['payment']) ??
        ApiBody.asMap(nestedData['payment']) ??
        const <String, dynamic>{};
    final options = ApiBody.asMap(data['options']) ??
        ApiBody.asMap(data['checkout']) ??
        ApiBody.asMap(json['options']) ??
        const <String, dynamic>{};
    final razorpay = ApiBody.asMap(data['razorpay']) ??
        ApiBody.asMap(json['razorpay']) ??
        ApiBody.asMap(options) ??
        const <String, dynamic>{};
    final orderMap = ApiBody.asMap(data['order']) ??
        ApiBody.asMap(json['order']) ??
        const <String, dynamic>{};

    var paymentId = _first(
      [paymentMap, nestedData, data, json],
      const ['paymentId', 'payment_id', 'walletPaymentId'],
    );
    paymentId = paymentId.isNotEmpty
        ? paymentId
        : (_stringId(data['payment']) ??
              _stringId(json['payment']) ??
              _stringId(nestedData['payment']) ??
              '');
    if (paymentId.isEmpty) {
      paymentId = _first([paymentMap, nestedData, data], const ['_id', 'id']);
    }

    var orderId = _first(
      [options, razorpay, orderMap, paymentMap, nestedData, data, json],
      const [
        'razorpay_order_id',
        'razorpayOrderId',
        'order_id',
        'orderId',
      ],
    );
    if (orderId.isEmpty) {
      orderId = _stringId(data['order']) ??
          _stringId(json['order']) ??
          _stringId(data['razorpay']) ??
          '';
    }
    if (orderId.isEmpty) {
      orderId = _first([razorpay, orderMap], const ['id']);
    }
    if (orderId.isEmpty && paymentId.isNotEmpty) {
      orderId = 'order_dev_wallet_$paymentId';
    }

    var key = _first(
      [orderMap, options, razorpay, paymentMap, nestedData, data, json],
      const [
        'key',
        'keyId',
        'key_id',
        'razorpayKey',
        'razorpay_key',
        'razorpayKeyId',
        'razorpay_key_id',
        'publicKey',
        'publishableKey',
      ],
    );
    if (key.isEmpty) {
      key = _findPrefixed(json, 'rzp_');
    }

    final isMock = orderMap['mock'] == true || data['mock'] == true;

    return WalletOrder(
      paymentId: paymentId,
      razorpayOrderId: orderId,
      key: key,
      amount: ApiBody.asNum(
        paymentMap['amount'] ??
            razorpay['amount'] ??
            orderMap['amount'] ??
            options['amount'] ??
            data['amount'] ??
            json['amount'],
      ),
      razorpayPaymentId: _first(
        [options, razorpay, paymentMap, data, json],
        const ['razorpay_payment_id', 'razorpayPaymentId'],
      ),
      razorpaySignature: _first(
        [options, razorpay, paymentMap, data, json],
        const ['razorpay_signature', 'razorpaySignature', 'signature'],
      ),
      checkoutOptions: options,
      isMock: isMock,
      currency: (orderMap['currency'] ?? data['currency'] ?? 'INR')
          .toString()
          .trim(),
    );
  }

  int amountInPaise(num rupees) {
    final expected = (rupees * 100).round();
    final api = amount.round();
    if (api == expected) return api;
    if (api == rupees.round()) return expected;
    if (api > expected) return api;
    return expected;
  }

  static String _first(List<Map<String, dynamic>> sources, List<String> keys) {
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key]?.toString().trim() ?? '';
        if (value.isNotEmpty && value.toLowerCase() != 'null') {
          return value;
        }
      }
    }
    return '';
  }

  static String? _stringId(dynamic raw) {
    if (raw is String) {
      final value = raw.trim();
      return value.isEmpty ? null : value;
    }
    return null;
  }

  static String _findPrefixed(dynamic raw, String prefix) {
    if (raw is String && raw.trim().startsWith(prefix)) {
      return raw.trim();
    }
    if (raw is Map) {
      for (final value in raw.values) {
        final found = _findPrefixed(value, prefix);
        if (found.isNotEmpty) return found;
      }
    }
    if (raw is List) {
      for (final value in raw) {
        final found = _findPrefixed(value, prefix);
        if (found.isNotEmpty) return found;
      }
    }
    return '';
  }
}

import '../../core/utils/api_body.dart';
import 'ride_booking.dart';
import 'wallet_transaction.dart';

class RidePaymentOption {
  const RidePaymentOption({
    required this.method,
    required this.label,
    this.available = true,
    this.walletBalance = 0,
    this.shortfall = 0,
  });

  final String method;
  final String label;
  final bool available;
  final double walletBalance;
  final double shortfall;

  bool get isCash => method == 'cash';
  bool get isOnline => method == 'online';
  bool get isWallet => method == 'wallet';

  static const defaults = [
    RidePaymentOption(method: 'cash', label: 'Cash'),
    RidePaymentOption(method: 'online', label: 'UPI'),
    RidePaymentOption(method: 'wallet', label: 'Wallet'),
  ];

  static String normalize(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'upi') return 'online';
    return value;
  }

  factory RidePaymentOption.fromJson(Map<String, dynamic> json) {
    final method = normalize(
      (json['method'] ?? json['paymentMethod'] ?? '').toString(),
    );
    final label = (json['label'] ?? json['paymentLabel'] ?? '').toString().trim();
    return RidePaymentOption(
      method: method,
      label: label.isNotEmpty
          ? label
          : method == 'online'
          ? 'UPI'
          : method.isEmpty
          ? ''
          : '${method[0].toUpperCase()}${method.substring(1)}',
      available: json['available'] != false,
      walletBalance: ApiBody.asNum(
        json['walletBalance'] ?? json['balance'],
      ).toDouble(),
      shortfall: ApiBody.asNum(json['shortfall']).toDouble(),
    );
  }

  static List<RidePaymentOption> listFrom(dynamic raw) {
    return ApiBody.asMapList(raw)
        .map(RidePaymentOption.fromJson)
        .where((item) => item.method.isNotEmpty)
        .toList(growable: false);
  }
}

class RidePayResult {
  const RidePayResult({
    required this.nextStep,
    this.paymentMethod = '',
    this.paymentLabel = '',
    this.paymentStatus = '',
    this.message = '',
    this.ride,
    this.order,
  });

  final String nextStep;
  final String paymentMethod;
  final String paymentLabel;
  final String paymentStatus;
  final String message;
  final RideBooking? ride;
  final WalletOrder? order;

  bool get awaitCash => nextStep == 'await_driver_cash';
  bool get openRazorpay => nextStep == 'open_razorpay';
  bool get isDone =>
      nextStep == 'done' || paymentStatus.toLowerCase() == 'paid';

  factory RidePayResult.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final source = data.isEmpty ? json : data;
    final method = RidePaymentOption.normalize(
      (source['paymentMethod'] ?? source['method'] ?? '').toString(),
    );
    var nextStep = (source['nextStep'] ?? '').toString().trim();
    final order = WalletOrder.fromJson(json);
    if (nextStep.isEmpty) {
      if (method == 'cash') {
        nextStep = 'await_driver_cash';
      } else if (method == 'wallet') {
        nextStep = 'done';
      } else if (method == 'online') {
        nextStep = 'open_razorpay';
      } else if (order.hasRazorpayKey ||
          (order.razorpayOrderId.isNotEmpty &&
              !order.razorpayOrderId.contains('wallet'))) {
        nextStep = 'open_razorpay';
      } else {
        nextStep = 'done';
      }
    }

    RideBooking? ride;
    final rideMap = ApiBody.asMap(source['ride']);
    if (rideMap != null && rideMap.isNotEmpty) {
      ride = RideBooking.fromJson(rideMap);
    } else if ((source['_id'] ?? source['id']) != null) {
      ride = RideBooking.fromJson(json);
    }

    final status = (source['paymentStatus'] ??
            rideMap?['paymentStatus'] ??
            ride?.paymentStatus ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    return RidePayResult(
      nextStep: nextStep,
      paymentMethod: method.isNotEmpty
          ? method
          : RidePaymentOption.normalize(ride?.paymentMethod ?? ''),
      paymentLabel: (source['paymentLabel'] ?? ride?.paymentLabel ?? '')
          .toString()
          .trim(),
      paymentStatus: status,
      message: ApiBody.message(json, fallback: ''),
      ride: ride,
      order: order,
    );
  }
}

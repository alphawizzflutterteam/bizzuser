import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';

class RazorpayPayment {
  const RazorpayPayment({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String paymentId;
  final String orderId;
  final String signature;
}

class RazorpayCheckout {
  Razorpay? _razorpay;
  Completer<RazorpayPayment>? _pending;

  Future<RazorpayPayment> open(Map<String, dynamic> options) {
    _pending?.completeError(
      const ApiException(AppStrings.paymentCancelled),
    );
    final pending = Completer<RazorpayPayment>();
    _pending = pending;
    try {
      _sdk.open(options);
    } catch (error) {
      _pending = null;
      if (!pending.isCompleted) {
        pending.completeError(
          ApiException('$error'),
        );
      }
    }
    return pending.future;
  }

  Razorpay get _sdk {
    final existing = _razorpay;
    if (existing != null) return existing;
    final sdk = Razorpay();
    sdk.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    sdk.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    sdk.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _razorpay = sdk;
    return sdk;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    final pending = _pending;
    _pending = null;
    if (pending == null || pending.isCompleted) return;
    pending.complete(
      RazorpayPayment(
        paymentId: response.paymentId?.trim() ?? '',
        orderId: response.orderId?.trim() ?? '',
        signature: response.signature?.trim() ?? '',
      ),
    );
  }

  void _onError(PaymentFailureResponse response) {
    final pending = _pending;
    _pending = null;
    if (pending == null || pending.isCompleted) return;
    final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    pending.completeError(
      ApiException(
        cancelled
            ? AppStrings.paymentCancelled
            : (response.message?.trim().isNotEmpty == true
                  ? response.message!.trim()
                  : AppStrings.paymentFailed),
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse _) {}

  void dispose() {
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(const ApiException(AppStrings.paymentCancelled));
    }
    _razorpay?.clear();
    _razorpay = null;
  }
}

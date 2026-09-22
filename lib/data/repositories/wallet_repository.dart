import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/wallet_transaction.dart';
import 'base_repository.dart';

class WalletRepository extends BaseRepository {
  const WalletRepository(super.apiService);

  Future<WalletInfo> fetchWallet() async {
    final json = await apiService.getJson(ApiConstants.wallet);
    return WalletInfo.fromJson(json);
  }

  Future<List<WalletTransaction>> fetchTransactions({String? type}) async {
    final json = await apiService.getJson(
      ApiConstants.walletTransactions,
      query: type == null || type.isEmpty ? null : {'type': type},
    );
    return ApiBody.dataList(json)
        .map(WalletTransaction.fromJson)
        .toList(growable: false);
  }

  Future<WalletOrder> addMoney(num amount) async {
    final json = await apiService.postJson(ApiConstants.walletAddMoney, {
      'amount': amount.round(),
    });
    return WalletOrder.fromJson(json);
  }

  Future<String> fetchRazorpayKey() async {
    try {
      final json = await apiService.getJson(ApiConstants.appConfig);
      final map = ApiBody.dataMap(json);
      final razorpay = ApiBody.asMap(map['razorpay']) ?? {};
      final key = (map['razorpayKey'] ??
                  map['razorpay_key'] ??
                  map['razorpayKeyId'] ??
                  map['keyId'] ??
                  razorpay['key'] ??
                  razorpay['keyId'] ??
                  json['razorpayKey'])
              ?.toString()
              .trim() ??
          '';
      if (key.startsWith('rzp_')) return key;
      return WalletOrder.fromJson(json).key;
    } catch (_) {
      return '';
    }
  }

  Future<WalletInfo> verify({
    required String paymentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final json = await apiService.postJson(ApiConstants.walletVerify, {
      'paymentId': paymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    });
    return WalletInfo.fromJson(json);
  }
}

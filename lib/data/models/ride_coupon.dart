import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';

class RideCoupon {
  const RideCoupon({
    this.id = '',
    required this.code,
    required this.title,
    required this.subtitle,
    required this.discount,
    this.discountType = 'flat',
    this.maxDiscount = 0,
    this.minAmount = 0,
    this.active = true,
  });

  final String id;
  final String code;
  final String title;
  final String subtitle;
  final double discount;
  final String discountType;
  final double maxDiscount;
  final double minAmount;
  final bool active;

  bool get isPercent => discountType.toLowerCase() == 'percent';

  double amountOff(num fare) {
    if (isPercent) {
      final off = fare * discount / 100;
      if (maxDiscount > 0 && off > maxDiscount) return maxDiscount;
      return off < 0 ? 0 : off.toDouble();
    }
    return discount < 0 ? 0 : discount;
  }

  factory RideCoupon.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? json['couponCode'] ?? json['title'])
            ?.toString()
            .trim() ??
        '';
    final offerText = (json['offerText'] ?? json['title'])?.toString().trim() ?? '';
    final description =
        (json['description'] ??
                json['subtitle'] ??
                json['validityLabel'] ??
                json['title'])
            ?.toString()
            .trim() ??
        '';
    final type =
        (json['discountType'] ?? json['type'] ?? 'flat').toString().trim();
    final usable = json['usable'];
    return RideCoupon(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      code: code,
      title: offerText.isNotEmpty
          ? offerText
          : (code.isNotEmpty ? code : AppStrings.availableCoupons),
      subtitle: description.isNotEmpty
          ? description
          : AppStrings.couponFirst50Hint,
      discount: ApiBody.asNum(
        json['discountValue'] ?? json['discount'] ?? json['amount'],
      ).toDouble(),
      discountType: type.isEmpty ? 'flat' : type,
      maxDiscount: ApiBody.asNum(json['maxDiscount']).toDouble(),
      minAmount: ApiBody.asNum(
        json['minAmount'] ?? json['minFare'],
      ).toDouble(),
      active: json['active'] != false && usable != false,
    );
  }
}

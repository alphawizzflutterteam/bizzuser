import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/media_url.dart';

class AppConfig {
  const AppConfig({
    this.name = '',
    this.tagline = '',
    this.mobileLogo = '',
    this.logoLight = '',
    this.email = '',
    this.contactNo = '',
    this.address = '',
    this.defaultCity = '',
    this.sosNumbers = const [],
    this.razorpayEnabled = false,
    this.razorpayKey = '',
    this.referralRewardAmount = 0,
  });

  final String name;
  final String tagline;
  final String mobileLogo;
  final String logoLight;
  final String email;
  final String contactNo;
  final String address;
  final String defaultCity;
  final List<String> sosNumbers;
  final bool razorpayEnabled;
  final String razorpayKey;
  final num referralRewardAmount;

  String get displayName => name.isNotEmpty ? name : AppStrings.appName;

  String get displayTagline =>
      tagline.isNotEmpty ? tagline : AppStrings.splashTagline;

  String get mobileLogoUrl {
    if (mobileLogo.isNotEmpty) return MediaUrl.resolve(mobileLogo);
    if (logoLight.isNotEmpty) return MediaUrl.resolve(logoLight);
    return '';
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final source = data.isNotEmpty ? data : json;
    final razorpay = ApiBody.asMap(source['razorpay']) ?? {};
    final key = (source['razorpayKey'] ??
            source['razorpay_key'] ??
            source['razorpayKeyId'] ??
            razorpay['key'] ??
            razorpay['keyId'])
        ?.toString()
        .trim() ??
        '';

    return AppConfig(
      name: source['name']?.toString().trim() ?? '',
      tagline: source['tagline']?.toString().trim() ?? '',
      mobileLogo: source['mobileLogo']?.toString().trim() ?? '',
      logoLight: source['logoLight']?.toString().trim() ?? '',
      email: source['email']?.toString().trim() ?? '',
      contactNo: source['contactNo']?.toString().trim() ?? '',
      address: source['address']?.toString().trim() ?? '',
      defaultCity: source['defaultCity']?.toString().trim() ?? '',
      sosNumbers: _numbers(source['sosNumbers'] ?? source['sos'] ?? json['sosNumbers']),
      razorpayEnabled: source['razorpayEnabled'] == true,
      razorpayKey: key.startsWith('rzp_') ? key : '',
      referralRewardAmount: ApiBody.asNum(
        source['referralRewardAmount'] ??
            source['referralReward'] ??
            source['rewardAmount'] ??
            json['referralRewardAmount'],
      ),
    );
  }

  static List<String> _numbers(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) {
            if (item is String) return item.trim();
            if (item is Map) {
              return (item['phone'] ?? item['number'] ?? item['value'])
                      ?.toString()
                      .trim() ??
                  '';
            }
            return item.toString().trim();
          })
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }
}

import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';

class UserAddress {
  const UserAddress({
    this.id = '',
    this.label = 'home',
    this.name = '',
    this.address = '',
    this.lat = 22.7533,
    this.lng = 75.8937,
  });

  final String id;
  final String label;
  final String name;
  final String address;
  final double lat;
  final double lng;

  String get displayName => name.isNotEmpty ? name : labelTitle;

  String get labelTitle {
    switch (label.toLowerCase()) {
      case 'work':
      case 'office':
        return AppStrings.labelWork;
      case 'other':
        return AppStrings.labelOther;
      default:
        return AppStrings.labelHome;
    }
  }

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    final location = ApiBody.asMap(json['location']) ?? {};
    final coords = location['coordinates'];
    var lat = ApiBody.asNum(
      json['lat'] ?? json['latitude'] ?? location['lat'],
      fallback: 22.7533,
    );
    var lng = ApiBody.asNum(
      json['lng'] ?? json['longitude'] ?? location['lng'],
      fallback: 75.8937,
    );
    if (coords is List && coords.length >= 2) {
      lng = ApiBody.asNum(coords[0], fallback: lng);
      lat = ApiBody.asNum(coords[1], fallback: lat);
    }
    return UserAddress(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      label: json['label']?.toString().trim().toLowerCase() ?? 'home',
      name: json['name']?.toString().trim() ?? '',
      address: json['address']?.toString().trim() ?? '',
      lat: lat.toDouble(),
      lng: lng.toDouble(),
    );
  }
}

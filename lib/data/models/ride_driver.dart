import '../../core/utils/api_body.dart';
import '../../core/utils/media_url.dart';

class RideDriver {
  const RideDriver({
    required this.name,
    required this.rating,
    required this.phone,
    required this.vehicleNumber,
    this.photoAsset,
    this.photoUrl = '',
    this.vehicleModel = '',
    this.vehicleColor = '',
  });

  final String name;
  final String rating;
  final String phone;
  final String vehicleNumber;
  final String? photoAsset;
  final String photoUrl;
  final String vehicleModel;
  final String vehicleColor;

  bool get hasName => name.trim().isNotEmpty;

  String get resolvedPhoto {
    if (photoUrl.isNotEmpty) return MediaUrl.resolve(photoUrl);
    return photoAsset ?? '';
  }

  factory RideDriver.fromJson(dynamic raw, {dynamic vehicle}) {
    final json = raw is Map
        ? raw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
    final nestedVehicle = ApiBody.asMap(json['vehicle']) ?? {};
    final siblingVehicle = ApiBody.asMap(vehicle) ?? {};
    final vehicleMap = siblingVehicle.isNotEmpty ? siblingVehicle : nestedVehicle;
    if (json.isEmpty && vehicleMap.isEmpty) {
      return const RideDriver(
        name: '',
        rating: '',
        phone: '',
        vehicleNumber: '',
      );
    }
    final ratingValue = json['rating'] ?? json['avgRating'];
    return RideDriver(
      name: (json['name'] ?? json['fullName'] ?? json['driverName'])
              ?.toString()
              .trim() ??
          '',
      rating: _rating(ratingValue),
      phone: (json['phone'] ?? json['mobile'] ?? json['contact'])
              ?.toString()
              .trim() ??
          '',
      vehicleNumber: (
            vehicleMap['registrationNumber'] ??
            vehicleMap['number'] ??
            vehicleMap['vehicleNumber'] ??
            json['vehicleNumber'] ??
            json['vehicleNo'] ??
            json['cabNumber']
          )
              ?.toString()
              .trim() ??
          '',
      photoUrl:
          (json['avatar'] ?? json['photo'] ?? json['image'] ?? json['profileImage'])
              ?.toString()
              .trim() ??
          '',
      vehicleModel: (vehicleMap['model'] ?? json['vehicleModel'])
              ?.toString()
              .trim() ??
          '',
      vehicleColor: (vehicleMap['color'] ?? json['vehicleColor'])
              ?.toString()
              .trim() ??
          '',
    );
  }

  static String _rating(dynamic value) {
    if (value == null) return '';
    if (value is num) {
      return value % 1 == 0
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
    }
    return value.toString().trim();
  }
}

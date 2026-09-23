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
    this.lat,
    this.lng,
  });

  final String name;
  final String rating;
  final String phone;
  final String vehicleNumber;
  final String? photoAsset;
  final String photoUrl;
  final String vehicleModel;
  final String vehicleColor;

  /// Driver's last known position (`location.coordinates` is `[lng, lat]`).
  final double? lat;
  final double? lng;

  bool get hasLocation =>
      lat != null && lng != null && (lat != 0 || lng != 0);

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
    final coords = _coordinates(json['location']);
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
      lat: coords?[1],
      lng: coords?[0],
    );
  }

  /// GeoJSON point → `[lng, lat]`, or null when missing / malformed.
  static List<double>? _coordinates(dynamic raw) {
    final location = ApiBody.asMap(raw);
    final list = location?['coordinates'];
    if (list is! List || list.length < 2) return null;
    final lng = double.tryParse(list[0].toString());
    final lat = double.tryParse(list[1].toString());
    if (lng == null || lat == null) return null;
    return [lng, lat];
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

import '../../core/utils/api_body.dart';
import 'vehicle_option.dart';

class RideEstimateVehicle {
  const RideEstimateVehicle({
    this.id = '',
    this.vehicleType = '',
    this.name = '',
    this.shortName = '',
    this.label = '',
    this.tagline = '',
    this.distanceKm = 0,
    this.durationMin = 0,
    this.fare = 0,
    this.baseFare = 0,
    this.tax = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.distanceFare = 0,
    this.waitingCharge = 0,
    this.discount = 0,
    this.total = 0,
  });

  final String id;
  final String vehicleType;
  final String name;
  final String shortName;
  final String label;
  final String tagline;
  final double distanceKm;
  final double durationMin;
  final double fare;
  final double baseFare;
  final double tax;
  final double cgst;
  final double sgst;
  final double igst;
  final double distanceFare;
  final double waitingCharge;
  final double discount;
  final double total;

  double get displayFare {
    if (total > 0) return total;
    return fare < 0 ? 0 : fare;
  }

  String get distance {
    if (distanceKm <= 0) return '';
    final label = distanceKm % 1 == 0
        ? distanceKm.toStringAsFixed(0)
        : distanceKm.toStringAsFixed(2);
    return '$label km';
  }

  String get durationLabel {
    if (durationMin <= 0) return '';
    final minutes = durationMin % 1 == 0
        ? durationMin.toStringAsFixed(0)
        : durationMin.toStringAsFixed(1);
    return '$minutes min';
  }

  bool matches(VehicleOption option) {
    return matchesQuery('${option.id} ${option.name}');
  }

  bool matchesQuery(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return false;
    final hay = '$id $vehicleType $name $shortName $label'.toLowerCase();
    for (final part in needle.split(RegExp(r'\s+'))) {
      if (part.isEmpty) continue;
      if (hay.contains(part)) return true;
    }
    return false;
  }

  factory RideEstimateVehicle.fromJson(Map<String, dynamic> json) {
    final type = ApiBody.asMap(json['vehicleType'] ?? json['vehicle']) ?? {};
    final breakdown =
        ApiBody.asMap(json['fareBreakdown'] ?? json['breakdown']) ?? json;
    final typeName =
        (json['vehicleType'] is String
                ? json['vehicleType']
                : type['name'] ?? type['vehicleType'])
            ?.toString()
            .trim() ??
        '';
    final fare = ApiBody.asNum(
      json['fare'] ?? json['total'] ?? json['price'] ?? breakdown['total'],
    ).toDouble();
    return RideEstimateVehicle(
      id: (type['_id'] ?? type['id'] ?? json['_id'] ?? json['id'])
              ?.toString() ??
          '',
      vehicleType: typeName,
      name: (json['name'] ?? type['name'] ?? typeName).toString().trim(),
      shortName: (json['shortName'] ?? type['shortName'] ?? json['label'])
              ?.toString()
              .trim() ??
          '',
      label: (json['label'] ?? type['label'])?.toString().trim() ?? '',
      tagline: (json['tagline'] ?? type['tagline'])?.toString().trim() ?? '',
      distanceKm: ApiBody.asNum(
        json['distanceKm'] ?? json['distance'],
      ).toDouble(),
      durationMin: ApiBody.asNum(
        json['durationMin'] ?? json['duration'],
      ).toDouble(),
      fare: fare,
      baseFare: ApiBody.asNum(breakdown['baseFare'] ?? json['baseFare'])
          .toDouble(),
      tax: ApiBody.asNum(breakdown['tax'] ?? json['tax'] ?? json['gst'])
          .toDouble(),
      cgst: ApiBody.asNum(breakdown['cgst'] ?? json['cgst']).toDouble(),
      sgst: ApiBody.asNum(breakdown['sgst'] ?? json['sgst']).toDouble(),
      igst: ApiBody.asNum(breakdown['igst'] ?? json['igst']).toDouble(),
      distanceFare: ApiBody.asNum(
        breakdown['distanceFare'] ?? json['distanceFare'],
      ).toDouble(),
      waitingCharge: ApiBody.asNum(
        breakdown['waitingCharge'] ?? json['waitingCharge'],
      ).toDouble(),
      discount: ApiBody.asNum(
        breakdown['discount'] ?? json['couponDiscount'] ?? json['discount'],
      ).toDouble(),
      total: ApiBody.asNum(breakdown['total'] ?? json['total'] ?? fare)
          .toDouble(),
    );
  }
}

class RideEstimate {
  const RideEstimate({
    this.baseFare = 0,
    this.tax = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.distanceFare = 0,
    this.waitingCharge = 0,
    this.discount = 0,
    this.total = 0,
    this.couponCode = '',
    this.message = '',
    this.distance = '',
    this.vehicles = const [],
  });

  final double baseFare;
  final double tax;
  final double cgst;
  final double sgst;
  final double igst;
  final double distanceFare;
  final double waitingCharge;
  final double discount;
  final double total;
  final String couponCode;
  final String message;
  final String distance;
  final List<RideEstimateVehicle> vehicles;

  factory RideEstimate.fromJson(
    Map<String, dynamic> json, {
    String? vehicleType,
  }) {
    final map = ApiBody.dataMap(json);
    final parent = map.isEmpty ? json : map;
    var rows = ApiBody.dataList(json);
    if (rows.isEmpty) {
      rows = ApiBody.asMapList(
        parent['estimates'] ?? parent['vehicles'] ?? parent['fares'],
      );
    }
    final hasSingleFare =
        parent['fare'] != null ||
        parent['fareBreakdown'] != null ||
        parent['breakdown'] != null;
    if (rows.isEmpty && hasSingleFare) {
      rows = [parent];
    }
    final vehicles =
        rows.map(RideEstimateVehicle.fromJson).toList(growable: false);
    final matched = _matchVehicle(vehicles, vehicleType) ??
        (vehicles.isEmpty ? null : vehicles.first);
    final coupon = ApiBody.asMap(parent['coupon'] ?? json['coupon']) ?? {};
    return RideEstimate(
      baseFare: matched?.baseFare ??
          ApiBody.asNum(parent['baseFare'] ?? json['baseFare']).toDouble(),
      tax: matched?.tax ??
          ApiBody.asNum(parent['tax'] ?? json['tax']).toDouble(),
      cgst: matched?.cgst ??
          ApiBody.asNum(parent['cgst'] ?? json['cgst']).toDouble(),
      sgst: matched?.sgst ??
          ApiBody.asNum(parent['sgst'] ?? json['sgst']).toDouble(),
      igst: matched?.igst ??
          ApiBody.asNum(parent['igst'] ?? json['igst']).toDouble(),
      distanceFare: matched?.distanceFare ??
          ApiBody.asNum(
            parent['distanceFare'] ?? json['distanceFare'],
          ).toDouble(),
      waitingCharge: matched?.waitingCharge ??
          ApiBody.asNum(
            parent['waitingCharge'] ?? json['waitingCharge'],
          ).toDouble(),
      discount: matched?.discount ??
          ApiBody.asNum(
            parent['discount'] ?? coupon['discount'] ?? json['discount'],
          ).toDouble(),
      total: matched?.displayFare ??
          ApiBody.asNum(
            parent['total'] ?? parent['fare'] ?? json['total'],
          ).toDouble(),
      couponCode:
          (parent['couponCode'] ?? json['couponCode'] ?? coupon['code'])
              ?.toString()
              .trim() ??
          '',
      message: ApiBody.message(json, fallback: ''),
      distance: matched?.distance ??
          (vehicles.isNotEmpty ? vehicles.first.distance : ''),
      vehicles: vehicles,
    );
  }

  static RideEstimateVehicle? _matchVehicle(
    List<RideEstimateVehicle> vehicles,
    String? vehicleType,
  ) {
    final needle = vehicleType?.trim() ?? '';
    if (needle.isEmpty) return null;
    for (final item in vehicles) {
      if (item.matchesQuery(needle)) return item;
    }
    return null;
  }
}

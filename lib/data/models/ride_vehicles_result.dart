import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/media_url.dart';
import 'ride_location.dart';
import 'vehicle_option.dart';

class RideVehiclesResult {
  const RideVehiclesResult({
    this.distanceKm = 0,
    this.durationMin = 0,
    this.distanceLabel = '',
    this.pickup = const RideLocation(title: '', subtitle: ''),
    this.drop = const RideLocation(title: '', subtitle: ''),
    this.vehicles = const [],
  });

  final double distanceKm;
  final double durationMin;
  final String distanceLabel;
  final RideLocation pickup;
  final RideLocation drop;
  final List<RideVehicleOffer> vehicles;

  String get distance {
    if (distanceLabel.trim().isNotEmpty) return distanceLabel.trim();
    if (distanceKm <= 0) return '';
    if (distanceKm < 10) {
      final rounded = (distanceKm * 10).round() / 10;
      final label = rounded % 1 == 0
          ? rounded.toStringAsFixed(0)
          : rounded.toStringAsFixed(1);
      return '$label km';
    }
    return '${distanceKm.round()} km';
  }

  factory RideVehiclesResult.fromJson(Map<String, dynamic> json) {
    final map = ApiBody.dataMap(json);
    final data = map.isEmpty ? json : map;
    final rows = ApiBody.asMapList(data['vehicles'] ?? data['items']);
    final fallback = rows.isEmpty ? ApiBody.dataList(json) : rows;
    return RideVehiclesResult(
      distanceKm: ApiBody.asNum(data['distanceKm'] ?? data['distance'])
          .toDouble(),
      durationMin: ApiBody.asNum(data['durationMin'] ?? data['duration'])
          .toDouble(),
      distanceLabel: (data['distanceLabel'] ?? data['distanceText'])
              ?.toString()
              .trim() ??
          '',
      pickup: RideLocation.fromJson(
        data['pickup'] ?? data['pickupLocation'] ?? data['from'],
      ),
      drop: RideLocation.fromJson(
        data['drop'] ?? data['dropLocation'] ?? data['to'],
      ),
      vehicles: fallback
          .map(RideVehicleOffer.fromJson)
          .where((item) => item.name.isNotEmpty || item.id.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class RideVehicleOffer {
  const RideVehicleOffer({
    this.id = '',
    this.category = '',
    this.vehicleType = '',
    this.name = '',
    this.shortName = '',
    this.label = '',
    this.tagline = '',
    this.iconPath = '',
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
    this.distanceKm = 0,
    this.durationMin = 0,
    this.dropBadge = '',
  });

  final String id;
  final String category;
  final String vehicleType;
  final String name;
  final String shortName;
  final String label;
  final String tagline;
  final String iconPath;
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
  final double distanceKm;
  final double durationMin;
  final String dropBadge;

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

  String get displayName =>
      shortName.isNotEmpty ? shortName : (name.isNotEmpty ? name : label);

  IconData get iconData {
    final value = '$vehicleType $category $name $shortName $label'.toLowerCase();
    if (value.contains('bike') || value.contains('2-wheeler')) {
      return Icons.two_wheeler_rounded;
    }
    if (value.contains('toto')) {
      return Icons.airport_shuttle_rounded;
    }
    if (value.contains('auto') || value.contains('3-wheeler')) {
      return Icons.electric_rickshaw;
    }
    return Icons.directions_car_filled_rounded;
  }

  String get localAsset {
    final value = '$vehicleType $category $name $shortName'.toLowerCase();
    if (value.contains('bike') || value.contains('2-wheeler')) {
      return AppAssets.vehicleBike;
    }
    if (value.contains('toto')) {
      return AppAssets.vehicleToto;
    }
    if (value.contains('auto') || value.contains('3-wheeler')) {
      return AppAssets.vehicleAutoOption;
    }
    return AppAssets.vehicleCar;
  }

  VehicleOption toOption() {
    final iconUrl = MediaUrl.resolve(iconPath);
    return VehicleOption(
      id: id.isNotEmpty ? id : displayName.toLowerCase(),
      name: displayName,
      subtitle: tagline,
      price: displayFare,
      icon: iconData,
      eta: durationLabel,
      distance: distance,
      badge: dropBadge,
      imageAsset: localAsset,
      imageUrl: iconUrl.isEmpty ? null : iconUrl,
      vehicleType: vehicleType.isNotEmpty ? vehicleType : category,
      baseFare: baseFare,
      tax: tax,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      distanceFare: distanceFare,
      waitingCharge: waitingCharge,
      discount: discount,
      total: displayFare,
    );
  }

  factory RideVehicleOffer.fromJson(Map<String, dynamic> json) {
    final breakdown =
        ApiBody.asMap(json['fareBreakdown'] ?? json['breakdown']) ?? {};
    final fare = ApiBody.asNum(
      json['fare'] ?? json['total'] ?? json['price'] ?? breakdown['total'],
    ).toDouble();
    return RideVehicleOffer(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      category: (json['category'] ?? json['vehicleType'])?.toString().trim() ??
          '',
      vehicleType: (json['vehicleType'] ?? json['category'])
              ?.toString()
              .trim() ??
          '',
      name: (json['name'] ?? json['shortName'])?.toString().trim() ?? '',
      shortName: json['shortName']?.toString().trim() ?? '',
      label: json['label']?.toString().trim() ?? '',
      tagline: (json['tagline'] ?? json['description'])?.toString().trim() ??
          '',
      iconPath: json['icon']?.toString().trim() ?? '',
      fare: fare,
      baseFare: ApiBody.asNum(breakdown['baseFare'] ?? json['baseFare'])
          .toDouble(),
      tax: ApiBody.asNum(breakdown['tax'] ?? json['tax']).toDouble(),
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
        breakdown['discount'] ?? json['discount'],
      ).toDouble(),
      total: ApiBody.asNum(breakdown['total'] ?? json['total'] ?? fare)
          .toDouble(),
      distanceKm: ApiBody.asNum(json['distanceKm'] ?? json['distance'])
          .toDouble(),
      durationMin: ApiBody.asNum(json['durationMin'] ?? json['duration'])
          .toDouble(),
      dropBadge: (json['estimatedDropLabel'] ?? json['dropLabel'])
              ?.toString()
              .trim() ??
          '',
    );
  }
}

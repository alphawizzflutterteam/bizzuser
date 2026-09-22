import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/media_url.dart';
import 'vehicle_category.dart';
import 'vehicle_option.dart';

class VehicleType {
  const VehicleType({
    required this.id,
    required this.name,
    required this.shortName,
    required this.tagline,
    required this.baseFare,
    required this.minFare,
    required this.perKm,
    required this.capacity,
    this.iconPath = '',
    this.active = true,
    this.label = '',
  });

  final String id;
  final String name;
  final String shortName;
  final String tagline;
  final num baseFare;
  final num minFare;
  final num perKm;
  final int capacity;
  final String iconPath;
  final bool active;
  final String label;

  String get displayName => shortName.isNotEmpty ? shortName : name;

  String get iconUrl => MediaUrl.resolve(iconPath);

  IconData get iconData {
    final value = '$name $shortName $label'.toLowerCase();
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
    final value = '$name $shortName'.toLowerCase();
    if (value.contains('bike') || value.contains('2-wheeler')) {
      return AppAssets.vehicleBike;
    }
    if (value.contains('toto')) {
      return AppAssets.vehicleToto;
    }
    if (value.contains('auto') || value.contains('3-wheeler')) {
      return AppAssets.vehicleAuto;
    }
    return AppAssets.vehicleCar;
  }

  VehicleCategory toCategory() {
    return VehicleCategory(
      id: id,
      title: name,
      subtitle: tagline,
      icon: iconData,
      imageAsset: localAsset,
      imageUrl: iconUrl.isEmpty ? null : iconUrl,
    );
  }

  VehicleOption toOption() {
    final fare = minFare > 0 ? minFare : baseFare;
    return VehicleOption(
      id: id,
      name: displayName,
      subtitle: tagline,
      price: fare.toDouble(),
      icon: iconData,
      imageAsset: localAsset,
      imageUrl: iconUrl.isEmpty ? null : iconUrl,
      vehicleType: name,
    );
  }

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      shortName: json['shortName']?.toString().trim() ?? '',
      tagline: json['tagline']?.toString().trim() ?? '',
      baseFare: ApiBody.asNum(json['baseFare']),
      minFare: ApiBody.asNum(json['minFare']),
      perKm: ApiBody.asNum(json['perKm']),
      capacity: ApiBody.asInt(json['capacity']) ?? 1,
      iconPath: json['icon']?.toString().trim() ?? '',
      active: json['active'] != false,
      label: json['label']?.toString().trim() ?? '',
    );
  }
}

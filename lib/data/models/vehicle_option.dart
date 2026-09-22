import 'package:flutter/material.dart';

class VehicleOption {
  const VehicleOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
    this.eta = '',
    this.distance = '',
    this.badge = '',
    this.imageAsset,
    this.imageUrl,
    this.vehicleType = '',
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
  final String name;
  final String subtitle;
  final double price;
  final IconData icon;
  final String eta;
  final String distance;
  final String badge;
  final String? imageAsset;
  final String? imageUrl;
  final String vehicleType;
  final double baseFare;
  final double tax;
  final double cgst;
  final double sgst;
  final double igst;
  final double distanceFare;
  final double waitingCharge;
  final double discount;
  final double total;

  String get canonicalType {
    final type = vehicleType.trim();
    if (type.isNotEmpty) return type;
    return name.trim();
  }

  VehicleOption copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? price,
    IconData? icon,
    String? eta,
    String? distance,
    String? badge,
    String? imageAsset,
    String? imageUrl,
    String? vehicleType,
    double? baseFare,
    double? tax,
    double? cgst,
    double? sgst,
    double? igst,
    double? distanceFare,
    double? waitingCharge,
    double? discount,
    double? total,
  }) {
    return VehicleOption(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      eta: eta ?? this.eta,
      distance: distance ?? this.distance,
      badge: badge ?? this.badge,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      baseFare: baseFare ?? this.baseFare,
      tax: tax ?? this.tax,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      igst: igst ?? this.igst,
      distanceFare: distanceFare ?? this.distanceFare,
      waitingCharge: waitingCharge ?? this.waitingCharge,
      discount: discount ?? this.discount,
      total: total ?? this.total,
    );
  }
}

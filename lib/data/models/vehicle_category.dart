import 'package:flutter/material.dart';

class VehicleCategory {
  const VehicleCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageAsset;
  final String? imageUrl;
}

import 'package:flutter/material.dart';

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color iconColor;
}

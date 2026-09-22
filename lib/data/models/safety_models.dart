import 'package:flutter/material.dart';

class SafetyAction {
  const SafetyAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color iconColor;
}

class SafetyReason {
  const SafetyReason({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final IconData icon;
}

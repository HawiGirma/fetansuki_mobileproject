import 'package:flutter/material.dart';

enum SettingType {
  toggle,
  navigation,
  action,
}

class SettingOption {
  final String id;
  final String label;
  final IconData icon;
  final String? value; // e.g., "On", "English"
  final SettingType type;
  final Color? iconColor;

  const SettingOption({
    required this.id,
    required this.label,
    required this.icon,
    this.value,
    this.type = SettingType.navigation,
    this.iconColor,
  });
}

import 'package:flutter/material.dart';

class UpdateItem {
  final String id;
  final String title;
  final String subtitle;
  final double currentAmount;
  final double totalAmount;
  final Color iconColor;
  final Color iconTintColor;
  final IconData iconData;

  const UpdateItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentAmount,
    required this.totalAmount,
    required this.iconColor,
    required this.iconTintColor,
    required this.iconData,
  });
}

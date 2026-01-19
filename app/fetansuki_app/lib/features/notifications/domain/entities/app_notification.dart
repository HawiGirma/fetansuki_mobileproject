import 'package:flutter/material.dart';

enum NotificationType {
  sale,
  credit,
  lowStock,
  payment,
  stockAdded
}

class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type;
  final String? userId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.userId,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.sale:
        return Icons.shopping_bag_outlined;
      case NotificationType.credit:
        return Icons.notifications_active_outlined;
      case NotificationType.lowStock:
        return Icons.warning_amber_rounded;
      case NotificationType.payment:
        return Icons.check_circle_outline;
      case NotificationType.stockAdded:
        return Icons.add_circle_outline;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.sale:
        return Colors.blue;
      case NotificationType.credit:
        return Colors.orange;
      case NotificationType.lowStock:
        return Colors.red;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.stockAdded:
        return Colors.purple;
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: json['timestamp'] != null 
          ? (json['timestamp'] is DateTime 
              ? json['timestamp'] as DateTime 
              : DateTime.parse(json['timestamp'] as String))
          : DateTime.now(),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.sale,
      ),
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'user_id': userId,
    };
  }
}

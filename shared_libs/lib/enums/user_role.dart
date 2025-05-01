import 'package:flutter/material.dart';

enum UserRole {
  customer,
  seller,
  admin,
  delivery,
  guest,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.customer:
        return 'عميل';
      case UserRole.seller:
        return 'بائع';
      case UserRole.admin:
        return 'مدير';
      case UserRole.delivery:
        return 'مندوب توصيل';
      case UserRole.guest:
        return 'زائر';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.seller:
        return Icons.store;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.delivery:
        return Icons.delivery_dining;
      case UserRole.guest:
        return Icons.person_outline;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.seller:
        return Colors.green;
      case UserRole.admin:
        return Colors.purple;
      case UserRole.delivery:
        return Colors.orange;
      case UserRole.guest:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';

/// نظام الألوان الموحد للتطبيق
/// تم توحيده مع تطبيق user_app
class AppColors {
  // ألوان العلامة التجارية الأساسية
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color accent = Color(0xFFFF9800);
  static const Color onPrimary = Colors.white;

  // ألوان الثانوية
  static const Color secondary = Color(0xFFFF9800); // برتقالي
  static const Color secondaryLight = Color(0xFFFFE0B2);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color onSecondary = Colors.black;

  // ألوان الخلفية
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);

  // ألوان النص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF000000);

  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color onError = Colors.white;

  // ألوان الحدود والفواصل
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFF9E9E9E);
  static const Color shadow = Color(0x40000000);

  // ألوان الوضع الداكن
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF9E9E9E);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkBorder = Color(0xFF616161);
  static const Color onDarkBackground = Color(0xFFE0E0E0);
  static const Color onDarkSurface = Color(0xFFE0E0E0);

  // ألوان حالة الطلب (خاصة بتطبيق البائع)
  static const Color orderPending = Color(0xFFFFA000);
  static const Color orderPreparing = Color(0xFF1976D2);
  static const Color orderDelivering = Color(0xFF7B1FA2);
  static const Color orderDelivered = Color(0xFF388E3C);
  static const Color orderCancelled = Color(0xFFB71C1C);
}

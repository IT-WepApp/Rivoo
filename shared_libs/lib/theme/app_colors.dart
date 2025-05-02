import 'package:flutter/material.dart';

/// ألوان التطبيق الموحدة
///
/// يحتوي هذا الملف على جميع ألوان التطبيق المستخدمة في جميع أنحاء التطبيق
/// لضمان اتساق المظهر وسهولة التعديل

class AppColors {
  // منع إنشاء نسخة من الفئة
  AppColors._();

  // الألوان الأساسية
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF0069C0);
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryVariant = Color(0xFFC66900);
  static const Color accent = Color(0xFF03A9F4);

  // ألوان السطح
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFFAFAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color dialog = Color(0xFFFFFFFF);

  // ألوان النص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF000000);

  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // ألوان الوضع الداكن
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);

  // ألوان أخرى
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color overlay = Color(0x80000000);
  
  // ألوان التصنيفات
  static const Color food = Color(0xFFF44336);
  static const Color electronics = Color(0xFF2196F3);
  static const Color fashion = Color(0xFF9C27B0);
  static const Color beauty = Color(0xFFE91E63);
  static const Color home = Color(0xFF4CAF50);
  static const Color sports = Color(0xFFFF9800);
  
  // ألوان الحالات
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusProcessing = Color(0xFF2196F3);
  static const Color statusShipped = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);
  
  // ألوان التقييم
  static const Color ratingActive = Color(0xFFFFC107);
  static const Color ratingInactive = Color(0xFFE0E0E0);
}

/// أبعاد التطبيق الموحدة
///
/// يحتوي هذا الملف على جميع أبعاد التطبيق المستخدمة في جميع أنحاء التطبيق
/// لضمان اتساق المظهر وسهولة التعديل

class AppDimensions {
  // منع إنشاء نسخة من الفئة
  AppDimensions._();

  // الهوامش والحشوات
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // نصف قطر الزوايا
  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // الارتفاعات
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;
  static const double bottomNavBarHeight = 56.0;
  static const double listItemHeight = 72.0;
  static const double cardHeight = 160.0;
  static const double dialogWidth = 280.0;

  // الارتفاعات
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // أحجام الخط
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 34.0;
}

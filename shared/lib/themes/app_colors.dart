import 'package:flutter/material.dart';

/// ألوان التطبيق الموحدة
class AppColors {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF6200EE); // اللون الأساسي
  static const Color primaryVariant = Color(0xFF3700B3); // متغير اللون الأساسي
  static const Color accentColor = Color(0xFF03DAC6); // لون ثانوي بارز
  static const Color accentVariant = Color(0xFF018786); // متغير اللون الثانوي

  // ألوان الخلفية والسطح
  static const Color background = Color(0xFFFFFFFF); // لون الخلفية الفاتحة
  static const Color backgroundDark = Color(0xFF121212); // لون الخلفية الداكنة
  static const Color surface = Color(0xFFF5F5F5); // لون للأسطح الخلفية
  static const Color surfaceDark = Color(0xFF1E1E1E); // لون للأسطح الداكنة

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF212121); // لون النص الأساسي
  static const Color textSecondary = Color(0xFF757575); // لون النص الثانوي
  static const Color textHint = Color(0xFF9E9E9E); // لون نص التلميح
  static const Color textPrimaryDark =
      Color(0xFFE1E1E1); // لون النص الأساسي في الوضع الداكن
  static const Color textSecondaryDark =
      Color(0xFFB0B0B0); // لون النص الثانوي في الوضع الداكن

  // ألوان الحالات
  static const Color success = Color(0xFF4CAF50); // لون النجاح
  static const Color warning = Color(0xFFFFC107); // لون التحذير
  static const Color error = Color(0xFFF44336); // لون الخطأ
  static const Color info = Color(0xFF2196F3); // لون المعلومات

  // ألوان الحدود والفواصل
  static const Color divider = Color(0xFFE0E0E0); // لون الفواصل
  static const Color dividerDark =
      Color(0xFF424242); // لون الفواصل في الوضع الداكن
  static const Color border = Color(0xFFBDBDBD); // لون الحدود
  static const Color borderDark =
      Color(0xFF616161); // لون الحدود في الوضع الداكن

  // ألوان أخرى
  static const Color disabled = Color(0xFFBDBDBD); // لون العناصر المعطلة
  static const Color shadow = Color(0x40000000); // لون الظلال
  static const Color overlay = Color(0x80000000); // لون الطبقة الفوقية
}

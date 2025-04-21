import 'package:flutter/material.dart';

/// واجهة حالات استخدام إعدادات التطبيق
abstract class SettingsUseCases {
  /// تغيير لغة التطبيق
  Future<void> changeLanguage(String languageCode);

  /// الحصول على رمز اللغة الحالية
  String getCurrentLanguageCode();

  /// الحصول على اسم اللغة الحالية
  String getCurrentLanguageName();

  /// الحصول على علم اللغة الحالية
  String getCurrentLanguageFlag();

  /// الحصول على قائمة اللغات المدعومة
  List<Map<String, String>> getSupportedLanguages();

  /// تغيير وضع السمة
  Future<void> changeThemeMode(ThemeMode mode);

  /// التبديل بين أوضاع السمة
  Future<void> toggleThemeMode();

  /// الحصول على وضع السمة الحالي
  ThemeMode getCurrentThemeMode();

  /// الحصول على اسم وضع السمة الحالي
  String getCurrentThemeModeName();

  /// الحصول على أيقونة وضع السمة الحالي
  IconData getCurrentThemeModeIcon();
}

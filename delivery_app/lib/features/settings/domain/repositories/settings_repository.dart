import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مستودع الإعدادات
/// يوفر واجهة للتعامل مع إعدادات التطبيق
class SettingsRepository {
  final SharedPreferences _prefs;

  /// إنشاء نسخة جديدة من مستودع الإعدادات
  SettingsRepository({required SharedPreferences prefs}) : _prefs = prefs;

  /// الحصول على نسخة من مستودع الإعدادات
  static Future<SettingsRepository> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs: prefs);
  }

  /// الحصول على وضع السمة (فاتح أو داكن)
  ThemeMode getThemeMode() {
    final themeValue = _prefs.getString('theme_mode') ?? 'system';
    switch (themeValue) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// تعيين وضع السمة (فاتح أو داكن)
  Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeValue;
    switch (themeMode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      default:
        themeValue = 'system';
        break;
    }
    await _prefs.setString('theme_mode', themeValue);
  }

  /// الحصول على اللغة المفضلة
  Locale getLocale() {
    final localeString = _prefs.getString('locale') ?? 'ar';
    return Locale(localeString);
  }

  /// تعيين اللغة المفضلة
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString('locale', locale.languageCode);
  }

  /// الحصول على إعدادات الإشعارات
  bool getNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  /// تعيين إعدادات الإشعارات
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  /// الحصول على إعدادات تحديد الموقع
  bool getLocationEnabled() {
    return _prefs.getBool('location_enabled') ?? true;
  }

  /// تعيين إعدادات تحديد الموقع
  Future<void> setLocationEnabled(bool enabled) async {
    await _prefs.setBool('location_enabled', enabled);
  }

  /// الحصول على وحدة المسافة المفضلة (كم أو ميل)
  String getDistanceUnit() {
    return _prefs.getString('distance_unit') ?? 'km';
  }

  /// تعيين وحدة المسافة المفضلة (كم أو ميل)
  Future<void> setDistanceUnit(String unit) async {
    await _prefs.setString('distance_unit', unit);
  }
}

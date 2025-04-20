import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مزود حالة السمة
/// يتيح تبديل وحفظ وضع السمة (فاتح/داكن/النظام)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  /// مفتاح لحفظ وضع السمة في التخزين المحلي
  static const String _themePreferenceKey = 'theme_mode';

  /// مرجع للتخزين المحلي
  final SharedPreferences _prefs;

  /// إنشاء مزود حالة السمة مع التخزين المحلي
  ThemeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  /// تحميل وضع السمة من التخزين المحلي
  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final String? themeString = prefs.getString(_themePreferenceKey);
    if (themeString == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
      (element) => element.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  /// تعيين وضع السمة وحفظه في التخزين المحلي
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_themePreferenceKey, themeMode.toString());
    state = themeMode;
  }

  /// تبديل بين الوضع الفاتح والداكن
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// استخدام وضع النظام
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// الحصول على اسم وضع السمة الحالي
  String get themeName {
    switch (state) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// التحقق إذا كان الوضع الداكن مفعل
  bool get isDarkMode => state == ThemeMode.dark;

  /// التحقق إذا كان الوضع الفاتح مفعل
  bool get isLightMode => state == ThemeMode.light;

  /// التحقق إذا كان وضع النظام مفعل
  bool get isSystemMode => state == ThemeMode.system;
}

/// مزود حالة السمة
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  throw UnimplementedError('يجب تهيئة مزود السمة باستخدام ProviderContainer');
});

/// تهيئة مزود السمة
Future<Override> initializeThemeProvider() async {
  final prefs = await SharedPreferences.getInstance();
  return themeProvider.overrideWith((ref) => ThemeNotifier(prefs));
}

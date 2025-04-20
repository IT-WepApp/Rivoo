import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// مزود لوضع السمة (الوضع الليلي/النهاري)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  // تحميل وضع السمة المحفوظ
  Future<void> _loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeMode = prefs.getString('themeMode');
    if (themeMode != null) {
      switch (themeMode) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
          break;
      }
    }
  }

  // تغيير وضع السمة
  Future<void> changeThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeModeString = 'system';
        break;
    }
    await prefs.setString('themeMode', themeModeString);
  }

  // التبديل بين الوضع الليلي والنهاري
  Future<void> toggleThemeMode() async {
    switch (state) {
      case ThemeMode.light:
        await changeThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await changeThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await changeThemeMode(ThemeMode.light);
        break;
    }
  }

  // الحصول على اسم وضع السمة الحالي
  String getCurrentThemeModeName() {
    switch (state) {
      case ThemeMode.light:
        return 'lightMode';
      case ThemeMode.dark:
        return 'darkMode';
      case ThemeMode.system:
        return 'systemDefault';
    }
  }

  // الحصول على أيقونة وضع السمة الحالي
  IconData getCurrentThemeModeIcon() {
    switch (state) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.settings_suggest;
    }
  }
}

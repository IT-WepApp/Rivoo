import 'package:shared_preferences/shared_preferences.dart';

/// واجهة مستودع إعدادات التطبيق
abstract class SettingsRepository {
  /// الحصول على رمز اللغة المحفوظ
  Future<String?> getSavedLanguageCode();

  /// حفظ رمز اللغة
  Future<void> saveLanguageCode(String languageCode);

  /// الحصول على وضع السمة المحفوظ
  Future<String?> getSavedThemeMode();

  /// حفظ وضع السمة
  Future<void> saveThemeMode(String themeMode);
}

/// تنفيذ مستودع الإعدادات باستخدام SharedPreferences
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _languageCodeKey = 'languageCode';
  static const String _themeModeKey = 'themeMode';

  @override
  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  @override
  Future<String?> getSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode);
  }
}

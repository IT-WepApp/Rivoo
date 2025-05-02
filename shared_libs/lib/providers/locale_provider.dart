import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// مزود للغة التطبيق
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  // تحميل اللغة المحفوظة
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  // تغيير لغة التطبيق
  Future<void> changeLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  // الحصول على اسم اللغة الحالية
  String getCurrentLanguageName() {
    switch (state.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'tr':
        return 'Türkçe';
      case 'ur':
        return 'اردو';
      default:
        return 'العربية';
    }
  }

  // الحصول على رمز العلم للغة الحالية
  String getCurrentLanguageFlag() {
    switch (state.languageCode) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'tr':
        return '🇹🇷';
      case 'ur':
        return '🇵🇰';
      default:
        return '🇸🇦';
    }
  }

  // الحصول على قائمة اللغات المدعومة
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    ];
  }
}

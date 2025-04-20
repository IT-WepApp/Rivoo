import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مزود لإعدادات اللغة
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

/// قائمة اللغات المدعومة في التطبيق
class SupportedLanguages {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');
  static const Locale french = Locale('fr');
  static const Locale turkish = Locale('tr');
  static const Locale urdu = Locale('ur');

  /// الحصول على قائمة اللغات المدعومة
  static List<Locale> get supportedLocales => [
        arabic,
        english,
        french,
        turkish,
        urdu,
      ];

  /// الحصول على اسم اللغة بناءً على الرمز
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
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

  /// الحصول على رمز اللغة بناءً على الاسم
  static String getLanguageCode(String languageName) {
    switch (languageName) {
      case 'العربية':
        return 'ar';
      case 'English':
        return 'en';
      case 'Français':
        return 'fr';
      case 'Türkçe':
        return 'tr';
      case 'اردو':
        return 'ur';
      default:
        return 'ar';
    }
  }
}

/// مدير حالة اللغة
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(SupportedLanguages.arabic) {
    _loadSavedLanguage();
  }

  /// مفتاح تخزين اللغة في الإعدادات المشتركة
  static const String _languagePreferenceKey = 'language_code';

  /// تحميل اللغة المحفوظة
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_languagePreferenceKey);

    if (savedLanguageCode != null) {
      state = Locale(savedLanguageCode);
    }
  }

  /// تغيير اللغة
  Future<void> changeLanguage(Locale locale) async {
    if (!SupportedLanguages.supportedLocales.contains(locale)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, locale.languageCode);
    state = locale;
  }

  /// الحصول على اللغة الحالية
  Locale get currentLocale => state;
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// مدير اللغات للتطبيق
class LocalizationManager {
  // منع إنشاء نسخ من الكلاس
  LocalizationManager._();

  /// اللغات المدعومة في التطبيق
  static const List<Locale> supportedLocales = [
    Locale('ar'), // العربية
    Locale('en'), // الإنجليزية
    Locale('fr'), // الفرنسية
    Locale('tr'), // التركية
    Locale('nb'), // النرويجية
  ];

  /// مندوبي الترجمة المستخدمة في التطبيق
  static const List<LocalizationsDelegate> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// الحصول على اللغة الافتراضية
  static Locale getDefaultLocale() {
    return const Locale('ar');
  }

  /// الحصول على اسم اللغة بناءً على رمز اللغة
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
      case 'nb':
        return 'Norsk';
      default:
        return 'Unknown';
    }
  }
}

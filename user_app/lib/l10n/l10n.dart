import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// امتداد للسياق للوصول إلى الترجمات بسهولة
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// قائمة اللغات المدعومة
class L10n {
  static final all = [
    const Locale('ar'), // العربية
    const Locale('en'), // الإنجليزية
    const Locale('fr'), // الفرنسية
    const Locale('tr'), // التركية
    const Locale('ur'), // الأردو
  ];

  // الحصول على اسم اللغة بناءً على الرمز
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
        return 'Unknown';
    }
  }

  // الحصول على اتجاه النص بناءً على اللغة
  static TextDirection getTextDirection(String languageCode) {
    switch (languageCode) {
      case 'ar':
      case 'ur':
        return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }
}

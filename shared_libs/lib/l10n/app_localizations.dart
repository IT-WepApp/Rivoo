import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../generated/l10n/app_localizations.dart';


/// توفير وصول سهل إلى الترجمات
class L10n {
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      AppLocalizations.localizationsDelegates;

  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context);
}

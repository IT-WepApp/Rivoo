import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seller_panel/core/services/language_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// واجهة المستخدم لتغيير اللغة
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language),
      ),
      body: ListView(
        children: [
          _buildLanguageOption(
            context,
            ref,
            SupportedLanguages.arabic,
            localizations.arabic,
            currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            SupportedLanguages.english,
            localizations.english,
            currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            SupportedLanguages.french,
            localizations.french,
            currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            SupportedLanguages.turkish,
            localizations.turkish,
            currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            SupportedLanguages.urdu,
            localizations.urdu,
            currentLocale,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    String languageName,
    Locale currentLocale,
  ) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(languageName),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        ref.read(languageProvider.notifier).changeLanguage(locale);
      },
    );
  }
}

/// إضافة دعم تعدد اللغات للتطبيق
/// يجب استدعاء هذه الدالة في MaterialApp
List<LocalizationsDelegate<dynamic>> getLocalizationsDelegates() {
  return [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

/// الحصول على اللغات المدعومة للتطبيق
List<Locale> getSupportedLocales() {
  return SupportedLanguages.supportedLocales;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/presentation/providers/locale_provider.dart';

void main() {
  group('LocaleNotifier Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('يجب أن تكون اللغة الافتراضية هي العربية', () {
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'ar');
    });

    test('يجب أن يتم تغيير اللغة عند استدعاء changeLocale', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});

      final notifier = container.read(localeProvider.notifier);

      // تغيير اللغة إلى الإنجليزية
      await notifier.changeLocale('en');

      // التحقق من تغيير اللغة
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'en');
    });

    test('يجب أن تعيد getCurrentLanguageName اسم اللغة الصحيح', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});

      final notifier = container.read(localeProvider.notifier);

      // التحقق من اسم اللغة الافتراضية (العربية)
      expect(notifier.getCurrentLanguageName(), 'العربية');

      // تغيير اللغة إلى الإنجليزية
      await notifier.changeLocale('en');

      // التحقق من اسم اللغة بعد التغيير
      expect(notifier.getCurrentLanguageName(), 'English');
    });

    test('يجب أن تعيد getCurrentLanguageFlag علم اللغة الصحيح', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});

      final notifier = container.read(localeProvider.notifier);

      // التحقق من علم اللغة الافتراضية (العربية)
      expect(notifier.getCurrentLanguageFlag(), '🇸🇦');

      // تغيير اللغة إلى الفرنسية
      await notifier.changeLocale('fr');

      // التحقق من علم اللغة بعد التغيير
      expect(notifier.getCurrentLanguageFlag(), '🇫🇷');
    });

    test('يجب أن تعيد getSupportedLanguages قائمة اللغات المدعومة', () {
      final notifier = container.read(localeProvider.notifier);
      final languages = notifier.getSupportedLanguages();

      // التحقق من عدد اللغات المدعومة
      expect(languages.length, 5);

      // التحقق من وجود اللغات المطلوبة
      expect(languages.any((lang) => lang['code'] == 'ar'), true);
      expect(languages.any((lang) => lang['code'] == 'en'), true);
      expect(languages.any((lang) => lang['code'] == 'fr'), true);
      expect(languages.any((lang) => lang['code'] == 'tr'), true);
      expect(languages.any((lang) => lang['code'] == 'ur'), true);
    });
  });
}

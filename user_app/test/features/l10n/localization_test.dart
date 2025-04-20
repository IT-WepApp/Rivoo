import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/l10n/l10n.dart';

void main() {
  testWidgets('Localization should support multiple languages', (WidgetTester tester) async {
    // اختبار اللغة العربية
    await _pumpLocalizedWidget(tester, const Locale('ar'));
    expect(AppLocalizations.of(tester.element(find.byType(TestLocalizations)))!.language, 'العربية');
    
    // اختبار اللغة الإنجليزية
    await _pumpLocalizedWidget(tester, const Locale('en'));
    expect(AppLocalizations.of(tester.element(find.byType(TestLocalizations)))!.language, 'English');
    
    // اختبار اللغة الفرنسية
    await _pumpLocalizedWidget(tester, const Locale('fr'));
    expect(AppLocalizations.of(tester.element(find.byType(TestLocalizations)))!.language, 'Français');
    
    // اختبار اللغة التركية
    await _pumpLocalizedWidget(tester, const Locale('tr'));
    expect(AppLocalizations.of(tester.element(find.byType(TestLocalizations)))!.language, 'Türkçe');
    
    // اختبار اللغة الأردية
    await _pumpLocalizedWidget(tester, const Locale('ur'));
    expect(AppLocalizations.of(tester.element(find.byType(TestLocalizations)))!.language, 'اردو');
  });

  test('L10n should provide supported locales', () {
    // التحقق من وجود اللغات المدعومة
    expect(L10n.supportedLocales.length, 5);
    expect(L10n.supportedLocales, contains(const Locale('ar')));
    expect(L10n.supportedLocales, contains(const Locale('en')));
    expect(L10n.supportedLocales, contains(const Locale('fr')));
    expect(L10n.supportedLocales, contains(const Locale('tr')));
    expect(L10n.supportedLocales, contains(const Locale('ur')));
  });

  test('L10n should provide language names', () {
    // التحقق من أسماء اللغات
    expect(L10n.getLanguageName('ar'), 'العربية');
    expect(L10n.getLanguageName('en'), 'English');
    expect(L10n.getLanguageName('fr'), 'Français');
    expect(L10n.getLanguageName('tr'), 'Türkçe');
    expect(L10n.getLanguageName('ur'), 'اردو');
    expect(L10n.getLanguageName('unknown'), isNotNull); // يجب أن يعيد قيمة افتراضية
  });
}

// مكون اختبار للترجمة
class TestLocalizations extends StatelessWidget {
  const TestLocalizations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.language);
  }
}

// دالة مساعدة لبناء المكون مع إعدادات اللغة
Future<void> _pumpLocalizedWidget(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: TestLocalizations(),
        ),
      ),
    ),
  );
}

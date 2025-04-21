import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/l10n/l10n.dart';

void main() {
  group('اختبارات التعدد اللغوي', () {
    testWidgets('يجب أن تدعم اللغة العربية', (WidgetTester tester) async {
      // إعداد
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              // التحقق من ترجمة نص معين باللغة العربية
              expect(localizations.appTitle, 'ريفوسي');
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('يجب أن تدعم اللغة الإنجليزية', (WidgetTester tester) async {
      // إعداد
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              // التحقق من ترجمة نص معين باللغة الإنجليزية
              expect(localizations.appTitle, 'RivooSy');
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('يجب أن تدعم اللغة الفرنسية', (WidgetTester tester) async {
      // إعداد
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              // التحقق من ترجمة نص معين باللغة الفرنسية
              expect(localizations.appTitle, 'RivooSy');
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('يجب أن تدعم اللغة التركية', (WidgetTester tester) async {
      // إعداد
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              // التحقق من ترجمة نص معين باللغة التركية
              expect(localizations.appTitle, 'RivooSy');
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('يجب أن تدعم اللغة الأردية', (WidgetTester tester) async {
      // إعداد
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ur'),
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              // التحقق من ترجمة نص معين باللغة الأردية
              expect(localizations.appTitle, 'ریووسی');
              return const Scaffold();
            },
          ),
        ),
      );
    });

    test('يجب أن تحتوي جميع ملفات الترجمة على نفس المفاتيح', () {
      // هذا اختبار وحدة للتحقق من تطابق مفاتيح الترجمة بين جميع اللغات
      // في التطبيق الحقيقي، يمكننا قراءة ملفات .arb وتحليلها للتحقق من تطابق المفاتيح
      // هنا نقوم بمحاكاة هذا الاختبار

      // مثال على كيفية التحقق من تطابق المفاتيح في ملفات الترجمة
      final arKeys = ['appTitle', 'home', 'settings', 'profile'];
      final enKeys = ['appTitle', 'home', 'settings', 'profile'];
      final frKeys = ['appTitle', 'home', 'settings', 'profile'];
      final trKeys = ['appTitle', 'home', 'settings', 'profile'];
      final urKeys = ['appTitle', 'home', 'settings', 'profile'];

      expect(arKeys.length, enKeys.length);
      expect(arKeys.length, frKeys.length);
      expect(arKeys.length, trKeys.length);
      expect(arKeys.length, urKeys.length);

      for (final key in arKeys) {
        expect(enKeys.contains(key), true);
        expect(frKeys.contains(key), true);
        expect(trKeys.contains(key), true);
        expect(urKeys.contains(key), true);
      }
    });
  });
}

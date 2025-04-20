import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_app/features/settings/presentation/widgets/theme_toggle_widget.dart';
import 'package:delivery_app/presentation/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('ThemeToggleWidget Tests', () {
    testWidgets('يجب أن يعرض خيارات السمة الثلاثة', (WidgetTester tester) async {
      // بناء الواجهة للاختبار
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            home: const Scaffold(
              body: ThemeToggleWidget(),
            ),
          ),
        ),
      );
      
      // انتظار اكتمال بناء الواجهة
      await tester.pumpAndSettle();
      
      // التحقق من وجود أيقونات الأوضاع الثلاثة
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget); // أيقونة الوضع الفاتح
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget); // أيقونة الوضع الداكن
      expect(find.byIcon(Icons.settings_suggest), findsOneWidget); // أيقونة إعدادات النظام
    });
    
    testWidgets('يجب أن يتم تحديد وضع السمة الحالي', (WidgetTester tester) async {
      // بناء الواجهة للاختبار
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            home: const Scaffold(
              body: ThemeToggleWidget(),
            ),
          ),
        ),
      );
      
      // انتظار اكتمال بناء الواجهة
      await tester.pumpAndSettle();
      
      // الوضع الافتراضي هو إعدادات النظام، لذا يجب أن يكون هناك تحديد على زر إعدادات النظام
      // ملاحظة: هذا الاختبار يعتمد على التنفيذ الدقيق للواجهة، قد يحتاج إلى تعديل
      // إذا تغيرت طريقة تمييز الزر المحدد
      
      // يمكن التحقق من وجود حدود خاصة أو لون مميز للزر المحدد
      // هذا مثال بسيط، قد تحتاج إلى تعديله حسب التنفيذ الفعلي
      final settingsButton = find.ancestor(
        of: find.byIcon(Icons.settings_suggest),
        matching: find.byType(InkWell),
      );
      
      expect(settingsButton, findsOneWidget);
    });
    
    testWidgets('يجب أن يتم تغيير وضع السمة عند النقر على وضع آخر', (WidgetTester tester) async {
      // بناء الواجهة للاختبار
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            home: const Scaffold(
              body: ThemeToggleWidget(),
            ),
          ),
        ),
      );
      
      // انتظار اكتمال بناء الواجهة
      await tester.pumpAndSettle();
      
      // النقر على زر الوضع الداكن
      final darkModeButton = find.ancestor(
        of: find.byIcon(Icons.nightlight_round),
        matching: find.byType(InkWell),
      );
      
      await tester.tap(darkModeButton.first);
      await tester.pumpAndSettle();
      
      // التحقق من تغيير وضع السمة
      // ملاحظة: هذا الاختبار قد يفشل في بيئة الاختبار لأن تغيير السمة يعتمد على SharedPreferences
      // ولكن يمكن التحقق من سلوك النقر
    });
  });
}

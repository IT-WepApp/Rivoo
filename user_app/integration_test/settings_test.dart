import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/auth/presentation/screens/register_screen.dart';
import 'package:user_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:user_app/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:user_app/features/settings/presentation/screens/theme_settings_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('اختبار إعدادات التطبيق', () {
    testWidgets('تسجيل حساب جديد، تغيير اللغة، تغيير السمة',
        (WidgetTester tester) async {
      // تشغيل التطبيق
      app.main();
      await tester.pumpAndSettle();

      // التحقق من ظهور شاشة تسجيل الدخول
      expect(find.byType(LoginScreen), findsOneWidget);

      // الانتقال إلى شاشة إنشاء حساب جديد
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة إنشاء حساب جديد
      expect(find.byType(RegisterScreen), findsOneWidget);

      // إدخال بيانات الحساب الجديد
      await tester.enterText(
          find.byKey(const Key('name_field')), 'مستخدم جديد');
      await tester.enterText(
          find.byKey(const Key('email_field')), 'new_user@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.pumpAndSettle();

      // النقر على زر إنشاء الحساب
      await tester.tap(find.byKey(const Key('create_account_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // الانتقال إلى شاشة الإعدادات
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة الإعدادات
      expect(find.byType(SettingsScreen), findsOneWidget);

      // الانتقال إلى إعدادات اللغة
      await tester.tap(find.text('إعدادات اللغة'));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة إعدادات اللغة
      expect(find.byType(LanguageSettingsScreen), findsOneWidget);

      // اختيار اللغة الإنجليزية
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // التحقق من تغيير اللغة
      expect(find.text('Language Settings'), findsOneWidget);

      // العودة إلى شاشة الإعدادات
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة الإعدادات باللغة الإنجليزية
      expect(find.text('Settings'), findsOneWidget);

      // الانتقال إلى إعدادات السمة
      await tester.tap(find.text('Theme Settings'));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة إعدادات السمة
      expect(find.byType(ThemeSettingsScreen), findsOneWidget);

      // اختيار السمة الداكنة
      await tester.tap(find.text('Dark Theme'));
      await tester.pumpAndSettle();

      // التحقق من تغيير السمة
      final darkThemeSwitch =
          find.byType(Switch).evaluate().first.widget as Switch;
      expect(darkThemeSwitch.value, true);

      // العودة إلى شاشة الإعدادات
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // العودة إلى الشاشة الرئيسية
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });
  });
}

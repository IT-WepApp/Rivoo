import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/home/presentation/screens/home_screen.dart';
import 'package:user_app/features/order_tracking/presentation/pages/order_tracking_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('اختبار تتبع الطلبات', () {
    testWidgets('تسجيل الدخول، عرض الطلبات، تتبع حالة الطلب',
        (WidgetTester tester) async {
      // تشغيل التطبيق
      app.main();
      await tester.pumpAndSettle();

      // التحقق من ظهور شاشة تسجيل الدخول
      expect(find.byType(LoginScreen), findsOneWidget);

      // إدخال بيانات تسجيل الدخول
      await tester.enterText(
          find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      // النقر على زر تسجيل الدخول
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // التحقق من الانتقال إلى الشاشة الرئيسية
      expect(find.byType(HomeScreen), findsOneWidget);

      // الانتقال إلى شاشة الطلبات
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();

      // التحقق من وجود قائمة الطلبات
      expect(find.byType(ListView), findsOneWidget);

      // النقر على أول طلب في القائمة
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة تفاصيل الطلب
      expect(find.text('تفاصيل الطلب'), findsOneWidget);

      // النقر على زر تتبع الطلب
      await tester.tap(find.byKey(const Key('track_order_button')));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة تتبع الطلب
      expect(find.byType(OrderTrackingPage), findsOneWidget);

      // التحقق من وجود خريطة التتبع
      expect(find.byKey(const Key('tracking_map')), findsOneWidget);

      // التحقق من وجود معلومات حالة الطلب
      expect(find.byKey(const Key('order_status')), findsOneWidget);

      // التحقق من وجود معلومات التوصيل المتوقع
      expect(find.byKey(const Key('estimated_delivery')), findsOneWidget);

      // العودة إلى شاشة تفاصيل الطلب
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // العودة إلى قائمة الطلبات
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // العودة إلى الشاشة الرئيسية
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // التحقق من العودة إلى الشاشة الرئيسية
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

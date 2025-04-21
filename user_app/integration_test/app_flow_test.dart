import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/home/presentation/screens/home_screen.dart';
import 'package:user_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:user_app/features/payment/presentation/screens/payment_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('تدفق المستخدم الكامل', () {
    testWidgets('تسجيل الدخول، تصفح المنتجات، إضافة إلى السلة، الدفع',
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

      // التحقق من وجود منتجات في الشاشة الرئيسية
      expect(find.byType(Card), findsWidgets);

      // النقر على أول منتج
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة تفاصيل المنتج
      expect(find.byType(ProductDetailsScreen), findsOneWidget);

      // النقر على زر إضافة إلى السلة
      await tester.tap(find.byKey(const Key('add_to_cart_button')));
      await tester.pumpAndSettle();

      // التحقق من ظهور رسالة تأكيد الإضافة إلى السلة
      expect(find.text('تمت الإضافة إلى السلة'), findsOneWidget);

      // الانتقال إلى شاشة السلة
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة السلة
      expect(find.byType(CartScreen), findsOneWidget);

      // التحقق من وجود المنتج في السلة
      expect(find.byType(ListTile), findsWidgets);

      // النقر على زر متابعة الدفع
      await tester.tap(find.byKey(const Key('checkout_button')));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة الدفع
      expect(find.byType(PaymentScreen), findsOneWidget);

      // اختيار طريقة الدفع
      await tester.tap(find.text('بطاقة ائتمان').first);
      await tester.pumpAndSettle();

      // إدخال بيانات البطاقة
      await tester.enterText(
          find.byKey(const Key('card_number_field')), '4242424242424242');
      await tester.enterText(
          find.byKey(const Key('expiry_date_field')), '12/25');
      await tester.enterText(find.byKey(const Key('cvv_field')), '123');
      await tester.enterText(
          find.byKey(const Key('card_holder_field')), 'محمد أحمد');
      await tester.pumpAndSettle();

      // النقر على زر إتمام الدفع
      await tester.tap(find.byKey(const Key('complete_payment_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // التحقق من ظهور رسالة نجاح الدفع
      expect(find.text('تم الدفع بنجاح'), findsOneWidget);

      // النقر على زر العودة إلى الصفحة الرئيسية
      await tester.tap(find.byKey(const Key('back_to_home_button')));
      await tester.pumpAndSettle();

      // التحقق من العودة إلى الشاشة الرئيسية
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

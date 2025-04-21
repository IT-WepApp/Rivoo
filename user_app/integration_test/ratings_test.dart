import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/home/presentation/screens/home_screen.dart';
import 'package:user_app/features/ratings/presentation/screens/product_reviews_screen.dart';
import 'package:user_app/features/ratings/presentation/screens/add_review_screen.dart';
import 'package:user_app/features/products/presentation/screens/product_details_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('اختبار نظام التقييمات والمراجعات', () {
    testWidgets('تسجيل الدخول، عرض تفاصيل منتج، إضافة تقييم ومراجعة',
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

      // النقر على أول منتج
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة تفاصيل المنتج
      expect(find.byType(ProductDetailsScreen), findsOneWidget);

      // النقر على زر عرض جميع التقييمات
      await tester.tap(find.byKey(const Key('view_all_reviews_button')));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة تقييمات المنتج
      expect(find.byType(ProductReviewsScreen), findsOneWidget);

      // النقر على زر إضافة تقييم
      await tester.tap(find.byKey(const Key('add_review_button')));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة إضافة تقييم
      expect(find.byType(AddReviewScreen), findsOneWidget);

      // تحديد عدد النجوم
      await tester.tap(find.byKey(const Key('star_4')));
      await tester.pumpAndSettle();

      // إدخال نص المراجعة
      await tester.enterText(find.byKey(const Key('review_text_field')),
          'منتج رائع وذو جودة عالية. أنصح به بشدة لمن يبحث عن منتج موثوق.');
      await tester.pumpAndSettle();

      // النقر على زر إرسال التقييم
      await tester.tap(find.byKey(const Key('submit_review_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // التحقق من العودة إلى شاشة تقييمات المنتج
      expect(find.byType(ProductReviewsScreen), findsOneWidget);

      // التحقق من ظهور التقييم الجديد في القائمة
      expect(
          find.text(
              'منتج رائع وذو جودة عالية. أنصح به بشدة لمن يبحث عن منتج موثوق.'),
          findsOneWidget);

      // العودة إلى شاشة تفاصيل المنتج
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // التحقق من العودة إلى شاشة تفاصيل المنتج
      expect(find.byType(ProductDetailsScreen), findsOneWidget);

      // التحقق من تحديث متوسط التقييم
      expect(find.byKey(const Key('average_rating')), findsOneWidget);
    });
  });
}

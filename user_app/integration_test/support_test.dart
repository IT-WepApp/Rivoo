import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/features/auth/presentation/screens/login_screen.dart';
import 'package:user_app/features/home/presentation/screens/home_screen.dart';
import 'package:user_app/features/support/presentation/screens/support_tickets_screen.dart';
import 'package:user_app/features/support/presentation/screens/create_ticket_screen.dart';
import 'package:user_app/features/support/presentation/screens/ticket_details_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('اختبار نظام الدعم الفني', () {
    testWidgets('تسجيل الدخول، إنشاء تذكرة دعم فني، متابعة التذكرة', (WidgetTester tester) async {
      // تشغيل التطبيق
      app.main();
      await tester.pumpAndSettle();

      // التحقق من ظهور شاشة تسجيل الدخول
      expect(find.byType(LoginScreen), findsOneWidget);

      // إدخال بيانات تسجيل الدخول
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      // النقر على زر تسجيل الدخول
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // التحقق من الانتقال إلى الشاشة الرئيسية
      expect(find.byType(HomeScreen), findsOneWidget);

      // الانتقال إلى شاشة الدعم الفني
      await tester.tap(find.byIcon(Icons.support));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة الدعم الفني
      expect(find.byType(SupportTicketsScreen), findsOneWidget);

      // النقر على زر إنشاء تذكرة جديدة
      await tester.tap(find.byKey(const Key('create_ticket_button')));
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة إنشاء تذكرة جديدة
      expect(find.byType(CreateTicketScreen), findsOneWidget);

      // إدخال بيانات التذكرة
      await tester.enterText(find.byKey(const Key('ticket_subject_field')), 'مشكلة في الدفع');
      await tester.enterText(
        find.byKey(const Key('ticket_description_field')),
        'لم أتمكن من إتمام عملية الدفع باستخدام بطاقة الائتمان الخاصة بي. تظهر رسالة خطأ عند محاولة الدفع.'
      );
      await tester.pumpAndSettle();

      // اختيار نوع المشكلة
      await tester.tap(find.byKey(const Key('ticket_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مشكلة في الدفع').last);
      await tester.pumpAndSettle();

      // اختيار أولوية المشكلة
      await tester.tap(find.byKey(const Key('ticket_priority_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عالية').last);
      await tester.pumpAndSettle();

      // النقر على زر إرسال التذكرة
      await tester.tap(find.byKey(const Key('submit_ticket_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // التحقق من العودة إلى شاشة الدعم الفني
      expect(find.byType(SupportTicketsScreen), findsOneWidget);

      // التحقق من ظهور التذكرة الجديدة في القائمة
      expect(find.text('مشكلة في الدفع'), findsOneWidget);

      // النقر على التذكرة للاطلاع على تفاصيلها
      await tester.tap(find.text('مشكلة في الدفع').first);
      await tester.pumpAndSettle();

      // التحقق من الانتقال إلى شاشة تفاصيل التذكرة
      expect(find.byType(TicketDetailsScreen), findsOneWidget);

      // التحقق من ظهور تفاصيل التذكرة
      expect(find.text('مشكلة في الدفع'), findsOneWidget);
      expect(find.text('لم أتمكن من إتمام عملية الدفع باستخدام بطاقة الائتمان الخاصة بي. تظهر رسالة خطأ عند محاولة الدفع.'), findsOneWidget);

      // إضافة رد على التذكرة
      await tester.enterText(
        find.byKey(const Key('reply_message_field')),
        'هل يمكنك توضيح رسالة الخطأ التي تظهر لك؟'
      );
      await tester.pumpAndSettle();

      // إرسال الرد
      await tester.tap(find.byKey(const Key('send_reply_button')));
      await tester.pumpAndSettle();

      // التحقق من ظهور الرد في المحادثة
      expect(find.text('هل يمكنك توضيح رسالة الخطأ التي تظهر لك؟'), findsOneWidget);

      // العودة إلى شاشة الدعم الفني
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // التحقق من العودة إلى شاشة الدعم الفني
      expect(find.byType(SupportTicketsScreen), findsOneWidget);
    });
  });
}

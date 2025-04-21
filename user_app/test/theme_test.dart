import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/theme/app_theme.dart';
import 'package:user_app/theme/app_widgets.dart';

void main() {
  group('اختبارات نظام التصميم الموحد', () {
    testWidgets('يجب أن يعرض AppButton بشكل صحيح', (WidgetTester tester) async {
      bool buttonPressed = false;

      // بناء واجهة المستخدم
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: AppWidgets.AppButton(
                text: 'زر الاختبار',
                onPressed: () {
                  buttonPressed = true;
                },
              ),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('زر الاختبار'), findsOneWidget);

      // النقر على الزر
      await tester.tap(find.text('زر الاختبار'));
      await tester.pump();

      // التحقق من تنفيذ الإجراء
      expect(buttonPressed, true);
    });

    testWidgets('يجب أن يعرض AppTextField بشكل صحيح',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      // بناء واجهة المستخدم
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: AppWidgets.AppTextField(
                controller: controller,
                labelText: 'حقل النص',
                hintText: 'أدخل النص هنا',
              ),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('حقل النص'), findsOneWidget);
      expect(find.text('أدخل النص هنا'), findsOneWidget);

      // إدخال نص
      await tester.enterText(find.byType(TextFormField), 'نص الاختبار');

      // التحقق من تحديث النص
      expect(controller.text, 'نص الاختبار');
    });

    testWidgets('يجب أن يعرض AppCard بشكل صحيح', (WidgetTester tester) async {
      bool cardPressed = false;

      // بناء واجهة المستخدم
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: AppWidgets.AppCard(
                onTap: () {
                  cardPressed = true;
                },
                child: const Text('محتوى البطاقة'),
              ),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('محتوى البطاقة'), findsOneWidget);

      // النقر على البطاقة
      await tester.tap(find.text('محتوى البطاقة'));
      await tester.pump();

      // التحقق من تنفيذ الإجراء
      expect(cardPressed, true);
    });

    testWidgets('يجب أن يعرض AppEmptyList بشكل صحيح',
        (WidgetTester tester) async {
      bool actionPressed = false;

      // بناء واجهة المستخدم
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: AppWidgets.AppEmptyList(
                message: 'القائمة فارغة',
                actionLabel: 'إضافة عنصر',
                onAction: () {
                  actionPressed = true;
                },
              ),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('القائمة فارغة'), findsOneWidget);
      expect(find.text('إضافة عنصر'), findsOneWidget);

      // النقر على زر الإجراء
      await tester.tap(find.text('إضافة عنصر'));
      await tester.pump();

      // التحقق من تنفيذ الإجراء
      expect(actionPressed, true);
    });
  });

  group('اختبارات سمات التطبيق', () {
    test('يجب أن تكون سمة التطبيق الفاتحة صحيحة', () {
      final lightTheme = AppTheme.light;

      // التحقق من ألوان السمة
      expect(lightTheme.colorScheme.primary, AppColors.primary);
      expect(lightTheme.colorScheme.onPrimary, AppColors.textOnPrimary);
      expect(lightTheme.colorScheme.surface, AppColors.surface);
      expect(lightTheme.colorScheme.onSurface, AppColors.textPrimary);
    });

    test('يجب أن تكون سمة التطبيق الداكنة صحيحة', () {
      final darkTheme = AppTheme.dark;

      // التحقق من ألوان السمة
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.surface, AppColors.darkSurface);
      expect(darkTheme.colorScheme.onSurface, AppColors.darkTextPrimary);
    });

    test('يجب أن تعيد getTheme السمة الصحيحة بناءً على الوضع', () {
      // الوضع الفاتح
      final lightTheme = AppTheme.getTheme(false);
      expect(lightTheme.colorScheme.brightness, Brightness.light);

      // الوضع الداكن
      final darkTheme = AppTheme.getTheme(true);
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
    });
  });
}

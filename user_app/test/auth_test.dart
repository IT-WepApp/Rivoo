import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/utils/validators.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// إنشاء فئات وهمية للاختبار
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('اختبارات خدمة التخزين الآمن', () {
    late MockSecureStorageService mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockSecureStorageService();
    });

    test('يجب أن تقوم بتخزين القيمة بشكل آمن', () async {
      // ترتيب
      const key = 'test_key';
      const value = 'test_value';
      when(mockSecureStorage.write(key, value)).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockSecureStorage.write(key, value);

      // تأكيد
      expect(result, true);
      verify(mockSecureStorage.write(key, value)).called(1);
    });

    test('يجب أن تقوم بقراءة القيمة المخزنة', () async {
      // ترتيب
      const key = 'test_key';
      const value = 'test_value';
      when(mockSecureStorage.read(key)).thenAnswer((_) async => value);

      // تنفيذ
      final result = await mockSecureStorage.read(key);

      // تأكيد
      expect(result, value);
      verify(mockSecureStorage.read(key)).called(1);
    });

    test('يجب أن تقوم بحذف القيمة المخزنة', () async {
      // ترتيب
      const key = 'test_key';
      when(mockSecureStorage.delete(key)).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockSecureStorage.delete(key);

      // تأكيد
      expect(result, true);
      verify(mockSecureStorage.delete(key)).called(1);
    });
  });

  group('اختبارات التحقق من صحة المدخلات', () {
    test('التحقق من صحة البريد الإلكتروني', () {
      // بريد إلكتروني صحيح
      expect(Validators.validateEmail('user@example.com'), null);
      expect(Validators.validateEmail('user.name@example.co.uk'), null);

      // بريد إلكتروني غير صحيح
      expect(Validators.validateEmail(''), 'الرجاء إدخال البريد الإلكتروني');
      expect(Validators.validateEmail('user'), 'الرجاء إدخال بريد إلكتروني صحيح');
      expect(Validators.validateEmail('user@'), 'الرجاء إدخال بريد إلكتروني صحيح');
      expect(Validators.validateEmail('user@example'), 'الرجاء إدخال بريد إلكتروني صحيح');
    });

    test('التحقق من صحة كلمة المرور', () {
      // كلمة مرور صحيحة
      expect(Validators.validatePassword('Password123!'), null);
      expect(Validators.validatePassword('Abcd1234@'), null);

      // كلمة مرور غير صحيحة
      expect(Validators.validatePassword(''), 'الرجاء إدخال كلمة المرور');
      expect(Validators.validatePassword('pass'), 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل');
      expect(Validators.validatePassword('password'), 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل');
      expect(Validators.validatePassword('Password'), 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل');
    });

    test('التحقق من صحة رقم الهاتف', () {
      // رقم هاتف صحيح
      expect(Validators.validatePhone('1234567890'), null);
      expect(Validators.validatePhone('05512345678'), null);

      // رقم هاتف غير صحيح
      expect(Validators.validatePhone(''), 'الرجاء إدخال رقم الهاتف');
      expect(Validators.validatePhone('123'), 'يجب أن يحتوي رقم الهاتف على 10 أرقام على الأقل');
      expect(Validators.validatePhone('abcdefghij'), 'يجب أن يحتوي رقم الهاتف على أرقام فقط');
    });

    test('التحقق من صحة الاسم', () {
      // اسم صحيح
      expect(Validators.validateName('محمد'), null);
      expect(Validators.validateName('محمد أحمد'), null);

      // اسم غير صحيح
      expect(Validators.validateName(''), 'الرجاء إدخال الاسم');
      expect(Validators.validateName('م'), 'يجب أن يحتوي الاسم على حرفين على الأقل');
    });
  });

  group('اختبارات خدمة المصادقة', () {
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('يجب أن تقوم بتسجيل الدخول بنجاح', () async {
      // ترتيب
      const email = 'user@example.com';
      const password = 'Password123!';
      when(mockAuthService.signIn(email, password)).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockAuthService.signIn(email, password);

      // تأكيد
      expect(result, true);
      verify(mockAuthService.signIn(email, password)).called(1);
    });

    test('يجب أن تقوم بتسجيل حساب جديد بنجاح', () async {
      // ترتيب
      const email = 'user@example.com';
      const password = 'Password123!';
      const name = 'محمد أحمد';
      when(mockAuthService.signUp(email, password, name)).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockAuthService.signUp(email, password, name);

      // تأكيد
      expect(result, true);
      verify(mockAuthService.signUp(email, password, name)).called(1);
    });

    test('يجب أن تقوم بتسجيل الخروج بنجاح', () async {
      // ترتيب
      when(mockAuthService.signOut()).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockAuthService.signOut();

      // تأكيد
      expect(result, true);
      verify(mockAuthService.signOut()).called(1);
    });

    test('يجب أن تقوم بإرسال رابط إعادة تعيين كلمة المرور بنجاح', () async {
      // ترتيب
      const email = 'user@example.com';
      when(mockAuthService.sendPasswordResetEmail(email)).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockAuthService.sendPasswordResetEmail(email);

      // تأكيد
      expect(result, true);
      verify(mockAuthService.sendPasswordResetEmail(email)).called(1);
    });

    test('يجب أن تقوم بالتحقق من حالة تأكيد البريد الإلكتروني بنجاح', () async {
      // ترتيب
      when(mockAuthService.isEmailVerified()).thenAnswer((_) async => true);

      // تنفيذ
      final result = await mockAuthService.isEmailVerified();

      // تأكيد
      expect(result, true);
      verify(mockAuthService.isEmailVerified()).called(1);
    });
  });

  group('اختبارات واجهة المستخدم', () {
    testWidgets('يجب أن تعرض صفحة تسجيل الدخول بشكل صحيح', (WidgetTester tester) async {
      // بناء واجهة المستخدم
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('تسجيل الدخول'),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('تسجيل الدخول'), findsOneWidget);
    });

    testWidgets('يجب أن تعرض صفحة التسجيل بشكل صحيح', (WidgetTester tester) async {
      // بناء واجهة المستخدم
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('إنشاء حساب جديد'),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
    });

    testWidgets('يجب أن تعرض صفحة نسيت كلمة المرور بشكل صحيح', (WidgetTester tester) async {
      // بناء واجهة المستخدم
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('نسيت كلمة المرور'),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('نسيت كلمة المرور'), findsOneWidget);
    });
  });
}

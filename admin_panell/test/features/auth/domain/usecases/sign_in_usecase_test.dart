import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:admin_panell/features/auth/domain/repositories/auth_repository.dart';
import 'package:admin_panell/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:admin_panell/features/auth/domain/entities/user_entity.dart';

// توليد الملفات المطلوبة لـ Mockito
@GenerateMocks([AuthRepository])
import 'sign_in_usecase_test.mocks.dart';

void main() {
  late SignInUseCase signInUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockAuthRepository);
  });

  final testEmail = 'test@example.com';
  final testPassword = 'password123';
  final testUser = UserEntity(
    id: '1',
    name: 'Test User',
    email: testEmail,
    role: 'admin',
  );

  test('يجب أن يقوم SignInUseCase باستدعاء مستودع المصادقة ويعيد المستخدم بنجاح', () async {
    // ترتيب
    when(mockAuthRepository.signIn(testEmail, testPassword))
        .thenAnswer((_) async => testUser);

    // تنفيذ
    final result = await signInUseCase.execute(testEmail, testPassword);

    // تحقق
    expect(result, equals(testUser));
    verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('يجب أن يعيد SignInUseCase الخطأ عندما يفشل تسجيل الدخول', () async {
    // ترتيب
    final testException = Exception('فشل تسجيل الدخول');
    when(mockAuthRepository.signIn(testEmail, testPassword))
        .thenThrow(testException);

    // تنفيذ وتحقق
    expect(
      () => signInUseCase.execute(testEmail, testPassword),
      throwsA(equals(testException)),
    );
    verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('يجب أن يرفض SignInUseCase البريد الإلكتروني غير الصالح', () async {
    // تنفيذ وتحقق
    expect(
      () => signInUseCase.execute('invalid-email', testPassword),
      throwsA(isA<Exception>()),
    );
    
    // التأكد من عدم استدعاء المستودع
    verifyZeroInteractions(mockAuthRepository);
  });

  test('يجب أن يرفض SignInUseCase كلمة المرور القصيرة', () async {
    // تنفيذ وتحقق
    expect(
      () => signInUseCase.execute(testEmail, '12345'),
      throwsA(isA<Exception>()),
    );
    
    // التأكد من عدم استدعاء المستودع
    verifyZeroInteractions(mockAuthRepository);
  });
}

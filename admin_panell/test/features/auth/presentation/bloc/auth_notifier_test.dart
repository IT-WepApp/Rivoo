import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_panell/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/is_signed_in_usecase.dart';
import 'package:admin_panell/features/auth/domain/entities/user_entity.dart';
import 'package:admin_panell/features/auth/presentation/bloc/auth_notifier.dart';

// توليد الملفات المطلوبة لـ Mockito
@GenerateMocks([
  SignInUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
  IsSignedInUseCase
])
import 'auth_notifier_test.mocks.dart';

void main() {
  late AuthNotifier authNotifier;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsSignedInUseCase mockIsSignedInUseCase;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockIsSignedInUseCase = MockIsSignedInUseCase();

    authNotifier = AuthNotifier(
      signInUseCase: mockSignInUseCase,
      signOutUseCase: mockSignOutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      isSignedInUseCase: mockIsSignedInUseCase,
    );
  });

  final testEmail = 'test@example.com';
  final testPassword = 'password123';
  final testUser = UserEntity(
    id: '1',
    name: 'Test User',
    email: testEmail,
    role: 'admin',
  );

  group('handleSignIn', () {
    test('يجب أن يتغير الحالة إلى AuthAuthenticated عند نجاح تسجيل الدخول', () async {
      // ترتيب
      when(mockSignInUseCase.execute(testEmail, testPassword))
          .thenAnswer((_) async => testUser);

      // تنفيذ
      await authNotifier.handleEvent(SignInEvent(
        email: testEmail,
        password: testPassword,
      ));

      // تحقق
      expect(authNotifier.state, isA<AuthAuthenticated>());
      final state = authNotifier.state as AuthAuthenticated;
      expect(state.user, equals(testUser));
      verify(mockSignInUseCase.execute(testEmail, testPassword)).called(1);
    });

    test('يجب أن يتغير الحالة إلى AuthError عند فشل تسجيل الدخول', () async {
      // ترتيب
      final testException = Exception('فشل تسجيل الدخول');
      when(mockSignInUseCase.execute(testEmail, testPassword))
          .thenThrow(testException);

      // تنفيذ
      await authNotifier.handleEvent(SignInEvent(
        email: testEmail,
        password: testPassword,
      ));

      // تحقق
      expect(authNotifier.state, isA<AuthError>());
      final state = authNotifier.state as AuthError;
      expect(state.message, equals(testException.toString()));
      verify(mockSignInUseCase.execute(testEmail, testPassword)).called(1);
    });
  });

  group('handleSignOut', () {
    test('يجب أن يتغير الحالة إلى AuthUnauthenticated عند نجاح تسجيل الخروج', () async {
      // ترتيب
      when(mockSignOutUseCase.execute())
          .thenAnswer((_) async => null);

      // تنفيذ
      await authNotifier.handleEvent(SignOutEvent());

      // تحقق
      expect(authNotifier.state, isA<AuthUnauthenticated>());
      verify(mockSignOutUseCase.execute()).called(1);
    });

    test('يجب أن يتغير الحالة إلى AuthError عند فشل تسجيل الخروج', () async {
      // ترتيب
      final testException = Exception('فشل تسجيل الخروج');
      when(mockSignOutUseCase.execute())
          .thenThrow(testException);

      // تنفيذ
      await authNotifier.handleEvent(SignOutEvent());

      // تحقق
      expect(authNotifier.state, isA<AuthError>());
      final state = authNotifier.state as AuthError;
      expect(state.message, equals(testException.toString()));
      verify(mockSignOutUseCase.execute()).called(1);
    });
  });

  group('handleCheckAuthStatus', () {
    test('يجب أن يتغير الحالة إلى AuthAuthenticated عندما يكون المستخدم مسجل الدخول', () async {
      // ترتيب
      when(mockIsSignedInUseCase.execute())
          .thenAnswer((_) async => true);
      when(mockGetCurrentUserUseCase.execute())
          .thenAnswer((_) async => testUser);

      // تنفيذ
      await authNotifier.handleEvent(CheckAuthStatusEvent());

      // تحقق
      expect(authNotifier.state, isA<AuthAuthenticated>());
      final state = authNotifier.state as AuthAuthenticated;
      expect(state.user, equals(testUser));
      verify(mockIsSignedInUseCase.execute()).called(1);
      verify(mockGetCurrentUserUseCase.execute()).called(1);
    });

    test('يجب أن يتغير الحالة إلى AuthUnauthenticated عندما لا يكون المستخدم مسجل الدخول', () async {
      // ترتيب
      when(mockIsSignedInUseCase.execute())
          .thenAnswer((_) async => false);

      // تنفيذ
      await authNotifier.handleEvent(CheckAuthStatusEvent());

      // تحقق
      expect(authNotifier.state, isA<AuthUnauthenticated>());
      verify(mockIsSignedInUseCase.execute()).called(1);
      verifyNever(mockGetCurrentUserUseCase.execute());
    });
  });
}

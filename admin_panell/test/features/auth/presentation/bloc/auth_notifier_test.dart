import 'package:admin_panell/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/is_signed_in_usecase.dart';
import 'package:admin_panell/features/auth/application/auth_notifier.dart';
import 'package:admin_panell/features/auth/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@GenerateMocks([
  SignInUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
  IsSignedInUseCase,
])
void main() {
  late MockSignInUseCase mockSignInUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsSignedInUseCase mockIsSignedInUseCase;
  late AuthNotifier authNotifier;

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

  group('تسجيل الدخول', () {
    const email = 'test@example.com';
    const password = 'password123';
    final user = User(id: '1', name: 'Test User', email: email);

    test('يجب أن يقوم بتسجيل الدخول بنجاح', () async {
      // ترتيب
      when(mockSignInUseCase.execute(email: email, password: password))
          .thenAnswer((_) async => user);

      // تنفيذ
      await authNotifier.signIn(email: email, password: password);

      // تحقق
      verify(mockSignInUseCase.execute(email: email, password: password)).called(1);
      expect(authNotifier.state.user, user);
      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, null);
    });

    test('يجب أن يعالج خطأ تسجيل الدخول', () async {
      // ترتيب
      final exception = Exception('فشل تسجيل الدخول');
      when(mockSignInUseCase.execute(email: email, password: password))
          .thenThrow(exception);

      // تنفيذ
      await authNotifier.signIn(email: email, password: password);

      // تحقق
      verify(mockSignInUseCase.execute(email: email, password: password)).called(1);
      expect(authNotifier.state.user, null);
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, isNotNull);
    });
  });

  group('تسجيل الخروج', () {
    test('يجب أن يقوم بتسجيل الخروج بنجاح', () async {
      // ترتيب
      when(mockSignOutUseCase.execute())
          .thenAnswer((_) async => true);

      // تنفيذ
      await authNotifier.signOut();

      // تحقق
      verify(mockSignOutUseCase.execute()).called(1);
      expect(authNotifier.state.user, null);
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, null);
    });
  });
}

import 'package:admin_panell/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/is_signed_in_usecase.dart';
import 'package:admin_panell/features/auth/presentation/bloc/auth_notifier.dart';
import 'package:admin_panell/features/auth/domain/entities/user_entity.dart';
import 'package:admin_panell/core/services/crashlytics_manager.dart';
import 'package:admin_panell/core/storage/secure_storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

// إنشاء فئات وهمية يدوياً للاختبارات
class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockIsSignedInUseCase extends Mock implements IsSignedInUseCase {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockCrashlyticsManager extends Mock implements CrashlyticsManager {}

void main() {
  late MockSignInUseCase mockSignInUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsSignedInUseCase mockIsSignedInUseCase;
  late MockSecureStorageService mockSecureStorageService;
  late MockCrashlyticsManager mockCrashlyticsManager;
  late AuthNotifier authNotifier;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockIsSignedInUseCase = MockIsSignedInUseCase();
    mockSecureStorageService = MockSecureStorageService();
    mockCrashlyticsManager = MockCrashlyticsManager();

    authNotifier = AuthNotifier(
      signInUseCase: mockSignInUseCase,
      signOutUseCase: mockSignOutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      isSignedInUseCase: mockIsSignedInUseCase,
      secureStorage: mockSecureStorageService,
      crashlytics: mockCrashlyticsManager,
    );
  });

  group('تسجيل الدخول', () {
    const email = 'test@example.com';
    const password = 'password123';
    const user = UserEntity(
      id: '1',
      email: email,
      role: 'admin',
      name: 'Test User',
    );

    test('يجب أن يقوم بتسجيل الدخول بنجاح', () async {
      // ترتيب
      when(mockSignInUseCase.execute(email: email, password: password))
          .thenAnswer((_) async => user);
      when(mockCrashlyticsManager.setUserIdentifier(userId: any))
          .thenAnswer((_) async => {});

      // تنفيذ
      await authNotifier.signIn(email: email, password: password);

      // تحقق
      verify(mockSignInUseCase.execute(email: email, password: password))
          .called(1);
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
      when(mockCrashlyticsManager.recordError(any, StackTrace.current))
          .thenAnswer((_) async => {});

      // تنفيذ
      await authNotifier.signIn(email: email, password: password);

      // تحقق
      verify(mockSignInUseCase.execute(email: email, password: password))
          .called(1);
      expect(authNotifier.state.user, null);
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, isNotNull);
    });
  });

  group('تسجيل الخروج', () {
    test('يجب أن يقوم بتسجيل الخروج بنجاح', () async {
      // ترتيب
      when(mockSignOutUseCase.execute()).thenAnswer((_) async => true);
      when(mockCrashlyticsManager.setUserIdentifier(userId: any))
          .thenAnswer((_) async => {});

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

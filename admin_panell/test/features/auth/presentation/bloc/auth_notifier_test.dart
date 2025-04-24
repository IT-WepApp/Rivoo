import 'package:admin_panell/features/auth/application/auth_notifier.dart' show crashlyticsManagerProvider, secureStorageServiceProvider;
import 'package:admin_panell/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panell/features/auth/domain/usecases/is_signed_in_usecase.dart';
import 'package:admin_panell/features/auth/presentation/bloc/auth_notifier.dart';
import 'package:shared_libs/entities/user_entity.dart';
import 'package:admin_panell/core/services/crashlytics_manager.dart';
import 'package:admin_panell/core/storage/secure_storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockIsSignedInUseCase extends Mock implements IsSignedInUseCase {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockCrashlyticsManager extends Mock implements CrashlyticsManager {}

class User extends UserEntity {
  const User({required super.id, required super.email, required super.role, required super.name});
}

void main() {
  late MockSignInUseCase mockSignInUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsSignedInUseCase mockIsSignedInUseCase;
  late MockSecureStorageService mockSecureStorageService;
  late MockCrashlyticsManager mockCrashlyticsManager;
  late AuthNotifier authNotifier;
  late ProviderContainer container;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockIsSignedInUseCase = MockIsSignedInUseCase();
    mockSecureStorageService = MockSecureStorageService();
    mockCrashlyticsManager = MockCrashlyticsManager();

    container = ProviderContainer(overrides: [
      signInUseCaseProvider.overrideWithValue(mockSignInUseCase),
      signOutUseCaseProvider.overrideWithValue(mockSignOutUseCase),
      getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUserUseCase),
      isSignedInUseCaseProvider.overrideWithValue(mockIsSignedInUseCase),
      secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
      crashlyticsManagerProvider.overrideWithValue(mockCrashlyticsManager),
    ]);

    authNotifier = container.read(authNotifierProvider.notifier);
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
      when(mockSignInUseCase.execute(email: email, password: password))
          .thenAnswer((_) async => user as dynamic);

      when(mockCrashlyticsManager.setUserIdentifier(userId: any))
          .thenAnswer((_) async => {});

      await authNotifier.handleEvent(SignInEvent(email: email, password: password));

      expect(authNotifier.state, isA<AuthAuthenticated>());
      expect((authNotifier.state as AuthAuthenticated).user, user);
    });

    test('يجب أن يعالج خطأ تسجيل الدخول', () async {
      final exception = Exception('فشل تسجيل الدخول');
      when(mockSignInUseCase.execute(email: email, password: password))
          .thenThrow(exception);
      when(mockCrashlyticsManager.recordError(any, StackTrace.current))
          .thenAnswer((_) async => {});

      await authNotifier.handleEvent(SignInEvent(email: email, password: password));

      expect(authNotifier.state, isA<AuthError>());
      expect((authNotifier.state as AuthError).message, isNotNull);
    });
  });

  group('تسجيل الخروج', () {
    test('يجب أن يقوم بتسجيل الخروج بنجاح', () async {
      when(mockSignOutUseCase.execute()).thenAnswer((_) async => true);
      when(mockCrashlyticsManager.setUserIdentifier(userId: any))
          .thenAnswer((_) async => {});

      await authNotifier.handleEvent(SignOutEvent());

      expect(authNotifier.state, isA<AuthUnauthenticated>());
    });
  });
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/is_signed_in_usecase.dart';
import '../domain/entities/user.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/services/crashlytics_manager.dart';

/// حالة المصادقة في التطبيق
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  /// إنشاء نسخة جديدة من الحالة مع تحديث بعض القيم
  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// مدير حالة المصادقة في التطبيق
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsSignedInUseCase _isSignedInUseCase;
  final SecureStorageServiceImpl _secureStorage;
  final CrashlyticsManager _crashlytics;

  /// إنشاء مدير حالة المصادقة
  AuthNotifier({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsSignedInUseCase isSignedInUseCase,
    required SecureStorageServiceImpl secureStorage,
    required CrashlyticsManager crashlytics,
  })  : _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _isSignedInUseCase = isSignedInUseCase,
        _secureStorage = secureStorage,
        _crashlytics = crashlytics,
        super(const AuthState());

  /// التحقق من حالة المصادقة الحالية
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isSignedIn = await _isSignedInUseCase.execute();
      if (isSignedIn) {
        final user = await _getCurrentUserUseCase.execute();
        if (user != null) {
          await _crashlytics.setUserIdentifier(userId: user.id);
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user =
          await _signInUseCase.execute(email: email, password: password);
      await _crashlytics.setUserIdentifier(userId: user.id);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// تسجيل الخروج من التطبيق
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _signOutUseCase.execute();
      await _crashlytics.setUserIdentifier(userId: null);
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

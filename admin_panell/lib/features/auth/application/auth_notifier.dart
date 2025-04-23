import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/is_signed_in_usecase.dart';
import '../domain/entities/user.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/services/crashlytics_manager.dart';

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
class AuthNotifier extends Notifier<AuthState> {
  late final SignInUseCase _signInUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final IsSignedInUseCase _isSignedInUseCase;
  late final SecureStorageService _secureStorage; 
  late final CrashlyticsManager _crashlytics;

  @override
  AuthState build() {
    _signInUseCase = ref.read(signInUseCaseProvider);
    _signOutUseCase = ref.read(signOutUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _isSignedInUseCase = ref.read(isSignedInUseCaseProvider);
    _secureStorage = ref.read(secureStorageServiceProvider);
    _crashlytics = ref.read(crashlyticsManagerProvider);
    
    return const AuthState();
  }

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

// تعريف مزودات لحالات الاستخدام
final signInUseCaseProvider = Provider<SignInUseCase>((ref) => throw UnimplementedError());
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) => throw UnimplementedError());
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => throw UnimplementedError());
final isSignedInUseCaseProvider = Provider<IsSignedInUseCase>((ref) => throw UnimplementedError());
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) => throw UnimplementedError());
final crashlyticsManagerProvider = Provider<CrashlyticsManager>((ref) => throw UnimplementedError());

// تعريف مزود AuthNotifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

// تعريف مزود authProvider كبديل لـ authNotifierProvider للتوافق مع الكود الحالي
final authProvider = authNotifierProvider;

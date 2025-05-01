import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/entities/user_entity.dart';
import 'package:shared_libs/services/auth_service.dart'; // Import unified AuthService
import 'package:shared_libs/services/secure_storage_service.dart'; // Import unified SecureStorageService
// Assuming AppLogger or similar is used within AuthService for logging/crash reporting

/// حالة المصادقة في التطبيق
class AuthState {
  final UserEntity? user;
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
    UserEntity? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false, // Option to clear error
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// مدير حالة المصادقة في التطبيق باستخدام AuthService الموحد
class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;
  // SecureStorageService might be used internally by AuthService or directly if needed
  // late final SecureStorageService _secureStorage;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider); // Use the provider for unified AuthService
    // _secureStorage = ref.read(secureStorageServiceProvider); // If needed directly
    _initialize();
    return const AuthState(isLoading: true); // Initial state is loading
  }

  Future<void> _initialize() async {
    await checkAuthStatus();
  }

  /// التحقق من حالة المصادقة الحالية
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // Optionally check user role for admin panel access
        // if (user.role == UserRole.admin) { ... }
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      // Error logged within AuthService
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: 'فشل التحقق من حالة المصادقة: $e',
      );
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signInWithEmailPassword(email: email, password: password);
      // Optionally check user role
      // if (user.role != UserRole.admin) { throw Exception('Access denied'); }
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      // Error logged within AuthService
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تسجيل الدخول: $e',
      );
      return false;
    }
  }

  /// تسجيل الخروج من التطبيق
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signOut();
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      // Error logged within AuthService
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تسجيل الخروج: $e',
      );
    }
  }
}

// Assuming authServiceProvider is defined elsewhere, providing the unified AuthService
// e.g., final authServiceProvider = Provider<AuthService>((ref) => AuthService(...));

// تعريف مزود AuthNotifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

// تعريف مزود authProvider كبديل لـ authNotifierProvider للتوافق مع الكود الحالي
final authProvider = authNotifierProvider;


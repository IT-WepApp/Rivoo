import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// حالة المصادقة
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// نموذج حالة المصادقة
class AuthStateModel {
  final AuthState state;
  final UserModel? user;
  final String? errorMessage;

  AuthStateModel({
    required this.state,
    this.user,
    this.errorMessage,
  });

  /// نسخة أولية من الحالة
  factory AuthStateModel.initial() {
    return AuthStateModel(state: AuthState.initial);
  }

  /// نسخة من الحالة أثناء التحميل
  AuthStateModel loading() {
    return AuthStateModel(state: AuthState.loading);
  }

  /// نسخة من الحالة بعد المصادقة
  AuthStateModel authenticated(UserModel user) {
    return AuthStateModel(
      state: AuthState.authenticated,
      user: user,
    );
  }

  /// نسخة من الحالة بدون مصادقة
  AuthStateModel unauthenticated() {
    return AuthStateModel(state: AuthState.unauthenticated);
  }

  /// نسخة من الحالة في حالة الخطأ
  AuthStateModel error(String message) {
    return AuthStateModel(
      state: AuthState.error,
      errorMessage: message,
    );
  }
}

/// مزود حالة المصادقة
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthStateModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// مزود خدمة المصادقة
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// مدير حالة المصادقة
class AuthNotifier extends StateNotifier<AuthStateModel> {
  final AuthService _authService;
  final _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this._authService) : super(AuthStateModel.initial()) {
    checkAuthStatus();
  }

  /// التحقق من حالة المصادقة
  Future<void> checkAuthStatus() async {
    state = state.loading();
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = state.authenticated(user);
        } else {
          await _secureStorage.delete(key: 'auth_token');
          state = state.unauthenticated();
        }
      } else {
        state = state.unauthenticated();
      }
    } catch (e) {
      state = state.error(e.toString());
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.loading();
    try {
      final result =
          await _authService.signInWithEmailAndPassword(email, password);
      await _secureStorage.write(key: 'auth_token', value: result.token);
      await _secureStorage.write(key: 'user_id', value: result.user.id);
      state = state.authenticated(result.user);
    } catch (e) {
      state = state.error(e.toString());
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    state = state.loading();
    try {
      await _authService.signOut();
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_id');
      state = state.unauthenticated();
    } catch (e) {
      state = state.error(e.toString());
    }
  }
}

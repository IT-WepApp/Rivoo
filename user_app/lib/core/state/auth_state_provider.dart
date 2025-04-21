import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

part 'auth_state_provider.freezed.dart';
part 'auth_state_provider.g.dart';

/// نموذج حالة المصادقة باستخدام freezed للتعامل مع الحالات المختلفة
@freezed
class AuthState with _$AuthState {
  /// حالة التحميل الأولي
  const factory AuthState.initial() = _Initial;

  /// حالة التحميل
  const factory AuthState.loading() = _Loading;

  /// حالة المصادقة الناجحة
  const factory AuthState.authenticated(UserModel user) = _Authenticated;

  /// حالة عدم المصادقة
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// حالة الخطأ
  const factory AuthState.error(String message) = _Error;
}

/// مزود حالة المصادقة باستخدام Riverpod المُولّد
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);

    // الاستماع لتغييرات حالة المصادقة من Firebase
    FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChange);

    return const AuthState.initial();
  }

  /// معالجة تغييرات حالة المصادقة
  void _handleAuthStateChange(User? user) async {
    if (user == null) {
      state = const AuthState.unauthenticated();
    } else {
      state = const AuthState.loading();
      try {
        final userModel = await _authService.getUserData(user.uid);
        state = AuthState.authenticated(userModel);
      } catch (e) {
        state = AuthState.error(e.toString());
      }
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      // حالة المصادقة ستتحدث من خلال مستمع authStateChanges
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// إنشاء حساب جديد
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    state = const AuthState.loading();
    try {
      await _authService.createUserWithEmailAndPassword(email, password, name);
      // حالة المصادقة ستتحدث من خلال مستمع authStateChanges
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _authService.signOut();
      // حالة المصادقة ستتحدث من خلال مستمع authStateChanges
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

/// مزود قراءة فقط لحالة المصادقة الحالية
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
}

/// مزود قراءة فقط لنموذج المستخدم الحالي
@riverpod
UserModel? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
}

/// مزود قراءة فقط لدور المستخدم الحالي
@riverpod
String? userRole(UserRoleRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
}

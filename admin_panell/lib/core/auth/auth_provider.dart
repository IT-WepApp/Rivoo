import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// حالة المصادقة
enum AuthStatus {
  /// غير مصادق
  unauthenticated,
  
  /// جاري المصادقة
  authenticating,
  
  /// تم المصادقة
  authenticated,
  
  /// حدث خطأ في المصادقة
  error,
}

/// نموذج حالة المصادقة
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isAdmin;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.isAdmin = false,
  });

  /// إنشاء نسخة جديدة من حالة المصادقة مع تحديث بعض الحقول
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isAdmin,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

/// مزود حالة المصادقة
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;

  AuthNotifier({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(const AuthState()) {
    // الاستماع لتغييرات حالة المصادقة
    _auth.authStateChanges().listen(_authStateChanged);
  }

  /// معالجة تغييرات حالة المصادقة
  void _authStateChanged(User? user) {
    if (user == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    } else {
      // التحقق من أن المستخدم هو مسؤول
      _checkIfUserIsAdmin(user);
    }
  }

  /// التحقق من أن المستخدم هو مسؤول
  Future<void> _checkIfUserIsAdmin(User user) async {
    try {
      // هنا يمكن استخدام خدمة التفويض للتحقق من أن المستخدم هو مسؤول
      // مثال: final isAdmin = await _authorizationService.hasPermission(user.uid, 'admin');
      
      // للتبسيط، نفترض أن المستخدم هو مسؤول إذا كان البريد الإلكتروني يحتوي على كلمة admin
      final isAdmin = user.email?.contains('admin') ?? false;
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isAdmin: isAdmin,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // لا نحتاج لتحديث الحالة هنا لأن _authStateChanged سيتم استدعاؤه تلقائيًا
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // لا نحتاج لتحديث الحالة هنا لأن _authStateChanged سيتم استدعاؤه تلقائيًا
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

/// مزود حالة المصادقة
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// مزود حالة المصادقة (للاستماع فقط)
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider);
});

/// مزود حالة تسجيل الدخول
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

/// مزود حالة المسؤول
final isAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAdmin;
});

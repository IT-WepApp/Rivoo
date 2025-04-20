import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/constants/app_constants.dart';

/// مزود خدمة التخزين الآمن
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// مزود خدمة المصادقة
final authServiceProvider = Provider<AuthService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(secureStorage, FirebaseAuth.instance);
});

/// حالة المصادقة
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  verifying,
  loading,
  error,
}

/// حالة المستخدم
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// مزود حالة المصادقة
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// مدير حالة المصادقة
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  /// تهيئة حالة المصادقة
  Future<void> _init() async {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
      }
    });
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signIn(email, password);
      // لا نحتاج لتحديث الحالة هنا لأن مستمع authStateChanges سيقوم بذلك
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signUp(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signUp(email, password);
      // لا نحتاج لتحديث الحالة هنا لأن مستمع authStateChanges سيقوم بذلك
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signOut();
      // لا نحتاج لتحديث الحالة هنا لأن مستمع authStateChanges سيقوم بذلك
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// إرسال بريد تأكيد البريد الإلكتروني
  Future<void> sendEmailVerification() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.sendEmailVerification();
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// التحقق من حالة تأكيد البريد الإلكتروني
  Future<void> checkEmailVerification() async {
    try {
      state = state.copyWith(status: AuthStatus.verifying);
      final isVerified = await _authService.isEmailVerified();
      state = state.copyWith(
        status: isVerified ? AuthStatus.authenticated : AuthStatus.verifying,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

/// خدمة المصادقة
class AuthService {
  final SecureStorageService _secureStorage;
  final FirebaseAuth _auth;

  AuthService(this._secureStorage, this._auth);

  /// الحصول على مستمع لتغييرات حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // حفظ الرمز المميز وحذف كلمة المرور
      if (credential.user != null) {
        final token = await credential.user!.getIdToken();
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        
        // حفظ معرف المستخدم
        await _secureStorage.write(key: AppConstants.userIdKey, value: credential.user!.uid);
      }
      
      return credential;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // حفظ الرمز المميز وحذف كلمة المرور
      if (credential.user != null) {
        final token = await credential.user!.getIdToken();
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        
        // حفظ معرف المستخدم
        await _secureStorage.write(key: AppConstants.userIdKey, value: credential.user!.uid);
        
        // إرسال بريد تأكيد البريد الإلكتروني
        await credential.user!.sendEmailVerification();
      }
      
      return credential;
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: $e');
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('فشل إرسال رابط إعادة تعيين كلمة المرور: $e');
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // حذف الرمز المميز ومعرف المستخدم
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.userIdKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw Exception('فشل تسجيل الخروج: $e');
    }
  }

  /// إرسال بريد تأكيد البريد الإلكتروني
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw Exception('لا يوجد مستخدم حالي');
      }
    } catch (e) {
      throw Exception('فشل إرسال بريد تأكيد البريد الإلكتروني: $e');
    }
  }

  /// التحقق من حالة تأكيد البريد الإلكتروني
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      throw Exception('فشل التحقق من حالة تأكيد البريد الإلكتروني: $e');
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      } else {
        throw Exception('لا يوجد مستخدم حالي');
      }
    } catch (e) {
      throw Exception('فشل تحديث بيانات المستخدم: $e');
    }
  }

  /// تحديث البريد الإلكتروني
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        await user.sendEmailVerification();
      } else {
        throw Exception('لا يوجد مستخدم حالي');
      }
    } catch (e) {
      throw Exception('فشل تحديث البريد الإلكتروني: $e');
    }
  }

  /// تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('لا يوجد مستخدم حالي');
      }
    } catch (e) {
      throw Exception('فشل تحديث كلمة المرور: $e');
    }
  }

  /// إعادة المصادقة
  Future<UserCredential> reauthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        return await user.reauthenticateWithCredential(credential);
      } else {
        throw Exception('لا يوجد مستخدم حالي');
      }
    } catch (e) {
      throw Exception('فشل إعادة المصادقة: $e');
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        
        // حذف الرمز المميز ومعرف المستخدم
        await _secureStorage.delete(key: AppConstants.tokenKey);
        await _secureStorage.delete(key: AppConstants.userIdKey);
        await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      } else {
        throw Exception('لا يوجد مستخدم حالي');
      }
    } catch (e) {
      throw Exception('فشل حذف الحساب: $e');
    }
  }
}

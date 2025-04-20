import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_state.dart';
import 'package:user_app/features/auth/application/auth_service.dart';

/// مزود لحالة المصادقة
final authStateNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// مزود لحالة المصادقة الحالية
final currentAuthStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authStateNotifierProvider);
});

/// مزود للتحقق من حالة تسجيل الدخول
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateNotifierProvider).isAuthenticated;
});

/// مزود للتحقق من تأكيد البريد الإلكتروني
final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authStateNotifierProvider).isEmailVerified;
});

/// مزود للتحقق من دور المستخدم
final hasRoleProvider = Provider.family<bool, UserRole>((ref, role) {
  return ref.watch(authStateNotifierProvider).hasRole(role);
});

/// مزود للتحقق من أي من الأدوار المحددة
final hasAnyRoleProvider = Provider.family<bool, List<UserRole>>((ref, roles) {
  return ref.watch(authStateNotifierProvider).hasAnyRole(roles);
});

/// مدير حالة المصادقة
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState()) {
    _initAuthState();
  }
  
  /// تهيئة حالة المصادقة
  Future<void> _initAuthState() async {
    state = state.copyWith(status: AuthenticationStatus.loading);
    
    try {
      // الاستماع لتغييرات حالة المصادقة
      _authService.authStateChanges.listen((fb_auth.User? user) async {
        if (user != null) {
          // الحصول على دور المستخدم
          final role = await _authService.getUserRole(user.uid);
          
          // إنشاء نموذج بيانات المستخدم
          final userData = UserData(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL,
            role: role,
            isEmailVerified: user.emailVerified,
          );
          
          state = state.copyWith(
            status: AuthenticationStatus.authenticated,
            userData: userData,
            firebaseUser: user,
            isLoading: false,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: AuthenticationStatus.unauthenticated,
            userData: null,
            firebaseUser: null,
            isLoading: false,
            errorMessage: null,
          );
        }
      });
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, status: AuthenticationStatus.loading);
      await _authService.signIn(email, password);
      // لا نحتاج لتحديث الحالة هنا لأن مستمع authStateChanges سيقوم بذلك
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signUp(String email, String password, {UserRole role = UserRole.customer}) async {
    try {
      state = state.copyWith(isLoading: true, status: AuthenticationStatus.loading);
      await _authService.signUp(email, password, role: role);
      // لا نحتاج لتحديث الحالة هنا لأن مستمع authStateChanges سيقوم بذلك
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, status: AuthenticationStatus.loading);
      await _authService.signOut();
      // لا نحتاج لتحديث الحالة هنا لأن مستمع authStateChanges سيقوم بذلك
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, status: AuthenticationStatus.loading);
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(
        isLoading: false,
        status: AuthenticationStatus.unauthenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// إرسال بريد تأكيد البريد الإلكتروني
  Future<void> sendEmailVerification() async {
    try {
      state = state.copyWith(isLoading: true, status: AuthenticationStatus.loading);
      await _authService.sendEmailVerification();
      state = state.copyWith(
        isLoading: false,
        status: AuthenticationStatus.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// التحقق من حالة تأكيد البريد الإلكتروني
  Future<void> checkEmailVerification() async {
    try {
      state = state.copyWith(isLoading: true, status: AuthenticationStatus.verifying);
      final isVerified = await _authService.isEmailVerified();
      
      if (state.userData != null) {
        final updatedUserData = state.userData!.copyWith(isEmailVerified: isVerified);
        
        state = state.copyWith(
          isLoading: false,
          status: isVerified ? AuthenticationStatus.authenticated : AuthenticationStatus.verifying,
          userData: updatedUserData,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          status: AuthenticationStatus.unauthenticated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// تحديث دور المستخدم
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.updateUserRole(userId, role);
      
      if (state.userData != null && userId == state.userData!.uid) {
        final updatedUserData = state.userData!.copyWith(role: role);
        
        state = state.copyWith(
          isLoading: false,
          userData: updatedUserData,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// تحديث بيانات المستخدم
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.updateProfile(displayName: displayName, photoURL: photoURL);
      
      if (state.userData != null) {
        final updatedUserData = state.userData!.copyWith(
          displayName: displayName ?? state.userData!.displayName,
          photoURL: photoURL ?? state.userData!.photoURL,
        );
        
        state = state.copyWith(
          isLoading: false,
          userData: updatedUserData,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthenticationStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// التحقق من صلاحيات المستخدم
  bool hasPermission(List<UserRole> allowedRoles) {
    return state.hasAnyRole(allowedRoles);
  }
}

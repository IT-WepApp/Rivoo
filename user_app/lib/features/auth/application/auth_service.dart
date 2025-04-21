import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../domain/entities/user_role.dart';

/// مزود خدمة التخزين الآمن
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// مزود خدمة المصادقة
final authServiceProvider = Provider<AuthService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(
      secureStorage, FirebaseAuth.instance, FirebaseFirestore.instance);
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
  final UserRole? role;
  final String? errorMessage;
  final bool isEmailVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.role,
    this.errorMessage,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserRole? role,
    String? errorMessage,
    bool? isEmailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      role: role ?? this.role,
      errorMessage: errorMessage,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
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
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // التحقق من تأكيد البريد الإلكتروني
        await user.reload();
        final isEmailVerified = user.emailVerified;

        // الحصول على دور المستخدم
        final role = await _authService.getUserRole(user.uid);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          role: role,
          isEmailVerified: isEmailVerified,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          role: UserRole.guest,
          isEmailVerified: false,
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
  Future<void> signUp(String email, String password,
      {UserRole role = UserRole.customer}) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signUp(email, password, role: role);
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
        isEmailVerified: isVerified,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// تحديث دور المستخدم
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.updateUserRole(userId, role);

      if (userId == state.user?.uid) {
        state = state.copyWith(
          role: role,
          status: AuthStatus.authenticated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// التحقق من صلاحيات المستخدم
  bool hasPermission(List<UserRole> allowedRoles) {
    if (state.user == null) return false;
    if (state.role == null) return false;
    return allowedRoles.contains(state.role);
  }
}

/// خدمة المصادقة
class AuthService {
  final SecureStorageService _secureStorage;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final AppLogger _logger = AppLogger();

  AuthService(this._secureStorage, this._auth, this._firestore);

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
        final refreshToken = await _getRefreshToken(credential.user!);

        // استخدام الطرق المتقدمة في SecureStorageService لحفظ الرموز المميزة
        await _secureStorage.saveAuthToken(token,
            expiryMinutes: AppConstants.sessionTimeoutMinutes);
        await _secureStorage.saveRefreshToken(refreshToken);

        // حفظ بيانات المستخدم بشكل آمن
        final userData = {
          'uid': credential.user!.uid,
          'email': credential.user!.email,
          'displayName': credential.user!.displayName,
          'photoURL': credential.user!.photoURL,
          'lastLogin': DateTime.now().toIso8601String(),
        };
        await _secureStorage.saveUserData(userData);

        // تسجيل تاريخ تسجيل الدخول
        await _updateLoginTimestamp(credential.user!.uid);
      }

      return credential;
    } catch (e) {
      // تسجيل محاولة تسجيل الدخول الفاشلة للكشف عن الهجمات
      _logFailedLoginAttempt(email);
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential> signUp(String email, String password,
      {UserRole role = UserRole.customer}) async {
    try {
      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(password)) {
        throw Exception(
            'كلمة المرور غير قوية بما فيه الكفاية. يجب أن تحتوي على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا.');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // حفظ الرمز المميز وحذف كلمة المرور
      if (credential.user != null) {
        final token = await credential.user!.getIdToken();
        final refreshToken = await _getRefreshToken(credential.user!);

        // استخدام الطرق المتقدمة في SecureStorageService لحفظ الرموز المميزة
        await _secureStorage.saveAuthToken(token,
            expiryMinutes: AppConstants.sessionTimeoutMinutes);
        await _secureStorage.saveRefreshToken(refreshToken);

        // حفظ بيانات المستخدم بشكل آمن
        final userData = {
          'uid': credential.user!.uid,
          'email': credential.user!.email,
          'displayName': credential.user!.displayName,
          'photoURL': credential.user!.photoURL,
          'role': role.toString().split('.').last,
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _secureStorage.saveUserData(userData);

        // إنشاء وثيقة المستخدم في Firestore
        await _createUserDocument(credential.user!.uid, email, role);

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

      // استخدام طريقة clearAll من SecureStorageService لحذف جميع البيانات المخزنة
      await _secureStorage.clearAll();
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

  /// الحصول على دور المستخدم
  Future<UserRole> getUserRole(String userId) async {
    try {
      // محاولة الحصول على الدور من التخزين الآمن أولاً
      final userData = await _secureStorage.getUserData();
      if (userData != null &&
          userData['uid'] == userId &&
          userData['role'] != null) {
        final roleString = userData['role'] as String;
        switch (roleString) {
          case 'admin':
            return UserRole.admin;
          case 'driver':
            return UserRole.driver;
          case 'customer':
            return UserRole.customer;
          default:
            return UserRole.customer;
        }
      }

      // إذا لم يتم العثور على الدور في التخزين الآمن، استعلم من Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final roleString = doc.data()!['role'] as String?;
        if (roleString != null) {
          // تحديث بيانات المستخدم في التخزين الآمن
          if (userData != null) {
            userData['role'] = roleString;
            await _secureStorage.saveUserData(userData);
          }

          switch (roleString) {
            case 'admin':
              return UserRole.admin;
            case 'driver':
              return UserRole.driver;
            case 'customer':
              return UserRole.customer;
            default:
              return UserRole.customer;
          }
        }
      }
      return UserRole.customer;
    } catch (e) {
      _logger.error('Error getting user role', e);
      return UserRole.customer;
    }
  }

  /// تحديث دور المستخدم
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      String roleString;
      switch (role) {
        case UserRole.admin:
          roleString = 'admin';
          break;
        case UserRole.driver:
          roleString = 'driver';
          break;
        case UserRole.customer:
          roleString = 'customer';
          break;
        default:
          roleString = 'customer';
      }

      // تحديث وثيقة المستخدم في Firestore
      await _firestore.collection('users').doc(userId).update({
        'role': roleString,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث بيانات المستخدم في التخزين الآمن
      final userData = await _secureStorage.getUserData();
      if (userData != null && userData['uid'] == userId) {
        userData['role'] = roleString;
        await _secureStorage.saveUserData(userData);
      }
    } catch (e) {
      throw Exception('فشل تحديث دور المستخدم: $e');
    }
  }

  // طرق مساعدة خاصة

  /// إنشاء وثيقة المستخدم في Firestore
  Future<void> _createUserDocument(
      String userId, String email, UserRole role) async {
    try {
      String roleString;
      switch (role) {
        case UserRole.admin:
          roleString = 'admin';
          break;
        case UserRole.driver:
          roleString = 'driver';
          break;
        case UserRole.customer:
          roleString = 'customer';
          break;
        default:
          roleString = 'customer';
      }

      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'role': roleString,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      _logger.error('Error creating user document', e);
      throw Exception('فشل إنشاء وثيقة المستخدم: $e');
    }
  }

  /// تحديث تاريخ تسجيل الدخول
  Future<void> _updateLoginTimestamp(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.error('Error updating login timestamp', e);
    }
  }

  /// تسجيل محاولة تسجيل الدخول الفاشلة
  void _logFailedLoginAttempt(String email) {
    try {
      _firestore.collection('failedLogins').add({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': 'unknown', // يمكن تحديث هذا لاحقًا
      });
    } catch (e) {
      _logger.error('Error logging failed login attempt', e);
    }
  }

  /// الحصول على رمز التحديث
  Future<String> _getRefreshToken(User user) async {
    try {
      // هذه طريقة مبسطة، في الواقع يجب استخدام Firebase SDK للحصول على رمز التحديث
      final idToken = await user.getIdToken();
      final bytes = utf8.encode('${user.uid}:$idToken:${DateTime.now().millisecondsSinceEpoch}');
      final refreshToken = sha256.convert(bytes).toString();
      return refreshToken;
    } catch (e) {
      _logger.error('Error getting refresh token', e);
      throw Exception('فشل الحصول على رمز التحديث: $e');
    }
  }

  /// التحقق من قوة كلمة المرور
  bool _isStrongPassword(String password) {
    // التحقق من طول كلمة المرور
    if (password.length < 8) {
      return false;
    }

    // التحقق من وجود حرف كبير
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    // التحقق من وجود حرف صغير
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    // التحقق من وجود رقم
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    // التحقق من وجود رمز
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';

/// مزود خدمة التخزين الآمن
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// مزود خدمة المصادقة
final authServiceProvider = Provider<AuthService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(secureStorage, FirebaseAuth.instance, FirebaseFirestore.instance);
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

/// أدوار المستخدم
enum UserRole {
  customer,
  driver,
  admin,
  guest,
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
  Future<void> signUp(String email, String password, {UserRole role = UserRole.customer}) async {
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
        
        // تشفير الرمز المميز قبل التخزين
        final encryptedToken = _encryptData(token);
        final encryptedRefreshToken = _encryptData(refreshToken);
        
        await _secureStorage.write(key: AppConstants.tokenKey, value: encryptedToken);
        await _secureStorage.write(key: AppConstants.refreshTokenKey, value: encryptedRefreshToken);
        
        // حفظ معرف المستخدم
        await _secureStorage.write(key: AppConstants.userIdKey, value: credential.user!.uid);
        
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
  Future<UserCredential> signUp(String email, String password, {UserRole role = UserRole.customer}) async {
    try {
      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(password)) {
        throw Exception('كلمة المرور غير قوية بما فيه الكفاية. يجب أن تحتوي على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا.');
      }
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // حفظ الرمز المميز وحذف كلمة المرور
      if (credential.user != null) {
        final token = await credential.user!.getIdToken();
        final refreshToken = await _getRefreshToken(credential.user!);
        
        // تشفير الرمز المميز قبل التخزين
        final encryptedToken = _encryptData(token);
        final encryptedRefreshToken = _encryptData(refreshToken);
        
        await _secureStorage.write(key: AppConstants.tokenKey, value: encryptedToken);
        await _secureStorage.write(key: AppConstants.refreshTokenKey, value: encryptedRefreshToken);
        
        // حفظ معرف المستخدم
        await _secureStorage.write(key: AppConstants.userIdKey, value: credential.user!.uid);
        
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
        
        // تحديث وثيقة المستخدم في Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
        // استخدام الأسلوب الموصى به بدلاً من الأسلوب المهمل
        await user.verifyBeforeUpdateEmail(newEmail);
        
        // تحديث وثيقة المستخدم في Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(newPassword)) {
        throw Exception('كلمة المرور غير قوية بما فيه الكفاية. يجب أن تحتوي على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا.');
      }
      
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        
        // تحديث وثيقة المستخدم في Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'passwordUpdatedAt': FieldValue.serverTimestamp(),
        });
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
        // حذف وثيقة المستخدم من Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // حذف الحساب من Firebase Auth
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

  /// الحصول على دور المستخدم
  Future<UserRole> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final roleString = doc.data()!['role'] as String?;
        if (roleString != null) {
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
      print('Error getting user role: $e');
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
      
      await _firestore.collection('users').doc(userId).update({
        'role': roleString,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('فشل تحديث دور المستخدم: $e');
    }
  }

  /// إنشاء وثيقة المستخدم في Firestore
  Future<void> _createUserDocument(String userId, String email, UserRole role) async {
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
      'email': email,
      'role': roleString,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// تحديث تاريخ تسجيل الدخول
  Future<void> _updateLoginTimestamp(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// تسجيل محاولة تسجيل الدخول الفاشلة
  Future<void> _logFailedLoginAttempt(String email) async {
    await _firestore.collection('failedLogins').add({
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
      'ip': 'unknown', // في التطبيق الحقيقي، يمكن الحصول على عنوان IP من الخادم
    });
  }

  /// الحصول على رمز تحديث المصادقة
  Future<String> _getRefreshToken(User user) async {
    final idTokenResult = await user.getIdTokenResult();
    return idTokenResult.token ?? '';
  }

  /// تشفير البيانات
  String _encryptData(String data) {
    // في التطبيق الحقيقي، يجب استخدام خوارزمية تشفير قوية مثل AES
    // هذه مجرد محاكاة بسيطة باستخدام SHA-256
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
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

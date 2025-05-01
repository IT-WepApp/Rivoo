import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage_service.dart';
import '../utils/encryption_utils.dart'; // تم التحديث
import '../utils/logger.dart'; // يفترض وجوده أو نقله
import '../enums/user_role.dart'; // تم التحديث
import '../constants/app_constants.dart'; // تم التحديث
import 'dart:async';

// --- Providers --- Provider definitions should ideally be in a separate file or at the app level ---

/// مزود خدمة التخزين الآمن (يفترض وجوده أو تعريفه في مكان مناسب)
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// مزود أداة التشفير
final encryptionUtilsProvider = Provider<EncryptionUtils>((ref) {
  return EncryptionUtils();
});

/// مزود خدمة المصادقة الموحدة
final authServiceProvider = Provider<AuthService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final encryptionUtils = ref.watch(encryptionUtilsProvider);
  // يمكنك تمرير مثيلات FirebaseAuth و FirebaseFirestore إذا أردت، أو استخدام Instance مباشرة
  return AuthService(
    secureStorage: secureStorage,
    encryptionUtils: encryptionUtils,
    // auth: fb_auth.FirebaseAuth.instance, // اختياري
    // firestore: FirebaseFirestore.instance, // اختياري
  );
});

// --- AuthService Implementation ---

/// خدمة المصادقة الموحدة والمحسنة
class AuthService {
  final SecureStorageService _secureStorage;
  final EncryptionUtils _encryptionUtils;
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final AppLogger _logger = AppLogger(); // يفترض وجود AppLogger في utils

  AuthService({
    required SecureStorageService secureStorage,
    required EncryptionUtils encryptionUtils,
    fb_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _secureStorage = secureStorage,
        _encryptionUtils = encryptionUtils,
        _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// الحصول على مستمع لتغييرات حالة المصادقة
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// الحصول على المستخدم الحالي من Firebase Auth
  fb_auth.User? get currentUser => _auth.currentUser;

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<fb_auth.UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password, // لا حاجة لتشفير كلمة المرور هنا، Firebase يعالجها
      );

      if (credential.user != null) {
        await _handleSuccessfulLogin(credential.user!);
      }

      return credential;
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.error('Sign in failed', e, StackTrace.current);
      _logFailedLoginAttempt(email);
      // يمكنك تحسين رسائل الخطأ هنا
      throw Exception('فشل تسجيل الدخول: ${e.message ?? e.code}');
    } catch (e) {
      _logger.error('Sign in failed with unexpected error', e, StackTrace.current);
      _logFailedLoginAttempt(email);
      throw Exception('فشل تسجيل الدخول: خطأ غير متوقع.');
    }
  }

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<fb_auth.UserCredential> signUp(String email, String password,
      {UserRole role = UserRole.customer}) async {
    try {
      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(password)) {
        throw Exception(
            'كلمة المرور غير قوية. يجب أن تحتوي على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا.');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // إنشاء وثيقة المستخدم في Firestore وتحديد الدور
        await _createUserDocument(credential.user!.uid, email, role);

        // إرسال بريد تأكيد البريد الإلكتروني
        await credential.user!.sendEmailVerification();

        // التعامل مع تسجيل الدخول الأولي بعد إنشاء الحساب
        await _handleSuccessfulLogin(credential.user!, role: role);
      }

      return credential;
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.error('Sign up failed', e, StackTrace.current);
      // يمكنك تحسين رسائل الخطأ هنا
      throw Exception('فشل إنشاء الحساب: ${e.message ?? e.code}');
    } catch (e) {
      _logger.error('Sign up failed with unexpected error', e, StackTrace.current);
      throw Exception('فشل إنشاء الحساب: خطأ غير متوقع.');
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // مسح جميع البيانات المخزنة بشكل آمن
      await _secureStorage.clearAll();
      _logger.info('User signed out successfully.');
    } catch (e) {
      _logger.error('Sign out failed', e, StackTrace.current);
      throw Exception('فشل تسجيل الخروج: $e');
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent to $email');
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.error('Failed to send password reset email', e, StackTrace.current);
      throw Exception('فشل إرسال رابط إعادة تعيين كلمة المرور: ${e.message ?? e.code}');
    } catch (e) {
      _logger.error('Failed to send password reset email with unexpected error', e, StackTrace.current);
      throw Exception('فشل إرسال رابط إعادة تعيين كلمة المرور: خطأ غير متوقع.');
    }
  }

  /// إرسال بريد تأكيد البريد الإلكتروني للمستخدم الحالي
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _logger.info('Verification email sent to ${user.email}');
      } else if (user == null) {
        throw Exception('لا يوجد مستخدم حالي لإرسال بريد التحقق.');
      } else {
        _logger.info('Email ${user.email} is already verified.');
        // يمكنك اختيار عدم رمي استثناء هنا إذا كان البريد مؤكدًا بالفعل
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.error('Failed to send verification email', e, StackTrace.current);
      throw Exception('فشل إرسال بريد تأكيد البريد الإلكتروني: ${e.message ?? e.code}');
    } catch (e) {
      _logger.error('Failed to send verification email with unexpected error', e, StackTrace.current);
      throw Exception('فشل إرسال بريد تأكيد البريد الإلكتروني: خطأ غير متوقع.');
    }
  }

  /// التحقق من حالة تأكيد البريد الإلكتروني للمستخدم الحالي
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // تحديث حالة المستخدم من Firebase
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      _logger.error('Failed to check email verification status', e, StackTrace.current);
      // لا ترمي استثناء هنا عادةً، فقط أرجع false
      return false;
    }
  }

  /// الحصول على دور المستخدم المحدد
  Future<UserRole> getUserRole(String userId) async {
    try {
      // 1. محاولة الحصول على الدور من التخزين الآمن أولاً (أسرع)
      final storedUserData = await _secureStorage.getUserData();
      if (storedUserData != null &&
          storedUserData['uid'] == userId &&
          storedUserData['role'] != null) {
        final roleString = storedUserData['role'] as String;
        final role = _parseUserRole(roleString);
        if (role != UserRole.guest) { // تأكد من أنه ليس الدور الافتراضي للخطأ
           _logger.fine('User role $roleString found in secure storage for user $userId');
           return role;
        }
      }

      // 2. إذا لم يتم العثور عليه أو كان غير صالح، استعلم من Firestore
      _logger.fine('User role not found in secure storage for $userId, querying Firestore.');
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final roleString = data['role'] as String?;
        if (roleString != null) {
          final role = _parseUserRole(roleString);
          // تحديث بيانات المستخدم في التخزين الآمن بالدور الصحيح
          await _updateSecureStorageWithRole(userId, role);
          _logger.info('User role $roleString fetched from Firestore for user $userId');
          return role;
        }
      }
      // إذا لم يتم العثور على المستخدم أو الدور في Firestore
      _logger.warning('User document or role not found in Firestore for user $userId. Defaulting to guest.');
      return UserRole.guest; // أو يمكنك رمي استثناء إذا كان الدور مطلوبًا دائمًا
    } catch (e) {
      _logger.error('Error getting user role for $userId', e, StackTrace.current);
      return UserRole.guest; // أو رمي استثناء
    }
  }

  /// تحديث دور المستخدم في Firestore والتخزين الآمن
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      final roleString = role.toString().split('.').last;

      // 1. تحديث وثيقة المستخدم في Firestore
      await _firestore.collection('users').doc(userId).update({
        'role': roleString,
        'updatedAt': FieldValue.serverTimestamp(), // تحديث وقت التعديل
      });

      // 2. تحديث بيانات المستخدم في التخزين الآمن إذا كان هو المستخدم الحالي
      final currentUserData = await _secureStorage.getUserData();
      if (currentUserData != null && currentUserData['uid'] == userId) {
         currentUserData['role'] = roleString;
         await _secureStorage.saveUserData(currentUserData);
      }
      _logger.info('User role updated to $roleString for user $userId');

    } catch (e) {
      _logger.error('Failed to update user role for $userId', e, StackTrace.current);
      throw Exception('فشل تحديث دور المستخدم: $e');
    }
  }

  /// تحديث الملف الشخصي للمستخدم في Firestore والتخزين الآمن
  Future<void> updateProfile({
    required String userId,
    String? name,
    // لا تسمح بتحديث البريد الإلكتروني مباشرة هنا، استخدم طرق Firebase الخاصة
    // String? email,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    try {
      // 1. تحديث بيانات Firebase Auth (إذا لزم الأمر ومتاح)
      final user = _auth.currentUser;
      if (user != null && user.uid == userId) {
        await user.updateDisplayName(name); // تحديث الاسم المعروض
        await user.updatePhotoURL(photoUrl); // تحديث رابط الصورة
        // تحديث البريد الإلكتروني أو الهاتف يتطلب عمليات تحقق خاصة
      }

      // 2. تحديث وثيقة المستخدم في Firestore
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null) updateData['displayName'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (photoUrl != null) updateData['photoURL'] = photoUrl;

      if (updateData.length > 1) { // تأكد من وجود بيانات للتحديث
         await _firestore.collection('users').doc(userId).update(updateData);
      }

      // 3. تحديث بيانات المستخدم في التخزين الآمن
      final currentUserData = await _secureStorage.getUserData();
      if (currentUserData != null && currentUserData['uid'] == userId) {
         if (name != null) currentUserData['displayName'] = name;
         if (photoUrl != null) currentUserData['photoURL'] = photoUrl;
         // أضف الحقول الأخرى إذا قمت بتخزينها
         await _secureStorage.saveUserData(currentUserData);
      }
      _logger.info('User profile updated for user $userId');

    } catch (e) {
      _logger.error('Failed to update profile for user $userId', e, StackTrace.current);
      throw Exception('فشل تحديث الملف الشخصي: $e');
    }
  }

  // --- Helper Methods ---

  /// التعامل مع تسجيل الدخول الناجح (حفظ التوكنات، بيانات المستخدم، إلخ)
  Future<void> _handleSuccessfulLogin(fb_auth.User user, {UserRole? role}) async {
    try {
      final tokenResult = await user.getIdTokenResult(true); // فرض التحديث
      final token = tokenResult.token;
      // لا يوجد طريقة مباشرة للحصول على Refresh Token في SDK الويب/فلاتر
      // final refreshToken = await _getRefreshToken(user); // هذه الطريقة غير موجودة

      if (token != null) {
        await _secureStorage.saveAuthToken(token,
            expiryMinutes: AppConstants.sessionTimeoutMinutes);
        // await _secureStorage.saveRefreshToken(refreshToken);
      } else {
         _logger.warning('ID token was null after login for user ${user.uid}');
      }

      // الحصول على الدور إذا لم يتم تمريره (مفيد عند تسجيل الدخول وليس إنشاء الحساب)
      final userRole = role ?? await getUserRole(user.uid);

      // حفظ بيانات المستخدم الأساسية بشكل آمن
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'role': userRole.toString().split('.').last,
        'lastLogin': DateTime.now().toIso8601String(),
        // يمكنك إضافة حقول أخرى إذا لزم الأمر
      };
      await _secureStorage.saveUserData(userData);

      // تسجيل/تحديث تاريخ تسجيل الدخول في Firestore
      await _updateLoginTimestamp(user.uid);
      _logger.info('User ${user.uid} logged in successfully.');

    } catch (e) {
       _logger.error('Error handling successful login for ${user.uid}', e, StackTrace.current);
       // قد ترغب في تسجيل الخروج إذا فشلت هذه الخطوة
       // await signOut();
       throw Exception('حدث خطأ أثناء إعداد جلسة المستخدم.');
    }
  }

  /// إنشاء وثيقة المستخدم في Firestore عند إنشاء حساب جديد
  Future<void> _createUserDocument(String userId, String email, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'displayName': null, // يمكن للمستخدم تحديثه لاحقًا
        'photoURL': null,
        'phone': null,
        'address': null,
        'isEmailVerified': false, // سيتم تحديثه بواسطة Firebase Auth
        'isPhoneVerified': false,
        'lastLoginAt': null,
        // أضف أي حقول افتراضية أخرى
      });
      _logger.info('User document created in Firestore for user $userId');
    } catch (e) {
       _logger.error('Failed to create user document for $userId', e, StackTrace.current);
       // قد تحتاج إلى التعامل مع هذا الخطأ (مثل حذف حساب Firebase Auth؟)
       throw Exception('فشل إنشاء ملف المستخدم في قاعدة البيانات.');
    }
  }

  /// تحديث وقت آخر تسجيل دخول للمستخدم في Firestore
  Future<void> _updateLoginTimestamp(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // لا يعتبر خطأ فادحًا عادةً، فقط قم بتسجيله
      _logger.warning('Failed to update last login timestamp for user $userId', e);
    }
  }

  /// التحقق من قوة كلمة المرور
  bool _isStrongPassword(String password) {
    // مثال: 8 أحرف على الأقل، حرف كبير، حرف صغير، رقم، رمز
    final strongRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*
(Content truncated due to size limit. Use line ranges to read in chunks)

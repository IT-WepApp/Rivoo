import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/constants/app_constants.dart';

/// تنفيذ مستودع المصادقة
/// يقوم بتنفيذ واجهة AuthRepository باستخدام Firebase Auth وSecureStorageService
class AuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SecureStorageService _secureStorage;
  
  AuthRepositoryImpl({
    required firebase.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SecureStorageService secureStorage,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _secureStorage = secureStorage;
  
  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return Left(AuthFailure(
          message: 'فشل تسجيل الدخول: لم يتم العثور على المستخدم',
        ));
      }
      
      final user = credential.user!;
      final token = await user.getIdToken();
      final refreshToken = await _getRefreshToken(user);
      
      // حفظ الرمز المميز وبيانات المستخدم بشكل آمن
      await _secureStorage.saveAuthToken(token, expiryMinutes: AppConstants.sessionTimeoutMinutes);
      await _secureStorage.saveRefreshToken(refreshToken);
      
      // حفظ بيانات المستخدم بشكل آمن
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': DateTime.now().toIso8601String(),
      };
      await _secureStorage.saveUserData(userData);
      
      // تحديث تاريخ تسجيل الدخول في Firestore
      await _updateLoginTimestamp(user.uid);
      
      // الحصول على معلومات المستخدم الإضافية من Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      String role = 'customer';
      bool isEmailVerified = user.emailVerified;
      DateTime? createdAt;
      
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        role = data['role'] as String? ?? 'customer';
        
        if (data['createdAt'] != null) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        }
      }
      
      final userEntity = UserEntity(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        role: role,
        isEmailVerified: isEmailVerified,
        createdAt: createdAt,
        lastLoginAt: DateTime.now(),
      );
      
      return Right(userEntity);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'حدث خطأ غير متوقع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name) async {
    try {
      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(password)) {
        return Left(ValidationFailure(
          message: 'كلمة المرور غير قوية بما فيه الكفاية',
          errors: {
            'password': 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا',
          },
        ));
      }
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return Left(AuthFailure(
          message: 'فشل إنشاء الحساب: لم يتم إنشاء المستخدم',
        ));
      }
      
      final user = credential.user!;
      
      // تحديث اسم المستخدم
      await user.updateDisplayName(name);
      
      final token = await user.getIdToken();
      final refreshToken = await _getRefreshToken(user);
      
      // حفظ الرمز المميز وبيانات المستخدم بشكل آمن
      await _secureStorage.saveAuthToken(token, expiryMinutes: AppConstants.sessionTimeoutMinutes);
      await _secureStorage.saveRefreshToken(refreshToken);
      
      // حفظ بيانات المستخدم بشكل آمن
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': name,
        'photoURL': user.photoURL,
        'role': 'customer',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _secureStorage.saveUserData(userData);
      
      // إنشاء وثيقة المستخدم في Firestore
      await _createUserDocument(user.uid, email, name);
      
      // إرسال بريد تأكيد البريد الإلكتروني
      await user.sendEmailVerification();
      
      final userEntity = UserEntity(
        id: user.uid,
        email: user.email!,
        displayName: name,
        photoUrl: user.photoURL,
        role: 'customer',
        isEmailVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      return Right(userEntity);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'حدث خطأ غير متوقع: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      
      // حذف جميع البيانات المخزنة محلياً
      await _secureStorage.clearAll();
      
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل تسجيل الخروج: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل إرسال رابط إعادة تعيين كلمة المرور: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      // التحقق من وجود مستخدم حالي
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Right(false);
      }
      
      // التحقق من صلاحية الرمز المميز
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        // محاولة تجديد الرمز المميز
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) {
          await signOut();
          return const Right(false);
        }
        
        // تجديد الرمز المميز
        try {
          final newToken = await currentUser.getIdToken(true);
          await _secureStorage.saveAuthToken(newToken, expiryMinutes: AppConstants.sessionTimeoutMinutes);
          return const Right(true);
        } catch (e) {
          await signOut();
          return const Right(false);
        }
      }
      
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل التحقق من حالة المصادقة: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Right(null);
      }
      
      // محاولة الحصول على بيانات المستخدم من التخزين الآمن أولاً
      final userData = await _secureStorage.getUserData();
      if (userData != null && userData['uid'] == currentUser.uid) {
        final userEntity = UserEntity(
          id: userData['uid'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          photoUrl: userData['photoURL'] as String?,
          role: userData['role'] as String? ?? 'customer',
          isEmailVerified: currentUser.emailVerified,
          createdAt: userData['createdAt'] != null ? DateTime.parse(userData['createdAt'] as String) : null,
          lastLoginAt: userData['lastLogin'] != null ? DateTime.parse(userData['lastLogin'] as String) : null,
        );
        
        return Right(userEntity);
      }
      
      // إذا لم يتم العثور على البيانات في التخزين الآمن، استعلم من Firestore
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      String role = 'customer';
      DateTime? createdAt;
      
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        role = data['role'] as String? ?? 'customer';
        
        if (data['createdAt'] != null) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        }
      }
      
      final userEntity = UserEntity(
        id: currentUser.uid,
        email: currentUser.email!,
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoURL,
        role: role,
        isEmailVerified: currentUser.emailVerified,
        createdAt: createdAt,
        lastLoginAt: DateTime.now(),
      );
      
      // تحديث بيانات المستخدم في التخزين الآمن
      final newUserData = {
        'uid': currentUser.uid,
        'email': currentUser.email,
        'displayName': currentUser.displayName,
        'photoURL': currentUser.photoURL,
        'role': role,
        'createdAt': createdAt?.toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      };
      await _secureStorage.saveUserData(newUserData);
      
      return Right(userEntity);
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل الحصول على المستخدم الحالي: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure(
          message: 'لا يوجد مستخدم حالي',
        ));
      }
      
      // تحديث بيانات المستخدم في Firebase Auth
      if (user.displayName != null && user.displayName != currentUser.displayName) {
        await currentUser.updateDisplayName(user.displayName);
      }
      
      if (user.photoUrl != null && user.photoUrl != currentUser.photoURL) {
        await currentUser.updatePhotoURL(user.photoUrl);
      }
      
      // تحديث بيانات المستخدم في Firestore
      await _firestore.collection('users').doc(user.id).update({
        'displayName': user.displayName,
        'photoURL': user.photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // تحديث بيانات المستخدم في التخزين الآمن
      final userData = await _secureStorage.getUserData();
      if (userData != null) {
        userData['displayName'] = user.displayName;
        userData['photoURL'] = user.photoUrl;
        await _secureStorage.saveUserData(userData);
      }
      
      return Right(user);
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل تحديث بيانات المستخدم: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'لا يوجد مستخدم حالي',
        ));
      }
      
      // التحقق من قوة كلمة المرور الجديدة
      if (!_isStrongPassword(newPassword)) {
        return Left(ValidationFailure(
          message: 'كلمة المرور غير قوية بما فيه الكفاية',
          errors: {
            'password': 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا',
          },
        ));
      }
      
      // إعادة المصادقة قبل تغيير كلمة المرور
      final credential = firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // تحديث كلمة المرور
      await user.updatePassword(newPassword);
      
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل تحديث كلمة المرور: $e',
        stackTrace: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(AuthFailure(
          message: 'لا يوجد مستخدم حالي',
        ));
      }
      
      // إعادة المصادقة قبل حذف الحساب
      final credential = firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // حذف وثيقة المستخدم من Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // حذف الحساب من Firebase Auth
      await user.delete();
      
      // حذف جميع البيانات المخزنة محلياً
      await _secureStorage.clearAll();
      
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل حذف الحساب: $e',
        stackTrace: e,
      ));
    }
  }
  
  // طرق مساعدة خاصة
  
  /// الحصول على رمز التحديث
  Future<String> _getRefreshToken(firebase.User user) async {
    try {
      // هذه طريقة مبسطة، في التطبيق الحقيقي يجب استخدام طريقة آمنة للحصول على رمز التحديث
      return 'refresh_token_for_${user.uid}';
    } catch (e) {
      print('Error getting refresh token: $e');
      return '';
    }
  }
  
  /// تحديث تاريخ تسجيل الدخول
  Future<void> _updateLoginTimestamp(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating login timestamp: $e');
    }
  }
  
  /// إنشاء وثيقة المستخدم في Firestore
  Future<void> _createUserDocument(String userId, String email, String name) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': name,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }
  
  /// التحقق من قوة كلمة المرور
  bool _isStrongPassword(String password) {
    // كلمة المرور يجب أن تكون على الأقل 8 أحرف وتحتوي على حرف كبير وحرف صغير ورقم ورمز
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return password.length >= 8 && hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }
  
  /// معالجة استثناءات Firebase Auth
  Failure _handleFirebaseAuthException(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthFailure(
          message: 'لم يتم العثور على المستخدم',
          code: e.code,
        );
      case 'wrong-password':
        return AuthFailure(
          message: 'كلمة المرور غير صحيحة',
          code: e.code,
        );
      case 'email-already-in-use':
        return AuthFailure(
          message: 'البريد الإلكتروني مستخدم بالفعل',
          code: e.code,
        );
      case 'weak-password':
        return ValidationFailure(
          message: 'كلمة المرور ضعيفة',
          code: e.code,
        );
      case 'invalid-email':
        return ValidationFailure(
          message: 'البريد الإلكتروني غير صالح',
          code: e.code,
        );
      case 'user-disabled':
        return AuthFailure(
          message: 'تم تعطيل الحساب',
          code: e.code,
        );
      case 'too-many-requests':
        return AuthFailure(
          message: 'تم تجاوز عدد المحاولات المسموح بها، يرجى المحاولة لاحقًا',
          code: e.code,
        );
      default:
        return AuthFailure(
          message: 'حدث خطأ في المصادقة: ${e.message}',
          code: e.code,
        );
    }
  }
}

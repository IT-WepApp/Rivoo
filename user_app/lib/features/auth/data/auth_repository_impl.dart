import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';
import 'package:user_app/features/auth/domain/user_model.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/constants/app_constants.dart';

/// تنفيذ مستودع المصادقة
/// يطبق واجهة AuthRepository باستخدام Firebase Auth، Firestore وGoogle Sign-In
class AuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final SecureStorageService _secureStorage;

  /// منشئ مستودع المصادقة
  AuthRepositoryImpl({
    required firebase.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required SecureStorageService secureStorage,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _secureStorage = secureStorage;

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Left(const AuthFailure(
          message: 'فشل تسجيل الدخول: لم يتم العثور على المستخدم',
          code: 'USER_NOT_FOUND',
        ));
      }
      // جلب وثيقة المستخدم
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return Left(const AuthFailure(
          message: 'فشل تسجيل الدخول: لم يتم العثور على بيانات المستخدم',
          code: 'USER_DATA_NOT_FOUND',
        ));
      }
      // حفظ الرمز
      final token = await user.getIdToken();
      await _secureStorage.saveAuthToken(token, expiryMinutes: AppConstants.sessionTimeoutMinutes);

      // إنشاء نموذج المستخدم
      final data = doc.data() as Map<String, dynamic>;
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        name: data['name'] ?? data['displayName'] ?? '',
        phone: data['phone'],
        role: data['role'] ?? 'customer',
        photoUrl: user.photoURL,
      );
      await _secureStorage.saveUserData(userModel.toJson());
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'حدث خطأ غير متوقع: $e',
        stackTrace: e,
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      if (!_isStrongPassword(password)) {
        return Left(const ValidationFailure(
          message: 'كلمة المرور غير قوية بما فيه الكفاية',
          errors: {},
        ));
      }
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Left(const AuthFailure(
          message: 'فشل إنشاء الحساب: لم يتم إنشاء المستخدم',
          code: 'USER_NOT_CREATED',
        ));
      }
      // إنشاء وثيقة جديدة
      final now = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'createdAt': now,
        'updatedAt': now,
      });
      await user.updateDisplayName(name);
      final token = await user.getIdToken();
      await _secureStorage.saveAuthToken(token, expiryMinutes: AppConstants.sessionTimeoutMinutes);

      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        phone: phone,
        role: 'customer',
        photoUrl: user.photoURL,
      );
      await _secureStorage.saveUserData(userModel.toJson());
      await user.sendEmailVerification();
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'حدث خطأ غير متوقع: $e',
        stackTrace: e,
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(const AuthFailure(
          message: 'تم إلغاء تسجيل الدخول بواسطة المستخدم',
          code: 'SIGN_IN_CANCELLED',
        ));
      }
      final auth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final userCred = await _firebaseAuth.signInWithCredential(credential);
      final user = userCred.user!;
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      final token = await user.getIdToken();
      await _secureStorage.saveAuthToken(token, expiryMinutes: AppConstants.sessionTimeoutMinutes);
      final data = (await docRef.get()).data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson({
        'id': user.uid,
        ...data,
      });
      await _secureStorage.saveUserData(userModel.toJson());
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'فشل تسجيل الدخول باستخدام Google: $e',
        stackTrace: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تسجيل الخروج: $e',
        code: 'SIGN_OUT_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        final data = await _secureStorage.getUserData();
        if (data != null) return Right(UserModel.fromJson(data));
        return const Right(null);
      }
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return const Left(AuthFailure(
          message: 'لم يتم العثور على بيانات المستخدم',
          code: 'USER_DATA_NOT_FOUND',
        ));
      }
      final userData = doc.data() as Map<String, dynamic>;
      final model = UserModel.fromJson({
        'id': user.uid,
        ...userData,
      });
      await _secureStorage.saveUserData(model.toJson());
      return Right(model);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل الحصول على المستخدم الحالي: $e',
        code: 'GET_CURRENT_USER_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل إعادة تعيين كلمة المرور: $e',
        code: 'RESET_PASSWORD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserData(UserModel user) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure(
          message: 'يجب تسجيل الدخول لتحديث البيانات',
          code: 'USER_NOT_AUTHENTICATED',
        ));
      }
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'phone': user.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _secureStorage.saveUserData(user.toJson());
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تحديث بيانات المستخدم: $e',
        code: 'UPDATE_USER_DATA_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return const Left(AuthFailure(
          message: 'يجب تسجيل الدخول لتحديث كلمة المرور',
          code: 'USER_NOT_AUTHENTICATED',
        ));
      }
      if (!_isStrongPassword(newPassword)) {
        return Left(const ValidationFailure(
          message: 'كلمة المرور غير قوية بما فيه الكفاية',
          errors: {},
        ));
      }
      final cred = firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تحديث كلمة المرور: $e',
        code: 'UPDATE_PASSWORD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyAuthToken() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) return const Right(false);
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        await _secureStorage.deleteAuthToken();
        return const Right(false);
      }
      final newToken = await user.getIdToken(true);
      await _secureStorage.saveAuthToken(newToken, expiryMinutes: AppConstants.sessionTimeoutMinutes);
      return const Right(true);
    } catch (_) {
      await _secureStorage.deleteAuthToken();
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, String>> getUserRole() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure(
          message: 'يجب تسجيل الدخول للحصول على الدور',
          code: 'USER_NOT_AUTHENTICATED',
        ));
      }
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return const Left(AuthFailure(
          message: 'لم يتم العثور على بيانات المستخدم',
          code: 'USER_DATA_NOT_FOUND',
        ));
      }
      final role = (doc.data() ?? {})['role'] as String? ?? 'customer';
      return Right(role);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل الحصول على دور المستخدم: $

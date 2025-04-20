import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

/// تنفيذ مستودع المصادقة
/// يطبق واجهة AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final SecureStorageService _secureStorage;

  /// منشئ مستودع المصادقة
  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
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
      // تسجيل الدخول باستخدام Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return const Left(AuthFailure(
          message: 'فشل تسجيل الدخول: لم يتم العثور على المستخدم',
          code: 'USER_NOT_FOUND',
        ));
      }

      // الحصول على بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return const Left(AuthFailure(
          message: 'فشل تسجيل الدخول: لم يتم العثور على بيانات المستخدم',
          code: 'USER_DATA_NOT_FOUND',
        ));
      }

      // حفظ رمز المصادقة
      final token = await userCredential.user!.getIdToken();
      await _secureStorage.saveAuthToken(token);

      // إنشاء نموذج المستخدم
      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userData['name'] ?? '',
        phone: userData['phone'],
        role: userData['role'] ?? 'customer',
        photoUrl: userCredential.user!.photoURL,
      );

      // حفظ بيانات المستخدم في التخزين الآمن
      await _secureStorage.saveUserData(userModel.toJson());

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تسجيل الدخول: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
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
      // إنشاء حساب جديد باستخدام Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return const Left(AuthFailure(
          message: 'فشل إنشاء الحساب: لم يتم إنشاء المستخدم',
          code: 'USER_NOT_CREATED',
        ));
      }

      // إنشاء بيانات المستخدم في Firestore
      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // حفظ رمز المصادقة
      final token = await userCredential.user!.getIdToken();
      await _secureStorage.saveAuthToken(token);

      // إنشاء نموذج المستخدم
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: 'customer',
        photoUrl: null,
      );

      // حفظ بيانات المستخدم في التخزين الآمن
      await _secureStorage.saveUserData(userModel.toJson());

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل إنشاء الحساب: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      // تسجيل الدخول باستخدام Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure(
          message: 'تم إلغاء تسجيل الدخول بواسطة المستخدم',
          code: 'SIGN_IN_CANCELLED',
        ));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول إلى Firebase باستخدام بيانات اعتماد Google
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return const Left(AuthFailure(
          message: 'فشل تسجيل الدخول: لم يتم العثور على المستخدم',
          code: 'USER_NOT_FOUND',
        ));
      }

      // التحقق مما إذا كان المستخدم موجودًا بالفعل في Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // إنشاء مستخدم جديد في Firestore إذا لم يكن موجودًا
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // حفظ رمز المصادقة
      final token = await user.getIdToken();
      await _secureStorage.saveAuthToken(token);

      // الحصول على بيانات المستخدم من Firestore
      final userData = userDoc.exists
          ? userDoc.data() as Map<String, dynamic>
          : {'role': 'customer'};

      // إنشاء نموذج المستخدم
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        phone: userData['phone'],
        role: userData['role'] ?? 'customer',
        photoUrl: user.photoURL,
      );

      // حفظ بيانات المستخدم في التخزين الآمن
      await _secureStorage.saveUserData(userModel.toJson());

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تسجيل الدخول باستخدام Google: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // تسجيل الخروج من Firebase
      await _firebaseAuth.signOut();
      
      // تسجيل الخروج من Google إذا كان مسجلاً الدخول
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // حذف بيانات المستخدم من التخزين الآمن
      await _secureStorage.clearAll();
      
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تسجيل الخروج: ${e.toString()}',
        code: 'SIGN_OUT_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      // التحقق من المستخدم الحالي في Firebase
      final currentUser = _firebaseAuth.currentUser;
      
      if (currentUser == null) {
        // محاولة استرداد بيانات المستخدم من التخزين الآمن
        final userData = await _secureStorage.getUserData();
        if (userData != null) {
          return Right(UserModel.fromJson(userData));
        }
        return const Right(null);
      }
      
      // الحصول على بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) {
        return const Left(AuthFailure(
          message: 'لم يتم العثور على بيانات المستخدم',
          code: 'USER_DATA_NOT_FOUND',
        ));
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // إنشاء نموذج المستخدم
      final userModel = UserModel(
        id: currentUser.uid,
        email: currentUser.email!,
        name: userData['name'] ?? '',
        phone: userData['phone'],
        role: userData['role'] ?? 'customer',
        photoUrl: currentUser.photoURL,
      );
      
      // حفظ بيانات المستخدم في التخزين الآمن
      await _secureStorage.saveUserData(userModel.toJson());
      
      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل الحصول على المستخدم الحالي: ${e.toString()}',
        code: 'GET_CURRENT_USER_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل إعادة تعيين كلمة المرور: ${e.toString()}',
        code: 'RESET_PASSWORD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserData(UserModel user) async {
    try {
      // التحقق من المستخدم الحالي
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure(
          message: 'يجب تسجيل الدخول لتحديث البيانات',
          code: 'USER_NOT_AUTHENTICATED',
        ));
      }
      
      // تحديث بيانات المستخدم في Firestore
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'phone': user.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // حفظ بيانات المستخدم المحدثة في التخزين الآمن
      await _secureStorage.saveUserData(user.toJson());
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تحديث بيانات المستخدم: ${e.toString()}',
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
      // التحقق من المستخدم الحالي
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        return const Left(AuthFailure(
          message: 'يجب تسجيل الدخول لتحديث كلمة المرور',
          code: 'USER_NOT_AUTHENTICATED',
        ));
      }
      
      // إعادة المصادقة قبل تغيير كلمة المرور
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      
      await currentUser.reauthenticateWithCredential(credential);
      
      // تحديث كلمة المرور
      await currentUser.updatePassword(newPassword);
      
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل تحديث كلمة المرور: ${e.toString()}',
        code: 'UPDATE_PASSWORD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyAuthToken() async {
    try {
      // التحقق من وجود رمز المصادقة في التخزين الآمن
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        return const Right(false);
      }
      
      // التحقق من المستخدم الحالي في Firebase
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        // حذف الرمز غير الصالح
        await _secureStorage.deleteAuthToken();
        return const Right(false);
      }
      
      // تحديث الرمز
      final newToken = await currentUser.getIdToken(true);
      await _secureStorage.saveAuthToken(newToken);
      
      return const Right(true);
    } catch (e) {
      // في حالة حدوث خطأ، نعتبر الرمز غير صالح
      await _secureStorage.deleteAuthToken();
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, String>> getUserRole() async {
    try {
      // التحقق من المستخدم الحالي
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure(
          message: 'يجب تسجيل الدخول للحصول على الدور',
          code: 'USER_NOT_AUTHENTICATED',
        ));
      }
      
      // الحصول على بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) {
        return const Left(AuthFailure(
          message: 'لم يتم العثور على بيانات المستخدم',
          code: 'USER_DATA_NOT_FOUND',
        ));
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'] as String? ?? 'customer';
      
      return Right(role);
    } catch (e) {
      return Left(AuthFailure(
        message: 'فشل الحصول على دور المستخدم: ${e.toString()}',
        code: 'GET_USER_ROLE_ERROR',
      ));
    }
  }

  /// تحويل استثناءات Firebase Auth إلى كائنات Failure
  Failure _mapFirebaseAuthExceptionToFailure(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'لم يتم العثور على المستخدم',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'كلمة المرور غير صحيحة',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'البريد الإلكتروني مستخدم بالفعل',
          code: 'EMAIL_ALREADY_IN_USE',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'كلمة المرور ضعيفة جدًا',
          code: 'WEAK_PASSWORD',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'البريد الإلكتروني غير صالح',
          code: 'INVALID_EMAIL',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'العملية غير مسموح بها',
          code: 'OPERATION_NOT_ALLOWED',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'تم تجاوز عدد المحاولات المسموح بها، يرجى المحاولة لاحقًا',
          code: 'TOO_MANY_REQUESTS',
        );
      case 'network-request-failed':
        return const NetworkFailure(
          message: 'فشل طلب الشبكة، يرجى التحقق من اتصالك بالإنترنت',
          code: 'NETWORK_REQUEST_FAILED',
        );
      default:
        return AuthFailure(
          message: 'حدث خطأ: ${e.message}',
          code: e.code,
        );
    }
  }
}

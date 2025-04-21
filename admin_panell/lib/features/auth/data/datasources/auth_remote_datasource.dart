// مصدر البيانات البعيد للمصادقة في طبقة Data
// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

/// واجهة مصدر البيانات البعيد للمصادقة
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserModel> signIn({required String email, required String password});

  /// تسجيل الخروج
  Future<void> signOut();

  /// الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser();
}

/// تنفيذ مصدر البيانات البعيد للمصادقة باستخدام Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      // تسجيل الدخول باستخدام Firebase Auth
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException('فشل تسجيل الدخول: لم يتم العثور على المستخدم');
      }

      // الحصول على بيانات المستخدم من Firestore
      final userId = userCredential.user!.uid;
      final userDoc = await firestore.collection('admins').doc(userId).get();

      if (!userDoc.exists) {
        // إذا لم يكن المستخدم موجودًا في مجموعة المشرفين، قم بتسجيل الخروج وإلقاء استثناء
        await firebaseAuth.signOut();
        throw AuthException('ليس لديك صلاحية الوصول كمشرف');
      }

      // إنشاء نموذج المستخدم من بيانات Firestore
      return UserModel(
        id: userId,
        email: email,
        name: userDoc.data()?['name'] ?? 'مشرف',
        role: userDoc.data()?['role'] ?? 'admin',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthErrorToMessage(e.code));
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('فشل تسجيل الدخول: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('فشل تسجيل الخروج: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      // التحقق من أن المستخدم هو مشرف
      final userDoc =
          await firestore.collection('admins').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // إذا لم يكن المستخدم موجودًا في مجموعة المشرفين، قم بتسجيل الخروج
        await firebaseAuth.signOut();
        return null;
      }

      // إنشاء نموذج المستخدم من بيانات Firestore
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: userDoc.data()?['name'] ?? 'مشرف',
        role: userDoc.data()?['role'] ?? 'admin',
      );
    } catch (e) {
      return null;
    }
  }

  // تحويل رموز أخطاء Firebase Auth إلى رسائل مفهومة
  String _mapFirebaseAuthErrorToMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم حظر الوصول بسبب محاولات متكررة. يرجى المحاولة لاحقًا';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بالبريد الإلكتروني وكلمة المرور غير مفعل';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جدًا';
      default:
        return 'حدث خطأ أثناء المصادقة: $errorCode';
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

/// واجهة مستودع المصادقة
/// تعريف جميع العمليات المتعلقة بالمصادقة في النظام
abstract class AuthRepository {
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  /// تسجيل الدخول باستخدام حساب Google
  Future<Either<Failure, UserModel>> signInWithGoogle();

  /// تسجيل الخروج
  Future<Either<Failure, void>> signOut();

  /// الحصول على المستخدم الحالي
  Future<Either<Failure, UserModel?>> getCurrentUser();

  /// إعادة تعيين كلمة المرور
  Future<Either<Failure, void>> resetPassword(String email);

  /// تحديث بيانات المستخدم
  Future<Either<Failure, UserModel>> updateUserData(UserModel user);

  /// تحديث كلمة المرور
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// التحقق من صلاحية رمز المصادقة
  Future<Either<Failure, bool>> verifyAuthToken();

  /// التحقق من دور المستخدم وصلاحياته
  Future<Either<Failure, String>> getUserRole();
}

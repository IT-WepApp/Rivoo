import '../entities/user.dart';
import '../../../../core/architecture/domain/failure.dart';

/// واجهة مستودع المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<Either<Failure, User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// تسجيل الخروج
  Future<Either<Failure, void>> signOut();

  /// تسجيل الدخول باستخدام حساب جوجل
  Future<Either<Failure, User>> signInWithGoogle();

  /// إعادة تعيين كلمة المرور
  Future<Either<Failure, void>> resetPassword(String email);

  /// التحقق من صحة رمز المصادقة
  Future<Either<Failure, bool>> validateToken(String token);

  /// تحديث بيانات المستخدم
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  });

  /// تغيير كلمة المرور
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

/// نوع Either للتعامل مع النجاح والفشل
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isRight;

  const Either._(this._left, this._right, this.isRight);

  factory Either.left(L value) => Either._(value, null, false);
  factory Either.right(R value) => Either._(null, value, true);

  L get left => _left as L;
  R get right => _right as R;

  bool get isLeft => !isRight;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return isRight ? onRight(right) : onLeft(left);
  }
}

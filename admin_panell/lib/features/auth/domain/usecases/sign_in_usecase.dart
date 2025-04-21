import '../entities/user.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام تسجيل الدخول
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User> execute({required String email, required String password}) async {
    // يمكن إضافة منطق أعمال إضافي هنا قبل استدعاء المستودع
    if (email.isEmpty || password.isEmpty) {
      throw Exception('البريد الإلكتروني وكلمة المرور مطلوبان');
    }

    if (!email.contains('@')) {
      throw Exception('البريد الإلكتروني غير صالح');
    }

    if (password.length < 6) {
      throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    final userEntity = await repository.signIn(email, password);
    return User.fromEntity(userEntity);
  }
}

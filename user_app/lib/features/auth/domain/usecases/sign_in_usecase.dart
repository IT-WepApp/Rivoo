import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/architecture/domain/failure.dart';
import 'package:shared_libs/core/architecture/domain/usecase.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';
import 'package:shared_libs/models/user_model.dart';

/// معلمات تسجيل الدخول
class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}

/// حالة استخدام تسجيل الدخول
/// تطبق واجهة UseCase من العمارة النظيفة
class SignInUseCase implements UseCase<UserModel, SignInParams> {
  final AuthRepository _authRepository;

  /// منشئ حالة استخدام تسجيل الدخول
  SignInUseCase(this._authRepository);

  @override
  Future<Either<Failure, UserModel>> call(SignInParams params) async {
    // التحقق من صحة المدخلات
    if (params.email.isEmpty) {
      return const Left(ValidationFailure(
        message: 'البريد الإلكتروني مطلوب',
        code: 'EMPTY_EMAIL',
      ));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure(
        message: 'كلمة المرور مطلوبة',
        code: 'EMPTY_PASSWORD',
      ));
    }

    // استدعاء المستودع لتنفيذ عملية تسجيل الدخول
    return _authRepository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

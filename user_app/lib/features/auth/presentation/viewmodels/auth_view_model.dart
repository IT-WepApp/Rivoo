import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/core/architecture/domain/usecase.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

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
class SignInUseCase implements UseCase<UserModel, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<Either<Failure, UserModel>> call(SignInParams params) async {
    if (params.email.isEmpty) {
      return Left(ValidationFailure(
        message: 'البريد الإلكتروني مطلوب',
        code: 'EMPTY_EMAIL',
      ));
    }
    if (params.password.isEmpty) {
      return Left(ValidationFailure(
        message: 'كلمة المرور مطلوبة',
        code: 'EMPTY_PASSWORD',
      ));
    }
    return _authRepository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// معلمات إنشاء حساب جديد
class SignUpParams {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

/// حالة استخدام إنشاء حساب جديد
class SignUpUseCase implements UseCase<UserModel, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<Either<Failure, UserModel>> call(SignUpParams params) {
    return _authRepository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

/// حالة استخدام تسجيل الخروج
class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _authRepository.signOut();
  }
}

/// معلمات إعادة تعيين كلمة المرور
class ResetPasswordParams {
  final String email;

  const ResetPasswordParams({
    required this.email,
  });
}

/// حالة استخدام إعادة تعيين كلمة المرور
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(params.email);
  }
}

/// حالة استخدام التحقق من حالة المصادقة
class IsAuthenticatedUseCase implements UseCase<bool, NoParams> {
  final AuthRepository _authRepository;

  IsAuthenticatedUseCase(this._authRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _authRepository.verifyAuthToken();
  }
}

/// حالة استخدام الحصول على المستخدم الحالي
class GetCurrentUserUseCase implements UseCase<UserModel?, NoParams> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<Either<Failure, UserModel?>> call(NoParams params) {
    return _authRepository.getCurrentUser();
  }
}

/// معلمات تحديث بيانات المستخدم
class UpdateUserDataParams {
  final UserModel user;

  const UpdateUserDataParams({
    required this.user,
  });
}

/// حالة استخدام تحديث بيانات المستخدم
class UpdateUserDataUseCase
    implements UseCase<UserModel, UpdateUserDataParams> {
  final AuthRepository _authRepository;

  UpdateUserDataUseCase(this._authRepository);

  @override
  Future<Either<Failure, UserModel>> call(UpdateUserDataParams params) {
    return _authRepository.updateUserData(params.user);
  }
}

/// معلمات تحديث كلمة المرور
class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

/// حالة استخدام تحديث كلمة المرور
class UpdatePasswordUseCase implements UseCase<void, UpdatePasswordParams> {
  final AuthRepository _authRepository;

  UpdatePasswordUseCase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) {
    return _authRepository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

/// معلمات حذف الحساب
class DeleteAccountParams {
  final String password;

  const DeleteAccountParams({
    required this.password,
  });
}

/// حالة استخدام حذف الحساب
class DeleteAccountUseCase implements UseCase<void, DeleteAccountParams> {
  final AuthRepository _authRepository;

  DeleteAccountUseCase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) {
    return _authRepository.deleteAccount(params.password);
  }
}

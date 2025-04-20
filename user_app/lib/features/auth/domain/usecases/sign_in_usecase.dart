import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/core/architecture/domain/usecase.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';

/// حالة استخدام تسجيل الدخول
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository _authRepository;
  
  SignInUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return _authRepository.signIn(params.email, params.password);
  }
}

/// معلمات تسجيل الدخول
class SignInParams {
  final String email;
  final String password;
  
  SignInParams({
    required this.email,
    required this.password,
  });
}

/// حالة استخدام إنشاء حساب جديد
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _authRepository;
  
  SignUpUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return _authRepository.signUp(params.email, params.password, params.name);
  }
}

/// معلمات إنشاء حساب جديد
class SignUpParams {
  final String email;
  final String password;
  final String name;
  
  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
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

/// حالة استخدام إعادة تعيين كلمة المرور
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _authRepository;
  
  ResetPasswordUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(params.email);
  }
}

/// معلمات إعادة تعيين كلمة المرور
class ResetPasswordParams {
  final String email;
  
  ResetPasswordParams({
    required this.email,
  });
}

/// حالة استخدام التحقق من حالة المصادقة
class IsAuthenticatedUseCase implements UseCase<bool, NoParams> {
  final AuthRepository _authRepository;
  
  IsAuthenticatedUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _authRepository.isAuthenticated();
  }
}

/// حالة استخدام الحصول على المستخدم الحالي
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _authRepository;
  
  GetCurrentUserUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return _authRepository.getCurrentUser();
  }
}

/// حالة استخدام تحديث بيانات المستخدم
class UpdateUserProfileUseCase implements UseCase<UserEntity, UpdateUserProfileParams> {
  final AuthRepository _authRepository;
  
  UpdateUserProfileUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserProfileParams params) {
    return _authRepository.updateUserProfile(params.user);
  }
}

/// معلمات تحديث بيانات المستخدم
class UpdateUserProfileParams {
  final UserEntity user;
  
  UpdateUserProfileParams({
    required this.user,
  });
}

/// حالة استخدام تحديث كلمة المرور
class UpdatePasswordUseCase implements UseCase<void, UpdatePasswordParams> {
  final AuthRepository _authRepository;
  
  UpdatePasswordUseCase(this._authRepository);
  
  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) {
    return _authRepository.updatePassword(params.currentPassword, params.newPassword);
  }
}

/// معلمات تحديث كلمة المرور
class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;
  
  UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
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

/// معلمات حذف الحساب
class DeleteAccountParams {
  final String password;
  
  DeleteAccountParams({
    required this.password,
  });
}

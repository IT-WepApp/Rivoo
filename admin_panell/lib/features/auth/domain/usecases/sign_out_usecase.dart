// حالات الاستخدام (Use Cases) في طبقة Domain
// lib/features/auth/domain/usecases/sign_out_usecase.dart

import '../repositories/auth_repository.dart';

/// حالة استخدام تسجيل الخروج
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() {
    return repository.signOut();
  }
}

// حالات الاستخدام (Use Cases) في طبقة Domain
// lib/features/auth/domain/usecases/is_signed_in_usecase.dart

import '../repositories/auth_repository.dart';

/// حالة استخدام التحقق مما إذا كان المستخدم مسجل الدخول
class IsSignedInUseCase {
  final AuthRepository repository;

  IsSignedInUseCase(this.repository);

  Future<bool> execute() {
    return repository.isSignedIn();
  }
}

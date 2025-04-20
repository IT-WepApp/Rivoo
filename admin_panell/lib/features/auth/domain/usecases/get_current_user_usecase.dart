// حالات الاستخدام (Use Cases) في طبقة Domain
// lib/features/auth/domain/usecases/get_current_user_usecase.dart

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام الحصول على المستخدم الحالي
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> execute() {
    return repository.getCurrentUser();
  }
}

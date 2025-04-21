// حالات الاستخدام (Use Cases) في طبقة Domain
// lib/features/auth/domain/usecases/get_current_user_usecase.dart

import '../entities/user_entity.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام الحصول على المستخدم الحالي
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> execute() async {
    final userEntity = await repository.getCurrentUser();
    if (userEntity == null) {
      return null;
    }
    return User.fromEntity(userEntity);
  }
}

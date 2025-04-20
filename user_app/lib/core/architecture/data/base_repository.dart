import 'package:user_app/core/architecture/domain/entity.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:dartz/dartz.dart';

/// واجهة المستودع الأساسية التي يجب أن تنفذها جميع المستودعات
/// تتبع نمط المستودع من العمارة النظيفة
abstract class BaseRepository<T extends Entity> {
  /// الحصول على كيان حسب المعرف
  Future<Either<Failure, T>> getById(String id);
  
  /// الحصول على قائمة من الكيانات
  Future<Either<Failure, List<T>>> getAll();
  
  /// إضافة كيان جديد
  Future<Either<Failure, T>> add(T entity);
  
  /// تحديث كيان موجود
  Future<Either<Failure, T>> update(T entity);
  
  /// حذف كيان حسب المعرف
  Future<Either<Failure, bool>> delete(String id);
}

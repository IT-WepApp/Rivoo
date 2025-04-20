import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/core/architecture/domain/entity.dart';

/// واجهة المستودع الأساسية
/// تحدد العمليات الأساسية التي يجب أن تنفذها جميع المستودعات
abstract class BaseRepository<T extends Entity> {
  /// الحصول على كيان بواسطة المعرف
  Future<Either<Failure, T>> getById(String id);
  
  /// الحصول على قائمة من الكيانات
  Future<Either<Failure, List<T>>> getAll();
  
  /// إضافة كيان جديد
  Future<Either<Failure, T>> add(T entity);
  
  /// تحديث كيان موجود
  Future<Either<Failure, T>> update(T entity);
  
  /// حذف كيان بواسطة المعرف
  Future<Either<Failure, bool>> delete(String id);
  
  /// البحث عن كيانات باستخدام معايير محددة
  Future<Either<Failure, List<T>>> search(Map<String, dynamic> criteria);
}

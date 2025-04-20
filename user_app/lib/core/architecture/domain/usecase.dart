import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

/// حالة الاستخدام الأساسية
/// تمثل عملية أو إجراء يمكن للمستخدم القيام به في التطبيق
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// معلمات فارغة للحالات التي لا تتطلب معلمات
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

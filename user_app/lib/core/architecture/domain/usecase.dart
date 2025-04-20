import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

/// واجهة حالة الاستخدام الأساسية
/// تتبع مبدأ المسؤولية الواحدة من مبادئ SOLID
/// كل حالة استخدام تمثل عملية واحدة محددة في النظام
abstract class UseCase<Type, Params> {
  /// تنفيذ حالة الاستخدام
  /// تعيد إما فشل (Failure) أو نتيجة ناجحة من النوع المحدد (Type)
  Future<Either<Failure, Type>> call(Params params);
}

/// واجهة حالة الاستخدام التي تعمل في الوقت الفعلي (Stream)
abstract class StreamUseCase<Type, Params> {
  /// تنفيذ حالة الاستخدام التي تعيد تدفق من البيانات
  Stream<Either<Failure, Type>> call(Params params);
}

/// حالة استخدام لا تحتاج إلى معلمات
abstract class NoParamsUseCase<Type> {
  /// تنفيذ حالة الاستخدام بدون معلمات
  Future<Either<Failure, Type>> call();
}

/// حالة استخدام تدفق بدون معلمات
abstract class NoParamsStreamUseCase<Type> {
  /// تنفيذ حالة الاستخدام بدون معلمات
  Stream<Either<Failure, Type>> call();
}

/// فئة تمثل عدم وجود معلمات لحالة الاستخدام
/// تستخدم Equatable لدعم المقارنة بين الحالات
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
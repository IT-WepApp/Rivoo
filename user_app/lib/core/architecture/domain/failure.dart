import 'package:equatable/equatable.dart';

/// فئة الفشل الأساسية
/// تمثل أخطاء المجال التي يمكن أن تحدث أثناء تنفيذ العمليات
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic stackTrace;
  
  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// فشل الشبكة
/// يحدث عند وجود مشاكل في الاتصال بالإنترنت
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    dynamic stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
}

/// فشل الخادم
/// يحدث عند وجود مشاكل في الخادم
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
}

/// فشل التحقق من الصحة
/// يحدث عند وجود مشاكل في التحقق من صحة البيانات
class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  
  const ValidationFailure({
    required String message,
    this.errors,
    String? code,
    dynamic stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
  
  @override
  List<Object?> get props => [message, code, errors];
}

/// فشل المصادقة
/// يحدث عند وجود مشاكل في المصادقة
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
    dynamic stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
}

/// فشل التخزين
/// يحدث عند وجود مشاكل في التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    dynamic stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
}

/// فشل غير متوقع
/// يحدث عند وجود مشاكل غير متوقعة
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required String message,
    String? code,
    dynamic stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
}

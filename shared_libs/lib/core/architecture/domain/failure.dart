import 'package:equatable/equatable.dart';

/// فئة أساسية للأخطاء في التطبيق
abstract class Failure extends Equatable {
  /// رسالة الخطأ الوصفية
  final String message;

  /// رمز الخطأ (قد يكون HTTP status code أو رمز داخلي)
  final int? code;

  /// بيانات إضافية توضيحية (اختياري)
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() =>
      'Failure(message: $message, code: $code, details: $details)';
}

/// فشل في الاتصال بالشبكة
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    int? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// فشل في المصادقة
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    int? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// فشل في الخادم
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// فشل في التخزين المحلي (الكاش)
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    int? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// فشل تحقق (Validation)
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    int? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// فشل غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required String message,
    int? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

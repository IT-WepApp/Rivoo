/// فئة الفشل الأساسية التي تمثل أي خطأ في النظام
/// تستخدم مع Either من مكتبة dartz لتمثيل نتائج العمليات
abstract class Failure {
  /// رسالة الخطأ
  final String message;
  
  /// رمز الخطأ (اختياري)
  final String? code;
  
  /// منشئ فئة الفشل الأساسية
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// فشل الشبكة (مثل عدم الاتصال بالإنترنت)
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل الخادم (مثل خطأ 500)
class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure({
    required String message,
    String? code,
    this.statusCode,
  }) : super(message: message, code: code);
  
  @override
  String toString() => 'ServerFailure(message: $message, code: $code, statusCode: $statusCode)';
}

/// فشل المصادقة (مثل انتهاء صلاحية الجلسة)
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل التحقق من الصلاحيات
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل التحقق من المدخلات
class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  
  const ValidationFailure({
    required String message,
    String? code,
    this.errors,
  }) : super(message: message, code: code);
  
  @override
  String toString() => 'ValidationFailure(message: $message, code: $code, errors: $errors)';
}

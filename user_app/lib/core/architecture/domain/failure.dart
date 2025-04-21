import 'package:equatable/equatable.dart';

/// فئة الفشل الأساسية التي تمثل أي خطأ في النظام
/// تستخدم مع Either من مكتبة dartz لتمثيل نتائج العمليات
abstract class Failure extends Equatable {
  /// رسالة الخطأ
  final String message;

  /// رمز الخطأ (اختياري)
  final String? code;

  /// أثر الخطأ (اختياري)
  final dynamic stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code];
}

/// فشل الشبكة (مثل عدم الاتصال بالإنترنت)
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

/// فشل الخادم (مثل خطأ 500)
class ServerFailure extends Failure {
  /// رمز الحالة HTTP (اختياري)
  final int? statusCode;

  const ServerFailure({
    required String message,
    String? code,
    this.statusCode,
    dynamic stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// فشل التحقق من المدخلات
class ValidationFailure extends Failure {
  /// تفاصيل أخطاء التحقق (اختياري)
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

/// فشل المصادقة (مثل انتهاء صلاحية الجلسة)
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

/// فشل الصلاحيات (مثل رفض الوصول)
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
    dynamic stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// فشل التخزين المحلي (مثل مشكلات الكاش)
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

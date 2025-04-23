import 'package:equatable/equatable.dart';

/// فئة أساسية للأخطاء في التطبيق
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// فشل في الاتصال بالشبكة
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

/// فشل في المصادقة
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

/// فشل في الخادم
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

/// فشل في قاعدة البيانات المحلية
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

/// فشل غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

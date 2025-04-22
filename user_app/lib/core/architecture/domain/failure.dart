abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code, details: $details)';
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

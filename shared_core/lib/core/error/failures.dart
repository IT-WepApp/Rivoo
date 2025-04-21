import 'package:equatable/equatable.dart';

/// فئة أساسية مجردة لجميع أنواع الفشل في التطبيق
///
/// تستخدم كنوع أساسي لجميع فئات الفشل المحددة
/// وتسمح بالتعامل مع الأخطاء بطريقة موحدة في جميع أنحاء التطبيق
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

/// فشل متعلق بالخادم
///
/// يستخدم عندما تحدث مشكلة في الاتصال بالخادم أو عندما يعيد الخادم استجابة خاطئة
class ServerFailure extends Failure {
  final String? message;

  const ServerFailure({this.message});

  @override
  List<Object?> get props => [message];
}

/// فشل غير متوقع
///
/// يستخدم للأخطاء غير المتوقعة أو غير المعروفة التي لا تندرج تحت فئات الفشل الأخرى
class UnexpectedFailure extends Failure {
  final String? message;

  const UnexpectedFailure({this.message});

  @override
  List<Object?> get props => [message];
}

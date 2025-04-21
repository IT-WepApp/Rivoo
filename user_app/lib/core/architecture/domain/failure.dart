/// فئة الفشل الأساسية التي تمثل أخطاء النظام
/// 
/// هذه الفئة المجردة هي الأساس لجميع أنواع الفشل في التطبيق
/// يجب أن تمتد جميع فئات الفشل المحددة من هذه الفئة
abstract class Failure {
  /// رسالة الخطأ
  final String message;
  
  /// رمز الخطأ
  final String? code;

  /// إنشاء كائن فشل جديد
  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// فشل الشبكة
/// 
/// يستخدم عندما تفشل عمليات الشبكة مثل طلبات HTTP
class NetworkFailure extends Failure {
  /// إنشاء كائن فشل شبكة جديد
  const NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل الخادم
/// 
/// يستخدم عندما يستجيب الخادم بخطأ
class ServerFailure extends Failure {
  /// رمز حالة HTTP
  final int? statusCode;

  /// إنشاء كائن فشل خادم جديد
  const ServerFailure({
    required String message,
    String? code,
    this.statusCode,
  }) : super(message: message, code: code);

  @override
  String toString() => 'ServerFailure(message: $message, code: $code, statusCode: $statusCode)';
}

/// فشل التحقق من الصحة
/// 
/// يستخدم عندما تفشل عمليات التحقق من صحة البيانات
class ValidationFailure extends Failure {
  /// حقل البيانات الذي فشل التحقق من صحته
  final String? field;

  /// إنشاء كائن فشل تحقق من الصحة جديد
  const ValidationFailure({
    required String message,
    String? code,
    this.field,
  }) : super(message: message, code: code);

  @override
  String toString() => 'ValidationFailure(message: $message, code: $code, field: $field)';
}

/// فشل المصادقة
/// 
/// يستخدم عندما تفشل عمليات المصادقة
class AuthFailure extends Failure {
  /// إنشاء كائن فشل مصادقة جديد
  const AuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل غير متوقع
/// 
/// يستخدم للأخطاء غير المتوقعة أو غير المعروفة
class UnexpectedFailure extends Failure {
  /// الاستثناء الأصلي
  final Object? exception;

  /// إنشاء كائن فشل غير متوقع جديد
  const UnexpectedFailure({
    required String message,
    String? code,
    this.exception,
  }) : super(message: message, code: code);

  @override
  String toString() => 'UnexpectedFailure(message: $message, code: $code, exception: $exception)';
}

/// فشل عدم العثور
/// 
/// يستخدم عندما لا يتم العثور على مورد مطلوب
class NotFoundFailure extends Failure {
  /// معرف المورد الذي لم يتم العثور عليه
  final String? resourceId;
  
  /// نوع المورد الذي لم يتم العثور عليه
  final String? resourceType;

  /// إنشاء كائن فشل عدم العثور جديد
  const NotFoundFailure({
    required String message,
    String? code,
    this.resourceId,
    this.resourceType,
  }) : super(message: message, code: code);

  @override
  String toString() => 'NotFoundFailure(message: $message, code: $code, resourceId: $resourceId, resourceType: $resourceType)';
}

/// فشل الإذن
/// 
/// يستخدم عندما لا يملك المستخدم الإذن المطلوب للوصول إلى مورد
class PermissionFailure extends Failure {
  /// إنشاء كائن فشل إذن جديد
  const PermissionFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// فشل التخزين المحلي
/// 
/// يستخدم عندما تفشل عمليات التخزين المحلي
class CacheFailure extends Failure {
  /// إنشاء كائن فشل تخزين محلي جديد
  const CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

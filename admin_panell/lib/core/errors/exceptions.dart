/// استثناء الخادم
///
/// يتم إلقاء هذا الاستثناء عندما يحدث خطأ في الاتصال بالخادم
class ServerException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// رمز الخطأ
  final String code;
  
  /// إنشاء استثناء جديد للخادم
  const ServerException({
    required this.message,
    required this.code,
  });
  
  @override
  String toString() => 'ServerException: [$code] $message';
}

/// استثناء التخزين المحلي
///
/// يتم إلقاء هذا الاستثناء عندما يحدث خطأ في التخزين المحلي
class CacheException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// إنشاء استثناء جديد للتخزين المحلي
  const CacheException({
    required this.message,
  });
  
  @override
  String toString() => 'CacheException: $message';
}

/// استثناء المصادقة
///
/// يتم إلقاء هذا الاستثناء عندما يحدث خطأ في عملية المصادقة
class AuthException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// إنشاء استثناء جديد للمصادقة
  const AuthException({
    required this.message,
  });
  
  @override
  String toString() => 'AuthException: $message';
}

/// استثناء الإدخال
///
/// يتم إلقاء هذا الاستثناء عندما يكون هناك خطأ في البيانات المدخلة
class InputException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// إنشاء استثناء جديد للإدخال
  const InputException({
    required this.message,
  });
  
  @override
  String toString() => 'InputException: $message';
}

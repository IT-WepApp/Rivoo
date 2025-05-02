/// استثناءات التطبيق
///
/// هذا الملف يحتوي على تعريفات الاستثناءات المستخدمة في التطبيق

/// استثناء الخادم
///
/// يتم رفع هذا الاستثناء عند حدوث خطأ في الاتصال بالخادم
class ServerException implements Exception {
  final String message;

  ServerException({this.message = 'حدث خطأ في الخادم'});

  @override
  String toString() => message;
}

/// استثناء التخزين المحلي
///
/// يتم رفع هذا الاستثناء عند حدوث خطأ في التخزين المحلي
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'حدث خطأ في التخزين المحلي'});

  @override
  String toString() => message;
}

/// استثناء المصادقة
///
/// يتم رفع هذا الاستثناء عند حدوث خطأ في عملية المصادقة
class AuthException implements Exception {
  final String message;

  AuthException({this.message = 'حدث خطأ في المصادقة'});

  @override
  String toString() => message;
}

/// استثناء عدم وجود اتصال بالإنترنت
///
/// يتم رفع هذا الاستثناء عند عدم وجود اتصال بالإنترنت
class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'لا يوجد اتصال بالإنترنت'});

  @override
  String toString() => message;
}

/// استثناء عدم وجود البيانات
///
/// يتم رفع هذا الاستثناء عند عدم وجود البيانات المطلوبة
class NotFoundException implements Exception {
  final String message;

  NotFoundException({this.message = 'البيانات المطلوبة غير موجودة'});

  @override
  String toString() => message;
}

/// استثناء الإدخال غير الصالح
///
/// يتم رفع هذا الاستثناء عند إدخال بيانات غير صالحة
class InvalidInputException implements Exception {
  final String message;

  InvalidInputException({this.message = 'البيانات المدخلة غير صالحة'});

  @override
  String toString() => message;
}

/// استثناء عام
///
/// يتم رفع هذا الاستثناء عند حدوث خطأ غير متوقع
class UnexpectedException implements Exception {
  final String message;

  UnexpectedException({this.message = 'حدث خطأ غير متوقع'});

  @override
  String toString() => message;
}

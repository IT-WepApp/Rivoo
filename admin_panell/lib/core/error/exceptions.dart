/// استثناءات المشروع
/// 
/// هذا الملف يحتوي على تعريفات الاستثناءات المستخدمة في المشروع

/// استثناء الخادم
/// 
/// يتم رميه عندما يحدث خطأ في الاتصال بالخادم
class ServerException implements Exception {
  final String message;
  
  ServerException([this.message = 'حدث خطأ في الخادم']);
  
  @override
  String toString() => 'ServerException: $message';
}

/// استثناء التخزين المؤقت
/// 
/// يتم رميه عندما يحدث خطأ في التخزين المؤقت
class CacheException implements Exception {
  final String message;
  
  CacheException([this.message = 'حدث خطأ في التخزين المؤقت']);
  
  @override
  String toString() => 'CacheException: $message';
}

/// استثناء المصادقة
/// 
/// يتم رميه عندما يحدث خطأ في عملية المصادقة
class AuthException implements Exception {
  final String message;
  
  AuthException([this.message = 'حدث خطأ في المصادقة']);
  
  @override
  String toString() => 'AuthException: $message';
}

/// استثناء الشبكة
/// 
/// يتم رميه عندما يحدث خطأ في الاتصال بالشبكة
class NetworkException implements Exception {
  final String message;
  
  NetworkException([this.message = 'حدث خطأ في الاتصال بالشبكة']);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// استثناء عدم العثور
/// 
/// يتم رميه عندما لا يتم العثور على البيانات المطلوبة
class NotFoundException implements Exception {
  final String message;
  
  NotFoundException([this.message = 'لم يتم العثور على البيانات المطلوبة']);
  
  @override
  String toString() => 'NotFoundException: $message';
}

/// استثناء المدخلات غير الصالحة
/// 
/// يتم رميه عندما تكون المدخلات غير صالحة
class InvalidInputException implements Exception {
  final String message;
  
  InvalidInputException([this.message = 'المدخلات غير صالحة']);
  
  @override
  String toString() => 'InvalidInputException: $message';
}

/// استثناء غير متوقع
/// 
/// يتم رميه عندما يحدث خطأ غير متوقع
class UnexpectedException implements Exception {
  final String message;
  
  UnexpectedException([this.message = 'حدث خطأ غير متوقع']);
  
  @override
  String toString() => 'UnexpectedException: $message';
}

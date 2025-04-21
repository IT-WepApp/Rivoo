/// استثناء أساسي للخادم
///
/// يُستخدم عندما تحدث مشكلة في الاتصال بالخادم أو عندما يعيد الخادم استجابة خاطئة
/// مثل أخطاء HTTP 4xx أو 5xx
class ServerException implements Exception {
  final String? message;

  ServerException({this.message});

  @override
  String toString() => 'ServerException: $message';
}

/// استثناء للشبكة
///
/// يُستخدم عندما تكون هناك مشكلة في الاتصال بالإنترنت
class NetworkException implements Exception {
  final String? message;

  NetworkException({this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// استثناء للتخزين المؤقت
///
/// يُستخدم عندما تكون هناك مشكلة في قراءة أو كتابة البيانات في التخزين المؤقت
class CacheException implements Exception {
  final String? message;

  CacheException({this.message});

  @override
  String toString() => 'CacheException: $message';
}

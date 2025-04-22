import 'package:logger/logger.dart';

/// مكتبة تسجيل موحدة للتطبيق
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// تسجيل معلومات عادية
  void info(String message) {
    _logger.i(message);
  }

  /// تسجيل تحذير
  void warning(String message) {
    _logger.w(message);
  }

  /// تسجيل خطأ
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // استخدام الطريقة الصحيحة لتسجيل الأخطاء مع تمرير الخطأ وتتبع المكدس بشكل صحيح
    if (error != null || stackTrace != null) {
      _logger.e(message, error, stackTrace);
    } else {
      _logger.e(message);
    }
  }

  /// تسجيل معلومات تصحيح
  void debug(String message) {
    _logger.d(message);
  }

  /// تسجيل معلومات مفصلة
  void verbose(String message) {
    _logger.v(message);
  }
}

/// مثال للاستخدام:
/// ```dart
/// final logger = AppLogger();
/// logger.info('تم تسجيل الدخول بنجاح');
/// logger.error('فشل في الاتصال بالخادم', exception, stackTrace);
/// ```

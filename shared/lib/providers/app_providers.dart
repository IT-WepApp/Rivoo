import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/utils/logger.dart'; // تم تحديث المسار للمكتبة الجديدة

/// مزود لتجميع كل مزودي الحالة في التطبيق
class AppProviders {
  // منع إنشاء نسخ من الكلاس
  AppProviders._();

  /// إنشاء قائمة بكل المزودين المستخدمين في التطبيق
  static List<ProviderObserver> get observers => [
        LoggerProviderObserver(),
      ];
}

/// مراقب لتسجيل تغييرات الحالة في المزودين
class LoggerProviderObserver extends ProviderObserver {
  final AppLogger _logger = AppLogger();

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // يمكن تنفيذ تسجيل التغييرات هنا
     _logger.debug('Provider: ${provider.name ?? provider.runtimeType}');
     _logger.debug('Previous value: $previousValue');
     _logger.debug('New value: $newValue');
  }

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    // يمكن تسجيل إضافة مزود جديد هنا
     _logger.debug('Provider added: ${provider.name ?? provider.runtimeType}');
     _logger.debug('Value: $value');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    // يمكن تسجيل إزالة مزود هنا
     _logger.debug('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }
}

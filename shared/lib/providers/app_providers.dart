import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // يمكن تنفيذ تسجيل التغييرات هنا
    // print('Provider: ${provider.name ?? provider.runtimeType}');
    // print('Previous value: $previousValue');
    // print('New value: $newValue');
  }

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    // يمكن تسجيل إضافة مزود جديد هنا
    // print('Provider added: ${provider.name ?? provider.runtimeType}');
    // print('Value: $value');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    // يمكن تسجيل إزالة مزود هنا
    // print('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }
}

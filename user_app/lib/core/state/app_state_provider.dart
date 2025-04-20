import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// إنشاء ملف توليد الكود
part 'app_state_provider.g.dart';

/// مزود حالة التطبيق الرئيسي
/// يستخدم لإدارة الحالة العامة للتطبيق مثل الوضع الليلي واللغة
@Riverpod(keepAlive: true)
class AppState extends _$AppState {
  @override
  AppStateModel build() {
    return const AppStateModel(
      isDarkMode: false,
      locale: 'ar',
      isConnected: true,
    );
  }

  /// تحديث وضع السمة (فاتح/داكن)
  void updateThemeMode(bool isDarkMode) {
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  /// تحديث اللغة المحددة
  void updateLocale(String locale) {
    state = state.copyWith(locale: locale);
  }

  /// تحديث حالة الاتصال بالإنترنت
  void updateConnectionStatus(bool isConnected) {
    state = state.copyWith(isConnected: isConnected);
  }
}

/// نموذج بيانات حالة التطبيق
class AppStateModel {
  final bool isDarkMode;
  final String locale;
  final bool isConnected;

  const AppStateModel({
    required this.isDarkMode,
    required this.locale,
    required this.isConnected,
  });

  AppStateModel copyWith({
    bool? isDarkMode,
    String? locale,
    bool? isConnected,
  }) {
    return AppStateModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

/// مزود قراءة فقط لوضع السمة
@riverpod
bool isDarkMode(IsDarkModeRef ref) {
  return ref.watch(appStateProvider).isDarkMode;
}

/// مزود قراءة فقط للغة
@riverpod
String currentLocale(CurrentLocaleRef ref) {
  return ref.watch(appStateProvider).locale;
}

/// مزود قراءة فقط لحالة الاتصال
@riverpod
bool isConnected(IsConnectedRef ref) {
  return ref.watch(appStateProvider).isConnected;
}

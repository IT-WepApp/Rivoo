import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_app/features/settings/domain/repositories/settings_repository.dart';

/// مزود مستودع الإعدادات
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('يجب تهيئة مزود مستودع الإعدادات قبل استخدامه');
});

/// مزود وضع السمة
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ThemeModeNotifier(repository);
});

/// مزود اللغة
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return LocaleNotifier(repository);
});

/// مزود إعدادات الإشعارات
final notificationsEnabledProvider = StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return NotificationsEnabledNotifier(repository);
});

/// مزود إعدادات تحديد الموقع
final locationEnabledProvider = StateNotifierProvider<LocationEnabledNotifier, bool>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return LocationEnabledNotifier(repository);
});

/// مزود وحدة المسافة
final distanceUnitProvider = StateNotifierProvider<DistanceUnitNotifier, String>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return DistanceUnitNotifier(repository);
});

/// مدير حالة وضع السمة
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repository;

  ThemeModeNotifier(this._repository) : super(_repository.getThemeMode());

  /// تغيير وضع السمة
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _repository.setThemeMode(themeMode);
    state = themeMode;
  }
}

/// مدير حالة اللغة
class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _repository;

  LocaleNotifier(this._repository) : super(_repository.getLocale());

  /// تغيير اللغة
  Future<void> setLocale(Locale locale) async {
    await _repository.setLocale(locale);
    state = locale;
  }
}

/// مدير حالة إعدادات الإشعارات
class NotificationsEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repository;

  NotificationsEnabledNotifier(this._repository) : super(_repository.getNotificationsEnabled());

  /// تغيير إعدادات الإشعارات
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _repository.setNotificationsEnabled(enabled);
    state = enabled;
  }
}

/// مدير حالة إعدادات تحديد الموقع
class LocationEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repository;

  LocationEnabledNotifier(this._repository) : super(_repository.getLocationEnabled());

  /// تغيير إعدادات تحديد الموقع
  Future<void> setLocationEnabled(bool enabled) async {
    await _repository.setLocationEnabled(enabled);
    state = enabled;
  }
}

/// مدير حالة وحدة المسافة
class DistanceUnitNotifier extends StateNotifier<String> {
  final SettingsRepository _repository;

  DistanceUnitNotifier(this._repository) : super(_repository.getDistanceUnit());

  /// تغيير وحدة المسافة
  Future<void> setDistanceUnit(String unit) async {
    await _repository.setDistanceUnit(unit);
    state = unit;
  }
}

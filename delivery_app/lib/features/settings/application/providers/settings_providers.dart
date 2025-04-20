import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_app/features/settings/domain/usecases/settings_usecases.dart';
import 'package:delivery_app/features/settings/data/repositories/settings_repository_impl.dart';

/// تنفيذ حالات استخدام إعدادات التطبيق
class SettingsUseCasesImpl implements SettingsUseCases {
  final SettingsRepository _repository;
  final Locale _currentLocale;
  final ThemeMode _currentThemeMode;

  SettingsUseCasesImpl(this._repository, this._currentLocale, this._currentThemeMode);

  @override
  Future<void> changeLanguage(String languageCode) async {
    await _repository.saveLanguageCode(languageCode);
  }

  @override
  String getCurrentLanguageCode() {
    return _currentLocale.languageCode;
  }

  @override
  String getCurrentLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'tr':
        return 'Türkçe';
      case 'ur':
        return 'اردو';
      default:
        return 'العربية';
    }
  }

  @override
  String getCurrentLanguageFlag() {
    switch (_currentLocale.languageCode) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'tr':
        return '🇹🇷';
      case 'ur':
        return '🇵🇰';
      default:
        return '🇸🇦';
    }
  }

  @override
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    ];
  }

  @override
  Future<void> changeThemeMode(ThemeMode mode) async {
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeModeString = 'system';
        break;
    }
    await _repository.saveThemeMode(themeModeString);
  }

  @override
  Future<void> toggleThemeMode() async {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        await changeThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await changeThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await changeThemeMode(ThemeMode.light);
        break;
    }
  }

  @override
  ThemeMode getCurrentThemeMode() {
    return _currentThemeMode;
  }

  @override
  String getCurrentThemeModeName() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'lightMode';
      case ThemeMode.dark:
        return 'darkMode';
      case ThemeMode.system:
        return 'systemDefault';
    }
  }

  @override
  IconData getCurrentThemeModeIcon() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.settings_suggest;
    }
  }
}

/// مزود حالات استخدام الإعدادات
final settingsUseCasesProvider = Provider<SettingsUseCases>((ref) {
  final repository = SettingsRepositoryImpl();
  final locale = ref.watch(localeProvider);
  final themeMode = ref.watch(themeModeProvider);
  
  return SettingsUseCasesImpl(repository, locale, themeMode);
});

/// مزود للغة التطبيق
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(SettingsRepositoryImpl());
});

/// مزود لوضع السمة
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(SettingsRepositoryImpl());
});

/// مدير حالة اللغة
class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _repository;

  LocaleNotifier(this._repository) : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final languageCode = await _repository.getSavedLanguageCode();
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> changeLocale(String languageCode) async {
    state = Locale(languageCode);
    await _repository.saveLanguageCode(languageCode);
  }
}

/// مدير حالة السمة
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repository;

  ThemeModeNotifier(this._repository) : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    final themeMode = await _repository.getSavedThemeMode();
    if (themeMode != null) {
      switch (themeMode) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
          break;
      }
    }
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    state = mode;
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeModeString = 'system';
        break;
    }
    await _repository.saveThemeMode(themeModeString);
  }

  Future<void> toggleThemeMode() async {
    switch (state) {
      case ThemeMode.light:
        await changeThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await changeThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await changeThemeMode(ThemeMode.light);
        break;
    }
  }
}

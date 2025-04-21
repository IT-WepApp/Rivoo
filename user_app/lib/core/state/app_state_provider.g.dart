// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isDarkModeHash() => r'af260806df955c02035ac6993c20bf97175b3ba4';

/// مزود قراءة فقط لوضع السمة
///
/// Copied from [isDarkMode].
@ProviderFor(isDarkMode)
final isDarkModeProvider = AutoDisposeProvider<bool>.internal(
  isDarkMode,
  name: r'isDarkModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isDarkModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDarkModeRef = AutoDisposeProviderRef<bool>;
String _$currentLocaleHash() => r'b15ab409d3385bc70e902cb4acdc0a4bc5993c65';

/// مزود قراءة فقط للغة
///
/// Copied from [currentLocale].
@ProviderFor(currentLocale)
final currentLocaleProvider = AutoDisposeProvider<String>.internal(
  currentLocale,
  name: r'currentLocaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLocaleRef = AutoDisposeProviderRef<String>;
String _$isConnectedHash() => r'bafea7146391612a254e4f69cc1e2cedb173aea6';

/// مزود قراءة فقط لحالة الاتصال
///
/// Copied from [isConnected].
@ProviderFor(isConnected)
final isConnectedProvider = AutoDisposeProvider<bool>.internal(
  isConnected,
  name: r'isConnectedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isConnectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsConnectedRef = AutoDisposeProviderRef<bool>;
String _$appStateHash() => r'86ed1ea8ac801e1873ab03dfeda02de83da3eba1';

/// مزود حالة التطبيق الرئيسي
/// يستخدم لإدارة الحالة العامة للتطبيق مثل الوضع الليلي واللغة
///
/// Copied from [AppState].
@ProviderFor(AppState)
final appStateProvider = NotifierProvider<AppState, AppStateModel>.internal(
  AppState.new,
  name: r'appStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppState = Notifier<AppStateModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isNetworkConnectedHash() =>
    r'4a190cbce8efe3625be3ed8a74bc837f2e7952f7';

/// مزود قراءة فقط لحالة الاتصال بالإنترنت
///
/// Copied from [isNetworkConnected].
@ProviderFor(isNetworkConnected)
final isNetworkConnectedProvider = AutoDisposeFutureProvider<bool>.internal(
  isNetworkConnected,
  name: r'isNetworkConnectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isNetworkConnectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsNetworkConnectedRef = AutoDisposeFutureProviderRef<bool>;
String _$connectivityNotifierHash() =>
    r'3e64012a9bb3a43a8ee781a956bd9d3b10e82d15';

/// مزود حالة الاتصال بالإنترنت
/// يستخدم لمراقبة حالة الاتصال بالإنترنت وتوفير تحديثات مباشرة
///
/// Copied from [ConnectivityNotifier].
@ProviderFor(ConnectivityNotifier)
final connectivityNotifierProvider = AutoDisposeStreamNotifierProvider<
    ConnectivityNotifier, ConnectivityResult>.internal(
  ConnectivityNotifier.new,
  name: r'connectivityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityNotifier = AutoDisposeStreamNotifier<ConnectivityResult>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productHash() => r'1accacff2affbfc124fd481806951d18e5db66f9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// مزود لمنتج محدد حسب المعرف
///
/// Copied from [product].
@ProviderFor(product)
const productProvider = ProductFamily();

/// مزود لمنتج محدد حسب المعرف
///
/// Copied from [product].
class ProductFamily extends Family<AsyncValue<ProductModel?>> {
  /// مزود لمنتج محدد حسب المعرف
  ///
  /// Copied from [product].
  const ProductFamily();

  /// مزود لمنتج محدد حسب المعرف
  ///
  /// Copied from [product].
  ProductProvider call(
    String productId,
  ) {
    return ProductProvider(
      productId,
    );
  }

  @override
  ProductProvider getProviderOverride(
    covariant ProductProvider provider,
  ) {
    return call(
      provider.productId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productProvider';
}

/// مزود لمنتج محدد حسب المعرف
///
/// Copied from [product].
class ProductProvider extends AutoDisposeFutureProvider<ProductModel?> {
  /// مزود لمنتج محدد حسب المعرف
  ///
  /// Copied from [product].
  ProductProvider(
    String productId,
  ) : this._internal(
          (ref) => product(
            ref as ProductRef,
            productId,
          ),
          from: productProvider,
          name: r'productProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productHash,
          dependencies: ProductFamily._dependencies,
          allTransitiveDependencies: ProductFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<ProductModel?> Function(ProductRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductProvider._internal(
        (ref) => create(ref as ProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProductModel?> createElement() {
    return _ProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductRef on AutoDisposeFutureProviderRef<ProductModel?> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductProviderElement
    extends AutoDisposeFutureProviderElement<ProductModel?> with ProductRef {
  _ProductProviderElement(super.provider);

  @override
  String get productId => (origin as ProductProvider).productId;
}

String _$productsNotifierHash() => r'e85515785623af354f6fb7ab0204645d2254a143';

/// مزود حالة المنتجات باستخدام Riverpod المُولّد
///
/// Copied from [ProductsNotifier].
@ProviderFor(ProductsNotifier)
final productsNotifierProvider =
    AutoDisposeNotifierProvider<ProductsNotifier, ProductsState>.internal(
  ProductsNotifier.new,
  name: r'productsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductsNotifier = AutoDisposeNotifier<ProductsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

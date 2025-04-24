import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart';

import '../../../../core/architecture/presentation/base_view_model.dart';
import '../domain/entities/cart_item.dart';
import '../domain/usecases/cart_usecases.dart';
import '../data/repositories/cart_repository_impl.dart';

class CartViewModel extends BaseViewModel {
  final AddItemToCartUseCase _addItemToCartUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;
  final UpdateCartItemQuantityUseCase _updateCartItemQuantityUseCase;
  final IncrementCartItemUseCase _incrementCartItemUseCase;
  final DecrementCartItemUseCase _decrementCartItemUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final GetCartItemsUseCase _getCartItemsUseCase;
  final GetCartTotalItemsUseCase _getCartTotalItemsUseCase;
  final GetCartTotalPriceUseCase _getCartTotalPriceUseCase;

  CartViewModel({
    required AddItemToCartUseCase addItemToCartUseCase,
    required RemoveItemFromCartUseCase removeItemFromCartUseCase,
    required UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase,
    required IncrementCartItemUseCase incrementCartItemUseCase,
    required DecrementCartItemUseCase decrementCartItemUseCase,
    required ClearCartUseCase clearCartUseCase,
    required GetCartItemsUseCase getCartItemsUseCase,
    required GetCartTotalItemsUseCase getCartTotalItemsUseCase,
    required GetCartTotalPriceUseCase getCartTotalPriceUseCase,
  })  : _addItemToCartUseCase = addItemToCartUseCase,
        _removeItemFromCartUseCase = removeItemFromCartUseCase,
        _updateCartItemQuantityUseCase = updateCartItemQuantityUseCase,
        _incrementCartItemUseCase = incrementCartItemUseCase,
        _decrementCartItemUseCase = decrementCartItemUseCase,
        _clearCartUseCase = clearCartUseCase,
        _getCartItemsUseCase = getCartItemsUseCase,
        _getCartTotalItemsUseCase = getCartTotalItemsUseCase,
        _getCartTotalPriceUseCase = getCartTotalPriceUseCase,
        super();

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  Future<void> loadCartItems() async {
    setLoading(true);
    final result = await _getCartItemsUseCase(NoParams());
    result.fold(
      (failure) => setError(failure.message),
      (items) {
        _cartItems = items.cast<CartItem>();
        setLoading(false);
      },
    );
    await _updateTotals();
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    setLoading(true);
    final params = AddItemToCartParams(product: product, quantity: quantity);
    final result = await _addItemToCartUseCase(params);
    result.fold(
      (failure) => setError(failure.message),
      (_) => loadCartItems(),
    );
  }

  Future<void> removeItem(String cartItemId) async {
    setLoading(true);
    final result = await _removeItemFromCartUseCase(cartItemId);
    result.fold(
      (failure) => setError(failure.message),
      (_) => loadCartItems(),
    );
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    setLoading(true);
    final params = UpdateCartItemQuantityParams(
      cartItemId: cartItemId,
      newQuantity: newQuantity,
    );
    final result = await _updateCartItemQuantityUseCase(params);
    result.fold(
      (failure) => setError(failure.message),
      (_) => loadCartItems(),
    );
  }

  Future<void> incrementQuantity(String cartItemId) async {
    setLoading(true);
    final result = await _incrementCartItemUseCase(cartItemId);
    result.fold(
      (failure) => setError(failure.message),
      (_) => loadCartItems(),
    );
  }

  Future<void> decrementQuantity(String cartItemId) async {
    setLoading(true);
    final result = await _decrementCartItemUseCase(cartItemId);
    result.fold(
      (failure) => setError(failure.message),
      (_) => loadCartItems(),
    );
  }

  Future<void> clearCart() async {
    setLoading(true);
    final result = await _clearCartUseCase(NoParams());
    result.fold(
      (failure) => setError(failure.message),
      (_) => loadCartItems(),
    );
  }

  Future<void> _updateTotals() async {
    final totalItemsResult = await _getCartTotalItemsUseCase(NoParams());
    totalItemsResult.fold(
      (failure) => setError(failure.message),
      (total) => _totalItems = total,
    );

    final totalPriceResult = await _getCartTotalPriceUseCase(NoParams());
    totalPriceResult.fold(
      (failure) => setError(failure.message),
      (total) => _totalPrice = total,
    );
    notifyListeners();
  }
}

// Providers
final cartRepositoryProvider = Provider<CartRepositoryImpl>((ref) {
  return CartRepositoryImpl();
});

final addItemToCartUseCaseProvider = Provider<AddItemToCartUseCase>((ref) {
  return AddItemToCartUseCase(ref.watch(cartRepositoryProvider));
});

final removeItemFromCartUseCaseProvider =
    Provider<RemoveItemFromCartUseCase>((ref) {
  return RemoveItemFromCartUseCase(ref.watch(cartRepositoryProvider));
});

final updateCartItemQuantityUseCaseProvider =
    Provider<UpdateCartItemQuantityUseCase>((ref) {
  return UpdateCartItemQuantityUseCase(ref.watch(cartRepositoryProvider));
});

final incrementCartItemUseCaseProvider =
    Provider<IncrementCartItemUseCase>((ref) {
  return IncrementCartItemUseCase(ref.watch(cartRepositoryProvider));
});

final decrementCartItemUseCaseProvider =
    Provider<DecrementCartItemUseCase>((ref) {
  return DecrementCartItemUseCase(ref.watch(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.watch(cartRepositoryProvider));
});

final getCartItemsUseCaseProvider = Provider<GetCartItemsUseCase>((ref) {
  return GetCartItemsUseCase(ref.watch(cartRepositoryProvider));
});

final getCartTotalItemsUseCaseProvider =
    Provider<GetCartTotalItemsUseCase>((ref) {
  return GetCartTotalItemsUseCase(ref.watch(cartRepositoryProvider));
});

final getCartTotalPriceUseCaseProvider =
    Provider<GetCartTotalPriceUseCase>((ref) {
  return GetCartTotalPriceUseCase(ref.watch(cartRepositoryProvider));
});

final cartViewModelProvider = ChangeNotifierProvider<CartViewModel>((ref) {
  return CartViewModel(
    addItemToCartUseCase: ref.watch(addItemToCartUseCaseProvider),
    removeItemFromCartUseCase: ref.watch(removeItemFromCartUseCaseProvider),
    updateCartItemQuantityUseCase:
        ref.watch(updateCartItemQuantityUseCaseProvider),
    incrementCartItemUseCase: ref.watch(incrementCartItemUseCaseProvider),
    decrementCartItemUseCase: ref.watch(decrementCartItemUseCaseProvider),
    clearCartUseCase: ref.watch(clearCartUseCaseProvider),
    getCartItemsUseCase: ref.watch(getCartItemsUseCaseProvider),
    getCartTotalItemsUseCase: ref.watch(getCartTotalItemsUseCaseProvider),
    getCartTotalPriceUseCase: ref.watch(getCartTotalPriceUseCaseProvider),
  );
});

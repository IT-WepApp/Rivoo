import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item_model.dart';

class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() {
    return [];
  }

  void addItem(Map<String, dynamic> product, {int quantity = 1}) {
    final existingItemIndex =
        state.indexWhere((item) => item.productId == product['id']);

    if (existingItemIndex != -1) {
      final currentItem = state[existingItemIndex];
      final updatedItem =
          currentItem.copyWith(quantity: currentItem.quantity + quantity);
      state = List.from(state)..[existingItemIndex] = updatedItem;
    } else {
      final newItem = CartItemModel.fromProduct(product, quantity: quantity);
      state = [...state, newItem];
    }
  }

  void removeItem(String cartItemId) {
    state = state.where((item) => item.id != cartItemId).toList();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    final itemIndex = state.indexWhere((item) => item.id == cartItemId);
    if (itemIndex == -1) return;

    if (newQuantity <= 0) {
      removeItem(cartItemId);
    } else {
      final currentItem = state[itemIndex];
      final updatedItem = currentItem.copyWith(quantity: newQuantity);
      state = List.from(state)..[itemIndex] = updatedItem;
    }
  }

  void incrementQuantity(String cartItemId) {
    final itemIndex = state.indexWhere((item) => item.id == cartItemId);
    if (itemIndex == -1) return;

    final currentItem = state[itemIndex];
    final updatedItem =
        currentItem.copyWith(quantity: currentItem.quantity + 1);
    state = List.from(state)..[itemIndex] = updatedItem;
  }

  void decrementQuantity(String cartItemId) {
    final itemIndex = state.indexWhere((item) => item.id == cartItemId);
    if (itemIndex == -1) return;

    final currentItem = state[itemIndex];
    if (currentItem.quantity <= 1) {
      removeItem(cartItemId);
    } else {
      final updatedItem =
          currentItem.copyWith(quantity: currentItem.quantity - 1);
      state = List.from(state)..[itemIndex] = updatedItem;
    }
  }

  void clearCart() {
    state = [];
  }

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      state.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(() {
  return CartNotifier();
});

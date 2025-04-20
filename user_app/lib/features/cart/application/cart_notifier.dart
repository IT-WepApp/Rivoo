import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; 
// import 'dart:developer'; // Removed unused import

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]); 

  void addItem(Product product, {int quantity = 1}) {
     final existingItemIndex = state.indexWhere((item) => item.productId == product.id);

     if (existingItemIndex != -1) {
        final currentItem = state[existingItemIndex];
        final updatedItem = currentItem.copyWith(quantity: currentItem.quantity + quantity);
        state = List.from(state)..[existingItemIndex] = updatedItem;
     } else {
        final newItem = CartItemModel(
            id: product.id, 
            productId: product.id,
            name: product.name,
            price: product.price,
            imageUrl: product.imageUrl, 
            quantity: quantity,
        );
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
     final updatedItem = currentItem.copyWith(quantity: currentItem.quantity + 1);
     state = List.from(state)..[itemIndex] = updatedItem;
  }

   void decrementQuantity(String cartItemId) {
     final itemIndex = state.indexWhere((item) => item.id == cartItemId);
     if (itemIndex == -1) return; 

     final currentItem = state[itemIndex];
     if (currentItem.quantity <= 1) {
       removeItem(cartItemId); 
     } else {
       final updatedItem = currentItem.copyWith(quantity: currentItem.quantity - 1);
       state = List.from(state)..[itemIndex] = updatedItem;
     }
  }


  void clearCart() {
     state = [];
  }

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => state.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

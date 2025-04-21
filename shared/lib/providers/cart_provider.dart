import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product.dart';

/// نموذج حالة سلة التسوق
class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? error;

  CartState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  /// حساب المجموع الكلي للسلة
  double get totalAmount {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// عدد العناصر في السلة
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// نسخة أولية من الحالة
  factory CartState.initial() {
    return CartState(items: []);
  }

  /// نسخة من الحالة مع تحميل
  CartState copyWithLoading() {
    return CartState(
      items: items,
      isLoading: true,
      error: null,
    );
  }

  /// نسخة من الحالة مع خطأ
  CartState copyWithError(String errorMessage) {
    return CartState(
      items: items,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// نسخة من الحالة مع عناصر جديدة
  CartState copyWithItems(List<CartItemModel> newItems) {
    return CartState(
      items: newItems,
      isLoading: false,
      error: null,
    );
  }
}

/// مزود حالة سلة التسوق
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

/// مدير حالة سلة التسوق
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState.initial());

  /// إضافة منتج إلى السلة
  void addItem(Product product, int quantity) {
    state = state.copyWithLoading();
    
    try {
      final currentItems = List<CartItemModel>.from(state.items);
      final existingIndex = currentItems.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex >= 0) {
        // تحديث الكمية إذا كان المنتج موجوداً بالفعل
        final existingItem = currentItems[existingIndex];
        final updatedItem = CartItemModel(
          productId: existingItem.productId,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity + quantity,
          imageUrl: existingItem.imageUrl,
        );
        currentItems[existingIndex] = updatedItem;
      } else {
        // إضافة منتج جديد إلى السلة
        currentItems.add(
          CartItemModel(
            productId: product.id,
            title: product.title,
            price: product.price,
            quantity: quantity,
            imageUrl: product.imageUrl,
          ),
        );
      }
      
      state = state.copyWithItems(currentItems);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// إزالة منتج من السلة
  void removeItem(String productId) {
    state = state.copyWithLoading();
    
    try {
      final currentItems = List<CartItemModel>.from(state.items);
      currentItems.removeWhere((item) => item.productId == productId);
      
      state = state.copyWithItems(currentItems);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// تغيير كمية منتج في السلة
  void updateQuantity(String productId, int quantity) {
    state = state.copyWithLoading();
    
    try {
      final currentItems = List<CartItemModel>.from(state.items);
      final itemIndex = currentItems.indexWhere((item) => item.productId == productId);
      
      if (itemIndex >= 0) {
        final item = currentItems[itemIndex];
        
        if (quantity <= 0) {
          // إزالة المنتج إذا كانت الكمية صفر أو أقل
          currentItems.removeAt(itemIndex);
        } else {
          // تحديث الكمية
          final updatedItem = CartItemModel(
            productId: item.productId,
            title: item.title,
            price: item.price,
            quantity: quantity,
            imageUrl: item.imageUrl,
          );
          currentItems[itemIndex] = updatedItem;
        }
        
        state = state.copyWithItems(currentItems);
      }
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// تفريغ السلة
  void clearCart() {
    state = state.copyWithItems([]);
  }
}

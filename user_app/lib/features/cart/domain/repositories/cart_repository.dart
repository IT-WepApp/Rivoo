import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/cart/domain/entities/cart_item.dart';

/// واجهة مستودع سلة التسوق
abstract class CartRepository {
  /// الحصول على جميع عناصر سلة التسوق
  Future<Either<Failure, List<CartItem>>> getCartItems();
  
  /// إضافة عنصر إلى سلة التسوق
  Future<Either<Failure, CartItem>> addCartItem(CartItem cartItem);
  
  /// تحديث عنصر في سلة التسوق
  Future<Either<Failure, CartItem>> updateCartItem(CartItem cartItem);
  
  /// حذف عنصر من سلة التسوق
  Future<Either<Failure, void>> removeCartItem(String cartItemId);
  
  /// تفريغ سلة التسوق
  Future<Either<Failure, void>> clearCart();
  
  /// الحصول على عدد عناصر سلة التسوق
  Future<Either<Failure, int>> getCartItemsCount();
  
  /// الحصول على المبلغ الإجمالي لسلة التسوق
  Future<Either<Failure, double>> getCartTotal();
}

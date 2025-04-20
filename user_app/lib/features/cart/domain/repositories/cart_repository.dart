import 'package:dartz/dartz.dart';
import '../entities/cart_item.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../../../../core/architecture/domain/entity.dart';

abstract class CartRepository {
  /// الحصول على جميع العناصر في سلة التسوق
  Future<Either<Failure, List<CartItem>>> getCartItems();
  
  /// إضافة منتج إلى سلة التسوق
  Future<Either<Failure, Unit>> addItem(Entity product, {int quantity = 1});
  
  /// إزالة عنصر من سلة التسوق
  Future<Either<Failure, Unit>> removeItem(String cartItemId);
  
  /// تحديث كمية عنصر في سلة التسوق
  Future<Either<Failure, Unit>> updateQuantity(String cartItemId, int newQuantity);
  
  /// زيادة كمية عنصر في سلة التسوق
  Future<Either<Failure, Unit>> incrementQuantity(String cartItemId);
  
  /// تقليل كمية عنصر في سلة التسوق
  Future<Either<Failure, Unit>> decrementQuantity(String cartItemId);
  
  /// تفريغ سلة التسوق
  Future<Either<Failure, Unit>> clearCart();
  
  /// الحصول على إجمالي عدد العناصر في سلة التسوق
  Future<Either<Failure, int>> getTotalItems();
  
  /// الحصول على إجمالي سعر العناصر في سلة التسوق
  Future<Either<Failure, double>> getTotalPrice();
}

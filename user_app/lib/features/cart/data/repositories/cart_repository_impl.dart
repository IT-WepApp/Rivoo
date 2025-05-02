import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/architecture/domain/failure.dart';
import 'package:user_app/features/cart/data/models/cart_item_model.dart';
import 'package:user_app/features/cart/domain/entities/cart_item.dart';
import 'package:user_app/features/cart/domain/repositories/cart_repository.dart';

/// تنفيذ مستودع سلة التسوق
class CartRepositoryImpl implements CartRepository {
  /// مصدر البيانات المحلي
  final CartLocalDataSource _localDataSource;
  
  /// مصدر البيانات البعيد
  final CartRemoteDataSource _remoteDataSource;

  /// إنشاء تنفيذ مستودع سلة التسوق
  CartRepositoryImpl({
    required CartLocalDataSource localDataSource,
    required CartRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final cartItemModels = await _localDataSource.getCartItems();
      final cartItems = cartItemModels.map((model) => model.toEntity()).toList();
      return Right(cartItems);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartItem>> addCartItem(CartItem cartItem) async {
    try {
      final cartItemModel = CartItemModel.fromEntity(cartItem);
      final addedCartItemModel = await _remoteDataSource.addCartItem(cartItemModel);
      await _localDataSource.saveCartItem(addedCartItemModel);
      return Right(addedCartItemModel.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartItem>> updateCartItem(CartItem cartItem) async {
    try {
      final cartItemModel = CartItemModel.fromEntity(cartItem);
      final updatedCartItemModel = await _remoteDataSource.updateCartItem(cartItemModel);
      await _localDataSource.saveCartItem(updatedCartItemModel);
      return Right(updatedCartItemModel.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeCartItem(String cartItemId) async {
    try {
      await _remoteDataSource.removeCartItem(cartItemId);
      await _localDataSource.removeCartItem(cartItemId);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _remoteDataSource.clearCart();
      await _localDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCartItemsCount() async {
    try {
      final count = await _localDataSource.getCartItemsCount();
      return Right(count);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getCartTotal() async {
    try {
      final total = await _localDataSource.getCartTotal();
      return Right(total);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

/// مصدر البيانات المحلي لسلة التسوق
abstract class CartLocalDataSource {
  /// الحصول على جميع عناصر سلة التسوق
  Future<List<CartItemModel>> getCartItems();
  
  /// حفظ عنصر في سلة التسوق
  Future<void> saveCartItem(CartItemModel cartItemModel);
  
  /// حذف عنصر من سلة التسوق
  Future<void> removeCartItem(String cartItemId);
  
  /// تفريغ سلة التسوق
  Future<void> clearCart();
  
  /// الحصول على عدد عناصر سلة التسوق
  Future<int> getCartItemsCount();
  
  /// الحصول على المبلغ الإجمالي لسلة التسوق
  Future<double> getCartTotal();
}

/// مصدر البيانات البعيد لسلة التسوق
abstract class CartRemoteDataSource {
  /// الحصول على جميع عناصر سلة التسوق
  Future<List<CartItemModel>> getCartItems();
  
  /// إضافة عنصر إلى سلة التسوق
  Future<CartItemModel> addCartItem(CartItemModel cartItemModel);
  
  /// تحديث عنصر في سلة التسوق
  Future<CartItemModel> updateCartItem(CartItemModel cartItemModel);
  
  /// حذف عنصر من سلة التسوق
  Future<void> removeCartItem(String cartItemId);
  
  /// تفريغ سلة التسوق
  Future<void> clearCart();
}

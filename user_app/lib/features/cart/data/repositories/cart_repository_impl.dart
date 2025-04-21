import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../core/architecture/domain/entity.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../domain/entities/cart_item.dart';
import '../domain/repositories/cart_repository.dart';
import 'models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final List<CartItemModel> _cartItems = [];

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      return Right(_cartItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addItem(Entity product,
      {int quantity = 1}) async {
    try {
      final existingItemIndex =
          _cartItems.indexWhere((item) => item.productId == product.id);

      if (existingItemIndex != -1) {
        final currentItem = _cartItems[existingItemIndex];
        final updatedItem =
            currentItem.copyWith(quantity: currentItem.quantity + quantity);
        _cartItems[existingItemIndex] = updatedItem;
      } else {
        final newItem =
            CartItemModel.fromProduct(product as Product, quantity: quantity);
        _cartItems.add(newItem);
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeItem(String cartItemId) async {
    try {
      _cartItems.removeWhere((item) => item.id == cartItemId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateQuantity(
      String cartItemId, int newQuantity) async {
    try {
      final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (itemIndex == -1) {
        return Left(NotFoundFailure(message: 'العنصر غير موجود في سلة التسوق'));
      }

      if (newQuantity <= 0) {
        return removeItem(cartItemId);
      } else {
        final currentItem = _cartItems[itemIndex];
        final updatedItem = currentItem.copyWith(quantity: newQuantity);
        _cartItems[itemIndex] = updatedItem;
        return const Right(unit);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> incrementQuantity(String cartItemId) async {
    try {
      final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (itemIndex == -1) {
        return Left(NotFoundFailure(message: 'العنصر غير موجود في سلة التسوق'));
      }

      final currentItem = _cartItems[itemIndex];
      final updatedItem =
          currentItem.copyWith(quantity: currentItem.quantity + 1);
      _cartItems[itemIndex] = updatedItem;
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> decrementQuantity(String cartItemId) async {
    try {
      final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (itemIndex == -1) {
        return Left(NotFoundFailure(message: 'العنصر غير موجود في سلة التسوق'));
      }

      final currentItem = _cartItems[itemIndex];
      if (currentItem.quantity <= 1) {
        return removeItem(cartItemId);
      } else {
        final updatedItem =
            currentItem.copyWith(quantity: currentItem.quantity - 1);
        _cartItems[itemIndex] = updatedItem;
        return const Right(unit);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      _cartItems.clear();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalItems() async {
    try {
      final totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);
      return Right(totalItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPrice() async {
    try {
      final totalPrice = _cartItems.fold(
          0.0, (sum, item) => sum + (item.price * item.quantity));
      return Right(totalPrice);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl();
});

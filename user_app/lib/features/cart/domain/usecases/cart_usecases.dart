import 'package:dartz/dartz.dart';
import '../repositories/cart_repository.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../../../../core/architecture/domain/usecase.dart';

class AddItemToCartUseCase implements UseCase<Unit, AddItemToCartParams> {
  final CartRepository repository;

  AddItemToCartUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AddItemToCartParams params) {
    return repository.addItem(params.product, quantity: params.quantity);
  }
}

class AddItemToCartParams {
  final dynamic product;
  final int quantity;

  AddItemToCartParams({required this.product, this.quantity = 1});
}

class RemoveItemFromCartUseCase implements UseCase<Unit, String> {
  final CartRepository repository;

  RemoveItemFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String cartItemId) {
    return repository.removeItem(cartItemId);
  }
}

class UpdateCartItemQuantityUseCase
    implements UseCase<Unit, UpdateCartItemQuantityParams> {
  final CartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateCartItemQuantityParams params) {
    return repository.updateQuantity(params.cartItemId, params.newQuantity);
  }
}

class UpdateCartItemQuantityParams {
  final String cartItemId;
  final int newQuantity;

  UpdateCartItemQuantityParams(
      {required this.cartItemId, required this.newQuantity});
}

class IncrementCartItemUseCase implements UseCase<Unit, String> {
  final CartRepository repository;

  IncrementCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String cartItemId) {
    return repository.incrementQuantity(cartItemId);
  }
}

class DecrementCartItemUseCase implements UseCase<Unit, String> {
  final CartRepository repository;

  DecrementCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String cartItemId) {
    return repository.decrementQuantity(cartItemId);
  }
}

class ClearCartUseCase implements UseCase<Unit, NoParams> {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.clearCart();
  }
}

class GetCartItemsUseCase implements UseCase<List<dynamic>, NoParams> {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(NoParams params) {
    return repository.getCartItems();
  }
}

class GetCartTotalItemsUseCase implements UseCase<int, NoParams> {
  final CartRepository repository;

  GetCartTotalItemsUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.getTotalItems();
  }
}

class GetCartTotalPriceUseCase implements UseCase<double, NoParams> {
  final CartRepository repository;

  GetCartTotalPriceUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(NoParams params) {
    return repository.getTotalPrice();
  }
}

import 'package:dartz/dartz.dart';
import '../repositories/order_repository.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../../../../core/architecture/domain/usecase.dart';
import '../entities/order.dart';

class GetUserOrdersUseCase implements UseCase<List<Order>, NoParams> {
  final OrderRepository repository;

  GetUserOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Order>>> call(NoParams params) {
    return repository.getUserOrders();
  }
}

class GetOrderDetailsUseCase implements UseCase<Order, String> {
  final OrderRepository repository;

  GetOrderDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Order>> call(String orderId) {
    return repository.getOrderDetails(orderId);
  }
}

class CreateOrderUseCase implements UseCase<Order, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, Order>> call(CreateOrderParams params) {
    return repository.createOrder(
      items: params.items,
      totalAmount: params.totalAmount,
      shippingAddress: params.shippingAddress,
      paymentMethod: params.paymentMethod,
    );
  }
}

class CreateOrderParams {
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;

  CreateOrderParams({
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
  });
}

class CancelOrderUseCase implements UseCase<Unit, String> {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String orderId) {
    return repository.cancelOrder(orderId);
  }
}

class TrackOrderUseCase implements UseCase<String, String> {
  final OrderRepository repository;

  TrackOrderUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String orderId) {
    return repository.trackOrder(orderId);
  }
}

class UpdateShippingAddressUseCase implements UseCase<Unit, UpdateShippingAddressParams> {
  final OrderRepository repository;

  UpdateShippingAddressUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateShippingAddressParams params) {
    return repository.updateShippingAddress(params.orderId, params.newAddress);
  }
}

class UpdateShippingAddressParams {
  final String orderId;
  final String newAddress;

  UpdateShippingAddressParams({
    required this.orderId,
    required this.newAddress,
  });
}

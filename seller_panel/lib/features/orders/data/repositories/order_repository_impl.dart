import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/exceptions.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/orders/data/datasources/order_firebase_datasource.dart';
import 'package:seller_panel/features/orders/domain/entities/order_entity.dart';
import 'package:seller_panel/features/orders/domain/repositories/order_repository.dart';

/// تنفيذ مستودع الطلبات
class OrderRepositoryImpl implements OrderRepository {
  final OrderFirebaseDataSource dataSource;

  OrderRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders(String sellerId) async {
    try {
      final orders = await dataSource.getOrders(sellerId);
      return Right(orders);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    try {
      final order = await dataSource.getOrderDetails(orderId);
      return Right(order);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(String orderId, String status) async {
    try {
      final updatedOrder = await dataSource.updateOrderStatus(orderId, status);
      return Right(updatedOrder);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics(String sellerId) async {
    try {
      final statistics = await dataSource.getOrderStatistics(sellerId);
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> searchOrders(
    String sellerId, {
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await dataSource.searchOrders(
        sellerId,
        query: query,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(orders);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}

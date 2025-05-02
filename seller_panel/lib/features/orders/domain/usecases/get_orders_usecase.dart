import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/error/failures.dart';
import 'package:shared_libs/models/order.dart';
import 'package:seller_panel/features/orders/domain/repositories/order_repository.dart';

/// حالة استخدام للحصول على قائمة الطلبات للبائع
class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, List<OrderEntity>>> call(String sellerId) {
    return repository.getOrders(sellerId);
  }
}

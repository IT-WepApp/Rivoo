import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/orders/domain/entities/order_entity.dart';
import 'package:seller_panel/features/orders/domain/repositories/order_repository.dart';

/// حالة استخدام لتحديث حالة الطلب
class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, OrderEntity>> call(String orderId, String status) {
    return repository.updateOrderStatus(orderId, status);
  }
}

import 'package:dartz/dartz.dart';
import 'package:shared_libs/core/error/failures.dart';
import 'package:shared_libs/models/order.dart';
import 'package:seller_panel/features/orders/domain/repositories/order_repository.dart';

/// حالة استخدام للحصول على تفاصيل طلب محدد
class GetOrderDetailsUseCase {
  final OrderRepository repository;

  GetOrderDetailsUseCase(this.repository);

  /// تنفيذ حالة الاستخدام
  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrderDetails(orderId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:seller_panel/core/error/failures.dart';
import 'package:seller_panel/features/orders/domain/entities/order_entity.dart';

/// واجهة مستودع الطلبات التي تحدد العمليات المتاحة على الطلبات
abstract class OrderRepository {
  /// الحصول على قائمة الطلبات للبائع
  Future<Either<Failure, List<OrderEntity>>> getOrders(String sellerId);

  /// الحصول على تفاصيل طلب محدد
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);

  /// تحديث حالة الطلب
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
      String orderId, String status);

  /// الحصول على إحصائيات الطلبات للبائع
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics(
      String sellerId);

  /// البحث عن الطلبات
  Future<Either<Failure, List<OrderEntity>>> searchOrders(
    String sellerId, {
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
}

import 'package:dartz/dartz.dart';
import '../../../../core/architecture/domain/failure.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  /// الحصول على جميع الطلبات للمستخدم الحالي
  Future<Either<Failure, List<Order>>> getUserOrders();

  /// الحصول على تفاصيل طلب محدد
  Future<Either<Failure, Order>> getOrderDetails(String orderId);

  /// إنشاء طلب جديد
  Future<Either<Failure, Order>> createOrder({
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  });

  /// إلغاء طلب
  Future<Either<Failure, Unit>> cancelOrder(String orderId);

  /// تتبع حالة الطلب
  Future<Either<Failure, String>> trackOrder(String orderId);

  /// تحديث عنوان الشحن للطلب
  Future<Either<Failure, Unit>> updateShippingAddress(
      String orderId, String newAddress);
}

import 'package:dartz/dartz.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/orders/domain/entities/order.dart';

/// واجهة مستودع الطلبات
abstract class OrderRepository {
  /// الحصول على طلبات المستخدم
  Future<Either<Failure, List<Order>>> getUserOrders(String userId);
  
  /// الحصول على تفاصيل طلب محدد
  Future<Either<Failure, Order>> getOrderDetails(String orderId);
  
  /// إنشاء طلب جديد
  Future<Either<Failure, Order>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String paymentMethod,
  });
  
  /// إلغاء طلب
  Future<Either<Failure, Unit>> cancelOrder(String orderId);
  
  /// تتبع حالة طلب
  Future<Either<Failure, Map<String, dynamic>>> trackOrder(String orderId);
}

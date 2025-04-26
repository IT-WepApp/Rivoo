import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(); // أو أي بناء فعلي مستخدم حالياً
});

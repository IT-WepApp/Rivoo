import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String shippingAddress;
  final String paymentMethod;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.shippingAddress,
    required this.paymentMethod,
    this.trackingNumber,
    this.estimatedDeliveryDate,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        status,
        orderDate,
        shippingAddress,
        paymentMethod,
        trackingNumber,
        estimatedDeliveryDate,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  @override
  List<Object?> get props =>
      [id, productId, productName, price, quantity, imageUrl];
}

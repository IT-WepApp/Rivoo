import '../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required String id,
    required String userId,
    required List<OrderItemModel> items,
    required double totalAmount,
    required String status,
    required DateTime orderDate,
    required String shippingAddress,
    required String paymentMethod,
    String? trackingNumber,
    DateTime? estimatedDeliveryDate,
  }) : super(
          id: id,
          userId: userId,
          items: items,
          totalAmount: totalAmount,
          status: status,
          orderDate: orderDate,
          shippingAddress: shippingAddress,
          paymentMethod: paymentMethod,
          trackingNumber: trackingNumber,
          estimatedDeliveryDate: estimatedDeliveryDate,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      shippingAddress: json['shippingAddress'] as String,
      paymentMethod: json['paymentMethod'] as String,
      trackingNumber: json['trackingNumber'] as String?,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': (items as List<OrderItemModel>).map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
    };
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required String id,
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    String? imageUrl,
  }) : super(
          id: id,
          productId: productId,
          productName: productName,
          price: price,
          quantity: quantity,
          imageUrl: imageUrl,
        );

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

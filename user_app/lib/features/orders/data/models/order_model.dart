import 'package:flutter/material.dart';
import 'package:user_app/features/orders/domain/entities/order.dart';

/// نموذج الطلب
class OrderModel extends Order {
  OrderModel({
    required String id,
    required String userId,
    required List<OrderItemModel> items,
    required String shippingAddress,
    required String paymentMethod,
    required double totalAmount,
    required String status,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          items: items,
          shippingAddress: shippingAddress,
          paymentMethod: paymentMethod,
          totalAmount: totalAmount,
          status: status,
          createdAt: createdAt,
        );

  /// إنشاء نموذج من JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'];
    final List<OrderItemModel> items = itemsJson
        .map((itemJson) => OrderItemModel.fromJson(itemJson))
        .toList();

    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      items: items,
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> itemsJson =
        items.map((item) => (item as OrderItemModel).toJson()).toList();

    return {
      'id': id,
      'userId': userId,
      'items': itemsJson,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// نموذج عنصر الطلب
class OrderItemModel extends OrderItem {
  OrderItemModel({
    required String id,
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
    required double totalPrice,
  }) : super(
          id: id,
          productId: productId,
          productName: productName,
          productImage: productImage,
          price: price,
          quantity: quantity,
          totalPrice: totalPrice,
        );

  /// إنشاء نموذج من JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}

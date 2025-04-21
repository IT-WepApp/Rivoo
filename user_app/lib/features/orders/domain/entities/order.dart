import 'package:flutter/material.dart';
import 'package:user_app/core/architecture/domain/entity.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:dartz/dartz.dart';

/// كيان الطلب
class Order extends Entity {
  final String userId;
  final List<OrderItem> items;
  final String shippingAddress;
  final String paymentMethod;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  Order({
    required String id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  }) : super(id: id);

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        shippingAddress,
        paymentMethod,
        totalAmount,
        status,
        createdAt,
      ];
}

/// كيان عنصر الطلب
class OrderItem extends Entity {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double totalPrice;

  OrderItem({
    required String id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  }) : super(id: id);

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        price,
        quantity,
        totalPrice,
      ];
}

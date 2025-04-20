import 'package:equatable/equatable.dart';

/// كيان الطلب الذي يمثل طلبًا في النظام
class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String sellerId;
  final String status;
  final DateTime orderDate;
  final double totalAmount;
  final List<OrderItemEntity> items;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? trackingNumber;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.sellerId,
    required this.status,
    required this.orderDate,
    required this.totalAmount,
    required this.items,
    this.shippingAddress,
    this.paymentMethod,
    this.paymentStatus,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        sellerId,
        status,
        orderDate,
        totalAmount,
        items,
        shippingAddress,
        paymentMethod,
        paymentStatus,
        trackingNumber,
      ];

  OrderEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? sellerId,
    String? status,
    DateTime? orderDate,
    double? totalAmount,
    List<OrderItemEntity>? items,
    String? shippingAddress,
    String? paymentMethod,
    String? paymentStatus,
    String? trackingNumber,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }
}

/// كيان عنصر الطلب الذي يمثل منتجًا في الطلب
class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double? discount;
  final String? imageUrl;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.discount,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        price,
        discount,
        imageUrl,
      ];

  double get totalPrice => price * quantity - (discount ?? 0);

  OrderItemEntity copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    double? discount,
    String? imageUrl,
  }) {
    return OrderItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

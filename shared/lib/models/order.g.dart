// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderProductItem _$OrderProductItemFromJson(Map<String, dynamic> json) =>
    OrderProductItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderProductItemToJson(OrderProductItem instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sellerId: json['sellerId'] as String,
      deliveryId: json['deliveryId'] as String?,
      products: (json['products'] as List<dynamic>)
          .map((e) => OrderProductItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      address: json['address'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Object),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sellerId': instance.sellerId,
      'deliveryId': instance.deliveryId,
      'products': instance.products.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'status': instance.status,
      'address': instance.address,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

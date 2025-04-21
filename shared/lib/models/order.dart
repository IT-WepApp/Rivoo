import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderProductItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  OrderProductItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) =>
      _$OrderProductItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderProductItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
@TimestampConverter()
class OrderModel {
  final String id;
  final String userId;
  final String sellerId;
  final String? deliveryId;
  final List<OrderProductItem> products;
  final double total;
  final String status;
  final String address;
  final Timestamp createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    this.deliveryId,
    required this.products,
    required this.total,
    this.status = 'pending',
    required this.address,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

class TimestampConverter implements JsonConverter<Timestamp, Object> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Object json) => json as Timestamp;

  @override
  Object toJson(Timestamp object) => object;
}

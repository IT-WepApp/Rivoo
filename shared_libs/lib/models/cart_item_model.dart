import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel {
  final String id; // Often same as productId for cart items
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl; // Optional imageUrl
  final DateTime addedAt; // Added timestamp

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.addedAt, // Make required
    this.imageUrl,
  });

  // JsonSerializable methods
  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  // copyWith method
  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    double? price,
    String? imageUrl,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}


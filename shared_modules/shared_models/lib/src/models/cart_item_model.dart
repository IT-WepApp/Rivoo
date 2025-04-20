import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel { // Renamed from CartItem to CartItemModel for consistency
  final String id; // Added id (often same as productId for cart items)
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl; // Added optional imageUrl

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
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
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

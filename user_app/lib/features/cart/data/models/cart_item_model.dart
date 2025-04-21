import 'package:equatable/equatable.dart';
import '../entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required String id,
    required String productId,
    required String name,
    required double price,
    required String imageUrl,
    required int quantity,
  }) : super(
          id: id,
          productId: productId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          quantity: quantity,
        );

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      name: entity.name,
      price: entity.price,
      imageUrl: entity.imageUrl,
      quantity: entity.quantity,
    );
  }

  factory CartItemModel.fromProduct(Map<String, dynamic> product, {int quantity = 1}) {
    return CartItemModel(
      id: product['id'] as String,
      productId: product['id'] as String,
      name: product['name'] as String,
      price: (product['price'] as num).toDouble(),
      imageUrl: product['imageUrl'] as String,
      quantity: quantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}

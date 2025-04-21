import 'package:user_app/features/cart/domain/entities/cart_item.dart';
import 'package:user_app/features/products/domain/product.dart';

/// نموذج عنصر سلة التسوق
class CartItemModel extends CartItem {
  /// إنشاء نموذج عنصر سلة التسوق
  const CartItemModel({
    required String id,
    required Product product,
    required int quantity,
    required DateTime addedAt,
  }) : super(
          id: id,
          product: product,
          quantity: quantity,
          addedAt: addedAt,
        );

  /// إنشاء نموذج عنصر سلة التسوق من خريطة
  factory CartItemModel.fromMap(Map<String, dynamic> map, Product product) {
    return CartItemModel(
      id: map['id'] as String,
      product: product,
      quantity: map['quantity'] as int,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int),
    );
  }

  /// تحويل نموذج عنصر سلة التسوق إلى خريطة
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': product.id,
      'quantity': quantity,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  /// إنشاء نسخة جديدة من نموذج عنصر سلة التسوق مع تحديث بعض الحقول
  CartItemModel copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

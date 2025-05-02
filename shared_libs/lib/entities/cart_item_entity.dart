import 'package:equatable/equatable.dart';

/// كيان عنصر سلة التسوق الأساسي الموحد
class CartItemEntity extends Equatable {
  final String id; // معرف فريد لعنصر السلة (قد يكون معرف المنتج أو معرف فريد آخر)
  final String productId;
  final int quantity;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [id, productId, quantity, addedAt];
}


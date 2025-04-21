import 'package:equatable/equatable.dart';
import '../../../../core/architecture/domain/entity.dart';

/// نموذج عنصر سلة التسوق
class CartItem extends Equatable {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  /// حساب السعر الإجمالي للعنصر
  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [id, productId, name, price, imageUrl, quantity];
}

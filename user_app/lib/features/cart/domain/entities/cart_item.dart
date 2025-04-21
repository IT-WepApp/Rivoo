import 'package:user_app/core/architecture/domain/entity.dart';
import 'package:user_app/features/products/domain/product.dart';

/// كيان عنصر سلة التسوق
class CartItem extends Entity {
  /// المنتج
  final Product product;
  
  /// الكمية
  final int quantity;
  
  /// السعر الإجمالي للعنصر
  final double totalPrice;
  
  /// الخيارات المحددة (مثل اللون، الحجم، إلخ)
  final Map<String, dynamic>? options;
  
  /// ملاحظات إضافية
  final String? notes;
  
  /// تاريخ إضافة العنصر إلى السلة
  final DateTime addedAt;

  /// إنشاء كيان عنصر سلة التسوق
  const CartItem({
    required String id,
    required this.product,
    required this.quantity,
    required this.totalPrice,
    this.options,
    this.notes,
    required this.addedAt,
  }) : super(id: id);

  /// نسخة جديدة من الكيان مع تحديث بعض الحقول
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? totalPrice,
    Map<String, dynamic>? options,
    String? notes,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      options: options ?? this.options,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        totalPrice,
        options,
        notes,
        addedAt,
      ];
}

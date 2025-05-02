import 'package:shared_libs/entities/cart_item_entity.dart'; // Import base entity
import 'package:user_app/features/products/domain/user_product.dart'; // Import UserProduct

/// كيان عنصر سلة التسوق الخاص بواجهة المستخدم (يرث من الكيان الأساسي)
class UserCartItem extends CartItemEntity {
  // Fields inherited from CartItemEntity:
  // id, productId, quantity, addedAt

  /// المنتج (باستخدام نموذج واجهة المستخدم)
  final UserProduct product;

  /// السعر الإجمالي للعنصر (محسوب)
  final double totalPrice;

  /// الخيارات المحددة (مثل اللون، الحجم، إلخ)
  final Map<String, dynamic>? options;

  /// ملاحظات إضافية
  final String? notes;

  /// إنشاء كيان عنصر سلة التسوق الخاص بالمستخدم
  const UserCartItem({
    // Fields for CartItemEntity (passed to super)
    required String id,
    required String productId,
    required int quantity,
    required DateTime addedAt,

    // Fields specific to this user-facing entity
    required this.product,
    this.options,
    this.notes,
  })  : totalPrice = product.actualPrice * quantity, // Calculate total price
        super(
          id: id,
          productId: productId,
          quantity: quantity,
          addedAt: addedAt,
        );

  /// نسخة جديدة من الكيان مع تحديث بعض الحقول
  UserCartItem copyWith({
    // Entity fields
    String? id,
    String? productId,
    int? quantity,
    DateTime? addedAt,
    // UserCartItem specific fields
    UserProduct? product,
    Map<String, dynamic>? options,
    String? notes,
    // totalPrice is calculated, not copied directly
  }) {
    final effectiveProduct = product ?? this.product;
    final effectiveQuantity = quantity ?? this.quantity;

    return UserCartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: effectiveQuantity,
      addedAt: addedAt ?? this.addedAt,
      product: effectiveProduct,
      options: options ?? this.options,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        product,
        totalPrice,
        options,
        notes,
      ];
}


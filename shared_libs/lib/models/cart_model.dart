import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cart_item_model.dart'; // ← pull in the separate model

part 'cart_model.g.dart';

/// نموذج سلة التسوق
/// يستخدم لتمثيل بيانات سلة التسوق للمستخدم في التطبيق
@JsonSerializable()
class CartModel extends Equatable {
  /// معرف المستخدم صاحب السلة
  final String userId;
  
  /// قائمة عناصر السلة
  final List<CartItemModel> items;
  
  /// إجمالي سعر المنتجات
  final double subtotal;
  
  /// رسوم التوصيل المتوقعة
  final double? estimatedDeliveryFee;
  
  /// قيمة الضريبة المتوقعة
  final double? estimatedTax;
  
  /// قيمة الخصم (إن وجد)
  final double discount;
  
  /// إجمالي المبلغ المتوقع
  final double total;
  
  /// رمز الكوبون المستخدم (إن وجد)
  final String? couponCode;
  
  /// تاريخ آخر تحديث للسلة
  final DateTime updatedAt;

  /// منشئ النموذج
  const CartModel({
    required this.userId,
    required this.items,
    required this.subtotal,
    this.estimatedDeliveryFee,
    this.estimatedTax,
    this.discount = 0,
    required this.total,
    this.couponCode,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  CartModel copyWith({
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? estimatedDeliveryFee,
    double? estimatedTax,
    double? discount,
    double? total,
    String? couponCode,
    DateTime? updatedAt,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      estimatedDeliveryFee: estimatedDeliveryFee ?? this.estimatedDeliveryFee,
      estimatedTax: estimatedTax ?? this.estimatedTax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      couponCode: couponCode ?? this.couponCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إضافة عنصر إلى السلة
  CartModel addItem(CartItemModel item) {
    // التحقق مما إذا كان المنتج موجوداً بالفعل في السلة
    final existingItemIndex = items.indexWhere((i) => i.productId == item.productId);
    
    if (existingItemIndex >= 0) {
      // إذا كان المنتج موجوداً، قم بتحديث الكمية
      final updatedItems = List<CartItemModel>.from(items);
      final existingItem = items[existingItemIndex];
      final newQuantity = existingItem.quantity + item.quantity;
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: newQuantity,
        // no more `total:` parameter here
      );
      
      // إعادة حساب الإجماليات
      final newSubtotal = _calculateSubtotal(updatedItems);
      
      return copyWith(
        items: updatedItems,
        subtotal: newSubtotal,
        total: _calculateTotal(newSubtotal, estimatedDeliveryFee, estimatedTax, discount),
        updatedAt: DateTime.now(),
      );
    } else {
      // إذا كان المنتج غير موجود، أضفه إلى القائمة
      final updatedItems = List<CartItemModel>.from(items)
        ..add(item);
      
      // إعادة حساب الإجماليات
      final newSubtotal = _calculateSubtotal(updatedItems);
      
      return copyWith(
        items: updatedItems,
        subtotal: newSubtotal,
        total: _calculateTotal(newSubtotal, estimatedDeliveryFee, estimatedTax, discount),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// إزالة عنصر من السلة
  CartModel removeItem(String productId) {
    final updatedItems = items.where((item) => item.productId != productId).toList();
    
    // إعادة حساب الإجماليات
    final newSubtotal = _calculateSubtotal(updatedItems);
    
    return copyWith(
      items: updatedItems,
      subtotal: newSubtotal,
      total: _calculateTotal(newSubtotal, estimatedDeliveryFee, estimatedTax, discount),
      updatedAt: DateTime.now(),
    );
  }

  /// تحديث كمية عنصر في السلة
  CartModel updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }
    
    final updatedItems = List<CartItemModel>.from(items);
    final itemIndex = items.indexWhere((item) => item.productId == productId);
    
    if (itemIndex >= 0) {
      final item = items[itemIndex];
      updatedItems[itemIndex] = item.copyWith(
        quantity: quantity,
        // no `total:` here either
      );
      
      // إعادة حساب الإجماليات
      final newSubtotal = _calculateSubtotal(updatedItems);
      
      return copyWith(
        items: updatedItems,
        subtotal: newSubtotal,
        total: _calculateTotal(newSubtotal, estimatedDeliveryFee, estimatedTax, discount),
        updatedAt: DateTime.now(),
      );
    }
    
    return this;
  }

  /// تطبيق كوبون خصم
  CartModel applyCoupon(String couponCode, double discountAmount) {
    return copyWith(
      couponCode: couponCode,
      discount: discountAmount,
      total: _calculateTotal(subtotal, estimatedDeliveryFee, estimatedTax, discountAmount),
      updatedAt: DateTime.now(),
    );
  }

  /// إزالة كوبون الخصم
  CartModel removeCoupon() {
    return copyWith(
      couponCode: null,
      discount: 0,
      total: _calculateTotal(subtotal, estimatedDeliveryFee, estimatedTax, 0),
      updatedAt: DateTime.now(),
    );
  }

  /// مسح السلة
  CartModel clear() {
    return copyWith(
      items: [],
      subtotal: 0,
      discount: 0,
      total: 0,
      couponCode: null,
      updatedAt: DateTime.now(),
    );
  }

  /// حساب إجمالي سعر المنتجات
  double _calculateSubtotal(List<CartItemModel> items) {
    // sum up price * quantity
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  /// حساب إجمالي المبلغ
  double _calculateTotal(double subtotal, double? deliveryFee, double? tax, double discount) {
    double total = subtotal;
    if (deliveryFee != null) total += deliveryFee;
    if (tax != null) total += tax;
    total -= discount;
    return total > 0 ? total : 0;
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  /// إنشاء نموذج من Map
  factory CartModel.fromJson(Map<String, dynamic> json) => _$CartModelFromJson(json);

  /// إنشاء سلة فارغة
  factory CartModel.empty(String userId) {
    return CartModel(
      userId: userId,
      items: [],
      subtotal: 0,
      total: 0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        items,
        subtotal,
        estimatedDeliveryFee,
        estimatedTax,
        discount,
        total,
        couponCode,
        updatedAt,
      ];
}

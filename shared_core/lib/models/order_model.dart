import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

/// نموذج الطلب
/// يستخدم لتمثيل بيانات طلبات المستخدمين في التطبيق
@JsonSerializable()
class OrderModel extends Equatable {
  /// معرف الطلب الفريد
  final String id;
  
  /// معرف المستخدم الذي قام بالطلب
  final String userId;
  
  /// قائمة عناصر الطلب
  final List<OrderItemModel> items;
  
  /// إجمالي سعر المنتجات
  final double subtotal;
  
  /// رسوم التوصيل
  final double deliveryFee;
  
  /// قيمة الضريبة
  final double tax;
  
  /// قيمة الخصم (إن وجد)
  final double discount;
  
  /// إجمالي المبلغ المدفوع
  final double total;
  
  /// حالة الطلب (قيد الانتظار، قيد التحضير، قيد التوصيل، تم التسليم، ملغي)
  final OrderStatus status;
  
  /// طريقة الدفع المستخدمة
  final PaymentMethod paymentMethod;
  
  /// حالة الدفع (تم الدفع، قيد الانتظار، فشل)
  final PaymentStatus paymentStatus;
  
  /// معرف عنوان التوصيل
  final String deliveryAddressId;
  
  /// معرف موصل الطلب (إن وجد)
  final String? deliveryPersonId;
  
  /// ملاحظات الطلب
  final String? notes;
  
  /// تاريخ إنشاء الطلب
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للطلب
  final DateTime updatedAt;
  
  /// تاريخ تسليم الطلب (إن وجد)
  final DateTime? deliveredAt;

  /// منشئ النموذج
  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryAddressId,
    this.deliveryPersonId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? discount,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? deliveryAddressId,
    String? deliveryPersonId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  /// إنشاء نموذج من Map
  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        subtotal,
        deliveryFee,
        tax,
        discount,
        total,
        status,
        paymentMethod,
        paymentStatus,
        deliveryAddressId,
        deliveryPersonId,
        notes,
        createdAt,
        updatedAt,
        deliveredAt,
      ];
}

/// نموذج عنصر الطلب
@JsonSerializable()
class OrderItemModel extends Equatable {
  /// معرف المنتج
  final String productId;
  
  /// اسم المنتج
  final String productName;
  
  /// سعر الوحدة
  final double price;
  
  /// الكمية المطلوبة
  final int quantity;
  
  /// إجمالي سعر العنصر (السعر × الكمية)
  final double total;
  
  /// خيارات إضافية للمنتج (الحجم، اللون، الخ)
  final Map<String, dynamic>? options;

  /// منشئ النموذج
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.options,
  });

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  /// إنشاء نموذج من Map
  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);

  @override
  List<Object?> get props => [productId, productName, price, quantity, total, options];
}

/// تعداد حالات الطلب
enum OrderStatus {
  pending,     // قيد الانتظار
  processing,  // قيد التحضير
  shipping,    // قيد التوصيل
  delivered,   // تم التسليم
  cancelled,   // ملغي
}

/// تعداد طرق الدفع
enum PaymentMethod {
  cash,           // الدفع عند الاستلام
  creditCard,     // بطاقة ائتمان
  debitCard,      // بطاقة خصم
  wallet,         // محفظة إلكترونية
  bankTransfer,   // تحويل بنكي
}

/// تعداد حالات الدفع
enum PaymentStatus {
  pending,    // قيد الانتظار
  completed,  // مكتمل
  failed,     // فشل
  refunded,   // مسترد
}

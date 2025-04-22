import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

/// نموذج الطلب
/// يستخدم لتمثيل بيانات الطلبات في التطبيق
@JsonSerializable()
class OrderModel extends Equatable {
  /// معرف الطلب الفريد
  final String id;
  
  /// معرف المستخدم الذي قام بالطلب
  final String userId;
  
  /// معرف المتجر أو البائع
  final String sellerId;
  
  /// معرف موظف التوصيل (إن وجد)
  final String? deliveryPersonId;
  
  /// قائمة المنتجات في الطلب
  final List<OrderItem> items;
  
  /// إجمالي سعر المنتجات
  final double subtotal;
  
  /// تكلفة التوصيل
  final double deliveryFee;
  
  /// قيمة الضريبة
  final double tax;
  
  /// قيمة الخصم (إن وجد)
  final double discount;
  
  /// إجمالي المبلغ المطلوب دفعه
  final double total;
  
  /// حالة الطلب (قيد الانتظار، قيد التحضير، قيد التوصيل، تم التسليم، تم الإلغاء)
  final String status;
  
  /// طريقة الدفع (نقداً، بطاقة ائتمان، محفظة إلكترونية)
  final String paymentMethod;
  
  /// حالة الدفع (تم الدفع، قيد الانتظار، فشل)
  final String paymentStatus;
  
  /// عنوان التوصيل
  final Address deliveryAddress;
  
  /// ملاحظات إضافية للطلب
  final String? notes;
  
  /// تاريخ إنشاء الطلب
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للطلب
  final DateTime updatedAt;
  
  /// تاريخ التسليم المتوقع
  final DateTime? estimatedDeliveryTime;
  
  /// تاريخ التسليم الفعلي
  final DateTime? actualDeliveryTime;

  /// منشئ النموذج
  const OrderModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    this.deliveryPersonId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    this.discount = 0.0,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  OrderModel copyWith({
    String? id,
    String? userId,
    String? sellerId,
    String? deliveryPersonId,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? discount,
    double? total,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    Address? deliveryAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
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
        sellerId,
        deliveryPersonId,
        items,
        subtotal,
        deliveryFee,
        tax,
        discount,
        total,
        status,
        paymentMethod,
        paymentStatus,
        deliveryAddress,
        notes,
        createdAt,
        updatedAt,
        estimatedDeliveryTime,
        actualDeliveryTime,
      ];
}

/// نموذج عنصر الطلب
@JsonSerializable()
class OrderItem extends Equatable {
  /// معرف المنتج
  final String productId;
  
  /// اسم المنتج
  final String productName;
  
  /// سعر الوحدة
  final double price;
  
  /// الكمية المطلوبة
  final int quantity;
  
  /// إجمالي سعر العنصر
  final double total;
  
  /// خيارات إضافية للمنتج (اللون، الحجم، الخ)
  final Map<String, dynamic>? options;

  /// منشئ النموذج
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.options,
  });

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  /// إنشاء نموذج من Map
  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

  @override
  List<Object?> get props => [
        productId,
        productName,
        price,
        quantity,
        total,
        options,
      ];
}

/// نموذج العنوان
@JsonSerializable()
class Address extends Equatable {
  /// معرف العنوان
  final String id;
  
  /// الاسم المعطى للعنوان (المنزل، العمل، الخ)
  final String name;
  
  /// الاسم الكامل للمستلم
  final String recipientName;
  
  /// رقم هاتف المستلم
  final String phoneNumber;
  
  /// الدولة
  final String country;
  
  /// المدينة
  final String city;
  
  /// المنطقة أو الحي
  final String area;
  
  /// الشارع
  final String street;
  
  /// رقم المبنى أو الوحدة
  final String buildingNumber;
  
  /// معلومات إضافية للعنوان
  final String? additionalInfo;
  
  /// خط العرض
  final double? latitude;
  
  /// خط الطول
  final double? longitude;

  /// منشئ النموذج
  const Address({
    required this.id,
    required this.name,
    required this.recipientName,
    required this.phoneNumber,
    required this.country,
    required this.city,
    required this.area,
    required this.street,
    required this.buildingNumber,
    this.additionalInfo,
    this.latitude,
    this.longitude,
  });

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  /// إنشاء نموذج من Map
  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        recipientName,
        phoneNumber,
        country,
        city,
        area,
        street,
        buildingNumber,
        additionalInfo,
        latitude,
        longitude,
      ];
}

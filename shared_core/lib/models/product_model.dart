import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

/// نموذج المنتج
/// يستخدم لتمثيل بيانات المنتجات في التطبيق
@JsonSerializable()
class ProductModel extends Equatable {
  /// معرف المنتج الفريد
  final String id;
  
  /// اسم المنتج
  final String name;
  
  /// وصف المنتج
  final String description;
  
  /// سعر المنتج
  final double price;
  
  /// سعر المنتج بعد الخصم (إن وجد)
  final double? discountPrice;
  
  /// معرف الفئة التي ينتمي إليها المنتج
  final String categoryId;
  
  /// معرف البائع أو المتجر
  final String sellerId;
  
  /// قائمة بروابط صور المنتج
  final List<String> images;
  
  /// متوسط تقييم المنتج
  final double rating;
  
  /// عدد التقييمات
  final int reviewCount;
  
  /// كمية المخزون المتوفرة
  final int stockQuantity;
  
  /// وحدة القياس (كجم، قطعة، الخ)
  final String unit;
  
  /// الوزن بالكيلوجرام
  final double? weight;
  
  /// ما إذا كان المنتج متاحاً للبيع
  final bool isAvailable;
  
  /// ما إذا كان المنتج مميزاً
  final bool isFeatured;
  
  /// تاريخ إضافة المنتج
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للمنتج
  final DateTime updatedAt;
  
  /// خصائص إضافية للمنتج (اللون، الحجم، الخ)
  final Map<String, dynamic>? attributes;

  /// منشئ النموذج
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.sellerId,
    required this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.stockQuantity,
    required this.unit,
    this.weight,
    this.isAvailable = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.attributes,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    String? sellerId,
    List<String>? images,
    double? rating,
    int? reviewCount,
    int? stockQuantity,
    String? unit,
    double? weight,
    bool? isAvailable,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? attributes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attributes: attributes ?? this.attributes,
    );
  }

  /// حساب السعر النهائي للمنتج (بعد الخصم إن وجد)
  double get finalPrice => discountPrice ?? price;

  /// حساب نسبة الخصم
  double? get discountPercentage {
    if (discountPrice == null) return null;
    return ((price - discountPrice!) / price) * 100;
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  /// إنشاء نموذج من Map
  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPrice,
        categoryId,
        sellerId,
        images,
        rating,
        reviewCount,
        stockQuantity,
        unit,
        weight,
        isAvailable,
        isFeatured,
        createdAt,
        updatedAt,
        attributes,
      ];
}

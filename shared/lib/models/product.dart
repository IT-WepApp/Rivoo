import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'promotion.dart'; // ✅ استيراد enum من ملفه الرسمي

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String sellerId;
  final String? storeId; // ✅ مضاف لدعم معرف المتجر
  final String? notes; // ✅ مضاف لدعم الملاحظات
  final String status; // ✅ مضاف
  final bool hasPromotion;
  final PromotionType? promotionType;
  final double? promotionValue;
  final DateTime? promotionStartDate;
  final DateTime? promotionEndDate;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.sellerId,
    this.storeId,
    this.notes,
    this.status = 'active',
    this.hasPromotion = false,
    this.promotionType,
    this.promotionValue,
    this.promotionStartDate,
    this.promotionEndDate,
  });

  void validatePromotion() {
    if (hasPromotion) {
      if (promotionType == null) {
        throw Exception('Promotion type cannot be null when promotion is enabled.');
      }

      if (promotionValue == null) {
        throw Exception('Promotion value must be a positive number when promotion is enabled.');
      }

      final value = promotionValue!;
      if (value <= 0) {
        throw Exception('Promotion value must be a positive number when promotion is enabled.');
      }

      if (promotionEndDate != null && promotionStartDate == null) {
        throw Exception('Promotion start date can not be null when promotion end date is provided');
      }

      if (promotionStartDate != null && promotionEndDate == null) {
        throw Exception('Promotion end date can not be null when promotion start date is provided');
      }

      if (promotionStartDate != null && promotionEndDate != null) {
        if (!promotionStartDate!.isBefore(promotionEndDate!)) {
          throw Exception('Promotion start date must be before the end date.');
        }
      }
    }
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    String? sellerId,
    String? storeId,
    String? notes,
    String? status,
    bool? hasPromotion,
    PromotionType? promotionType,
    double? promotionValue,
    DateTime? promotionStartDate,
    DateTime? promotionEndDate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      storeId: storeId ?? this.storeId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      hasPromotion: hasPromotion ?? this.hasPromotion,
      promotionType: promotionType ?? this.promotionType,
      promotionValue: promotionValue ?? this.promotionValue,
      promotionStartDate: promotionStartDate ?? this.promotionStartDate,
      promotionEndDate: promotionEndDate ?? this.promotionEndDate,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        categoryId,
        sellerId,
        storeId,
        notes,
        status,
        hasPromotion,
        promotionType,
        promotionValue,
        promotionStartDate,
        promotionEndDate,
      ];
}

import 'package:json_annotation/json_annotation.dart';
import '../entities/product_entity.dart'; // Import the base entity
import 'promotion.dart'; // Import PromotionType enum
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp converters

part 'product.g.dart';

@JsonSerializable(explicitToJson: true) // Ensure nested objects are serialized
class Product extends ProductEntity {
  // Fields inherited from ProductEntity:
  // id, name, description, price, imageUrl, categoryId, createdAt, updatedAt

  // Fields specific to the Product model (for seller/admin context):
  final String sellerId;
  final String? storeId;
  final String? notes;
  final String status;
  final bool hasPromotion;
  final PromotionType? promotionType;
  final double? promotionValue;
  final DateTime? promotionStartDate;
  final DateTime? promotionEndDate;

  const Product({
    // Fields for ProductEntity (passed to super)
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required DateTime createdAt, // Added based on ProductEntity
    required DateTime updatedAt, // Added based on ProductEntity

    // Fields specific to this model
    required this.sellerId,
    this.storeId,
    this.notes,
    this.status = 'active',
    this.hasPromotion = false,
    this.promotionType,
    this.promotionValue,
    this.promotionStartDate,
    this.promotionEndDate,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          categoryId: categoryId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  // --- Validation --- (Kept as it's specific to this model's context)
  void validatePromotion() {
    if (hasPromotion) {
      if (promotionType == null) {
        throw Exception('Promotion type cannot be null when promotion is enabled.');
      }
      if (promotionValue == null || promotionValue! <= 0) {
        throw Exception('Promotion value must be a positive number when promotion is enabled.');
      }
      if (promotionStartDate != null && promotionEndDate != null) {
        if (!promotionStartDate!.isBefore(promotionEndDate!)) {
          throw Exception('Promotion start date must be before the end date.');
        }
      }
      // Add checks for start/end date consistency if needed
    }
  }

  // --- copyWith --- (Updated to include all fields)
  Product copyWith({
    // Entity fields
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Model specific fields
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
      // Entity fields
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Model specific fields
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

  // --- Serialization --- (Keep JsonSerializable methods)
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // --- Equatable --- (Updated props)
  @override
  List<Object?> get props => [
        // Include super.props and model-specific props
        ...super.props,
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

// --- Json Converters (if needed, especially for DateTime/Timestamp) ---
// Ensure these converters are available or defined here/globally
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

DateTime? _nullableDateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _nullableDateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);


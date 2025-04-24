// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      categoryId: json['categoryId'] as String,
      sellerId: json['sellerId'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      unit: json['unit'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      attributes: json['attributes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'discountPrice': instance.discountPrice,
      'categoryId': instance.categoryId,
      'sellerId': instance.sellerId,
      'images': instance.images,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'stockQuantity': instance.stockQuantity,
      'unit': instance.unit,
      'weight': instance.weight,
      'isAvailable': instance.isAvailable,
      'isFeatured': instance.isFeatured,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'attributes': instance.attributes,
    };

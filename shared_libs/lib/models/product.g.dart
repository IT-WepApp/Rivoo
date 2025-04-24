// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String,
      sellerId: json['sellerId'] as String,
      storeId: json['storeId'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
      hasPromotion: json['hasPromotion'] as bool? ?? false,
      promotionType:
          $enumDecodeNullable(_$PromotionTypeEnumMap, json['promotionType']),
      promotionValue: (json['promotionValue'] as num?)?.toDouble(),
      promotionStartDate: json['promotionStartDate'] == null
          ? null
          : DateTime.parse(json['promotionStartDate'] as String),
      promotionEndDate: json['promotionEndDate'] == null
          ? null
          : DateTime.parse(json['promotionEndDate'] as String),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'categoryId': instance.categoryId,
      'sellerId': instance.sellerId,
      'storeId': instance.storeId,
      'notes': instance.notes,
      'status': instance.status,
      'hasPromotion': instance.hasPromotion,
      'promotionType': _$PromotionTypeEnumMap[instance.promotionType],
      'promotionValue': instance.promotionValue,
      'promotionStartDate': instance.promotionStartDate?.toIso8601String(),
      'promotionEndDate': instance.promotionEndDate?.toIso8601String(),
    };

const _$PromotionTypeEnumMap = {
  PromotionType.percentageDiscount: 'percentage_discount',
  PromotionType.fixedAmountDiscount: 'fixed_amount_discount',
};

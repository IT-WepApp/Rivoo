// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promotion _$PromotionFromJson(Map<String, dynamic> json) => Promotion(
      id: json['id'] as String?,
      type: $enumDecode(_$PromotionTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$PromotionToJson(Promotion instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$PromotionTypeEnumMap[instance.type]!,
      'value': instance.value,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };

const _$PromotionTypeEnumMap = {
  PromotionType.percentageDiscount: 'percentage_discount',
  PromotionType.fixedAmountDiscount: 'fixed_amount_discount',
};

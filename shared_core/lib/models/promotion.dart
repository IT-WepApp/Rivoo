import 'package:json_annotation/json_annotation.dart';

part 'promotion.g.dart';

enum PromotionType {
  @JsonValue('percentage_discount')
  percentageDiscount,

  @JsonValue('fixed_amount_discount')
  fixedAmountDiscount,
}

@JsonSerializable()
class Promotion {
  final String? id;
  final PromotionType type;
  final double value;
  final DateTime? startDate;
  final DateTime? endDate;

  const Promotion({
    this.id,
    required this.type,
    required this.value,
    this.startDate,
    this.endDate,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (value <= 0) {
      errors['value'] = 'Discount value must be positive.';
    }
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      errors['endDate'] = 'End date must be after start date.';
    }
    return errors;
  }
}

extension PromotionTypeExtension on PromotionType {
  String toJsonValue() {
    switch (this) {
      case PromotionType.percentageDiscount:
        return 'percentage_discount';
      case PromotionType.fixedAmountDiscount:
        return 'fixed_amount_discount';
    }
  }

  static PromotionType fromJsonValue(String value) {
    switch (value) {
      case 'percentage_discount':
        return PromotionType.percentageDiscount;
      case 'fixed_amount_discount':
        return PromotionType.fixedAmountDiscount;
      default:
        throw Exception('Unknown PromotionType: $value');
    }
  }
}

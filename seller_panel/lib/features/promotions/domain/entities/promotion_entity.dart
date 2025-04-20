import 'package:equatable/equatable.dart';

/// كيان العرض الذي يمثل عرضًا ترويجيًا في النظام
class PromotionEntity extends Equatable {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final String type; // percentage, fixed_amount
  final double value;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> applicableProductIds;
  final bool isActive;
  final int? usageLimit;
  final int? usageCount;
  final String? code;
  final double? minimumOrderAmount;

  const PromotionEntity({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    required this.applicableProductIds,
    required this.isActive,
    this.usageLimit,
    this.usageCount,
    this.code,
    this.minimumOrderAmount,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        title,
        description,
        type,
        value,
        startDate,
        endDate,
        applicableProductIds,
        isActive,
        usageLimit,
        usageCount,
        code,
        minimumOrderAmount,
      ];

  bool get isExpired => DateTime.now().isAfter(endDate);
  
  bool get isNotStarted => DateTime.now().isBefore(startDate);
  
  bool get isAvailable => isActive && !isExpired && !isNotStarted;

  PromotionEntity copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    String? type,
    double? value,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? applicableProductIds,
    bool? isActive,
    int? usageLimit,
    int? usageCount,
    String? code,
    double? minimumOrderAmount,
  }) {
    return PromotionEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      code: code ?? this.code,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
    );
  }
}

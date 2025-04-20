import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// نموذج بيانات المنتج باستخدام Freezed
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required String category,
    required List<String> images,
    @Default(0) double discount,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(true) bool isAvailable,
    @Default({}) Map<String, dynamic> attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductModel;

  /// إنشاء نموذج من JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}

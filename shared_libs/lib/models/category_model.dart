import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

/// نموذج الفئة
/// يستخدم لتمثيل بيانات فئات المنتجات في التطبيق
@JsonSerializable()
class CategoryModel extends Equatable {
  /// معرف الفئة الفريد
  final String id;
  
  /// اسم الفئة
  final String name;
  
  /// وصف الفئة
  final String? description;
  
  /// رابط صورة الفئة
  final String? imageUrl;
  
  /// معرف الفئة الأب (إن وجدت)
  final String? parentId;
  
  /// ترتيب الفئة
  final int order;
  
  /// ما إذا كانت الفئة نشطة
  final bool isActive;
  
  /// ما إذا كانت الفئة مميزة
  final bool isFeatured;
  
  /// تاريخ إنشاء الفئة
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للفئة
  final DateTime updatedAt;

  /// منشئ النموذج
  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.parentId,
    this.order = 0,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? parentId,
    int? order,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  /// إنشاء نموذج من Map
  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        parentId,
        order,
        isActive,
        isFeatured,
        createdAt,
        updatedAt,
      ];
}

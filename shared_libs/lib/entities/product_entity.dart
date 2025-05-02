import 'package:equatable/equatable.dart';

/// كيان المنتج الأساسي الموحد
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // استخدام imageUrl بدلاً من image
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        categoryId,
        createdAt,
        updatedAt,
      ];

  // لا يوجد copyWith هنا، يمكن إضافته إذا لزم الأمر أو تركه للنماذج الموروثة
}


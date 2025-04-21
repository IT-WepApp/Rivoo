import 'package:equatable/equatable.dart';
import '../../../core/architecture/domain/entity.dart';

/// نموذج المنتج
class Product extends Entity with EquatableMixin {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String image;
  final List<String>? images;
  final String categoryId;
  final String? categoryName;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final Map<String, dynamic>? attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.image,
    this.images,
    required this.categoryId,
    this.categoryName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// حساب نسبة الخصم إذا كان هناك سعر مخفض
  double? get discountPercentage {
    if (discountPrice == null || discountPrice! >= price) {
      return null;
    }
    return ((price - discountPrice!) / price) * 100;
  }

  /// التحقق مما إذا كان المنتج جديدًا (أقل من 7 أيام)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7;
  }

  /// التحقق مما إذا كان المنتج مخفضًا
  bool get isDiscounted => discountPrice != null && discountPrice! < price;

  /// الحصول على السعر الفعلي (المخفض إذا كان متاحًا)
  double get actualPrice => discountPrice ?? price;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPrice,
        image,
        images,
        categoryId,
        categoryName,
        rating,
        reviewCount,
        inStock,
        attributes,
        createdAt,
        updatedAt,
      ];
}

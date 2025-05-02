import 'package:shared_libs/entities/product_entity.dart'; // Import the base entity

/// نموذج المنتج الخاص بواجهة المستخدم (يرث من الكيان الأساسي)
class UserProduct extends ProductEntity {
  // Fields inherited from ProductEntity:
  // id, name, description, price, imageUrl, categoryId, createdAt, updatedAt

  // Fields specific to the user-facing product view:
  final double? discountPrice;
  final List<String>? images; // Additional images
  final String? categoryName;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final Map<String, dynamic>? attributes;

  const UserProduct({
    // Fields for ProductEntity (passed to super)
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required DateTime createdAt,
    required DateTime updatedAt,

    // Fields specific to this user-facing model
    this.discountPrice,
    this.images,
    this.categoryName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.attributes,
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

  // --- copyWith --- (Updated to include all fields)
  UserProduct copyWith({
    // Entity fields
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    // UserProduct specific fields
    double? discountPrice,
    List<String>? images,
    String? categoryName,
    double? rating,
    int? reviewCount,
    bool? inStock,
    Map<String, dynamic>? attributes,
  }) {
    return UserProduct(
      // Entity fields
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // UserProduct specific fields
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      attributes: attributes ?? this.attributes,
    );
  }

  // --- Equatable --- (Updated props)
  @override
  List<Object?> get props => [
        // Include super.props and model-specific props
        ...super.props,
        discountPrice,
        images,
        categoryName,
        rating,
        reviewCount,
        inStock,
        attributes,
      ];
}


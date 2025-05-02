import 'package:shared_libs/entities/product_entity.dart'; // Import base entity
import 'package:user_app/features/products/domain/product_status.dart'; // Import ProductStatus enum

/// كيان تفاصيل المنتج (يرث من الكيان الأساسي)
class ProductDetails extends ProductEntity {
  // Fields inherited from ProductEntity:
  // id, name, description, price, imageUrl, categoryId, createdAt, updatedAt

  // Fields specific to the product details view:
  final double? discountPrice;
  final List<String> additionalImages;
  final double rating;
  final int reviewCount; // Using reviewCount consistently
  final bool inStock;
  final int quantity;
  final List<String> tags;
  final bool isFeatured;
  // isNew can be calculated from createdAt
  // isOnSale can be calculated from discountPrice
  final ProductStatus status;

  const ProductDetails({
    // Fields for ProductEntity (passed to super)
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required DateTime createdAt,
    required DateTime updatedAt,

    // Fields specific to this details model
    this.discountPrice,
    this.additionalImages = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.quantity = 0,
    this.tags = const [],
    this.isFeatured = false,
    this.status = ProductStatus.available,
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
  bool get isOnSale => discountPrice != null && discountPrice! < price;

  /// الحصول على السعر الفعلي (المخفض إذا كان متاحًا)
  double get actualPrice => discountPrice ?? price;

  /// هل المنتج متاح للشراء
  bool get isAvailable => status == ProductStatus.available && inStock;

  // --- copyWith --- (Updated to include all fields)
  ProductDetails copyWith({
    // Entity fields
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    // ProductDetails specific fields
    double? discountPrice,
    List<String>? additionalImages,
    double? rating,
    int? reviewCount,
    bool? inStock,
    int? quantity,
    List<String>? tags,
    bool? isFeatured,
    ProductStatus? status,
  }) {
    return ProductDetails(
      // Entity fields
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // ProductDetails specific fields
      discountPrice: discountPrice ?? this.discountPrice,
      additionalImages: additionalImages ?? this.additionalImages,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      quantity: quantity ?? this.quantity,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
    );
  }

  // --- Equatable --- (Updated props)
  @override
  List<Object?> get props => [
        // Include super.props and model-specific props
        ...super.props,
        discountPrice,
        additionalImages,
        rating,
        reviewCount,
        inStock,
        quantity,
        tags,
        isFeatured,
        status,
      ];
}


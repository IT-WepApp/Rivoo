// طبقة Domain - كيان المنتج
// هذا الملف يحتوي على تعريف كيان المنتج بشكل مستقل عن مصادر البيانات

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String category;
  final bool isAvailable;
  final String sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? attributes;
  final int stockQuantity;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.isAvailable,
    required this.sellerId,
    required this.createdAt,
    required this.updatedAt,
    this.attributes,
    this.stockQuantity = 0,
  });

  // نسخة جديدة من الكيان مع تحديث بعض الخصائص
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? category,
    bool? isAvailable,
    String? sellerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? attributes,
    int? stockQuantity,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attributes: attributes ?? this.attributes,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}

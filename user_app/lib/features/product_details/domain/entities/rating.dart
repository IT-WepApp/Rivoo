import 'package:user_app/core/architecture/domain/entity.dart';

/// كيان التقييم
class Rating extends Entity {
  /// معرف المستخدم الذي قام بالتقييم
  final String userId;
  
  /// معرف المنتج الذي تم تقييمه
  final String productId;
  
  /// قيمة التقييم (من 1 إلى 5)
  final double rating;
  
  /// نص المراجعة
  final String? review;
  
  /// تاريخ إنشاء التقييم
  final DateTime createdAt;

  /// إنشاء كيان التقييم
  const Rating({
    required String id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.review,
    required this.createdAt,
  }) : super(id: id);

  /// نسخة جديدة من الكيان مع تحديث بعض الحقول
  Rating copyWith({
    String? id,
    String? userId,
    String? productId,
    double? rating,
    String? review,
    DateTime? createdAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        productId,
        rating,
        review,
        createdAt,
      ];
}

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
  
  /// اسم المستخدم الظاهر
  final String userDisplayName;
  
  /// هل التقييم من مشتري مؤكد
  final bool isVerifiedPurchase;

  /// إنشاء كيان التقييم
  const Rating({
    required String id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.review,
    required this.createdAt,
    required this.userDisplayName,
    this.isVerifiedPurchase = false,
  }) : super(id: id);

  @override
  List<Object?> get props => [
        id,
        userId,
        productId,
        rating,
        review,
        createdAt,
        userDisplayName,
        isVerifiedPurchase,
      ];
}

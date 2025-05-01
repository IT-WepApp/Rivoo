import 'package:equatable/equatable.dart';

/// كيان التقييم والمراجعة الموحد
class RatingEntity extends Equatable {
  /// معرف التقييم الفريد
  final String id;
  
  /// معرف المنتج الذي تم تقييمه
  final String productId;
  
  /// معرف المستخدم الذي قام بالتقييم
  final String userId;
  
  /// اسم المستخدم الذي قام بالتقييم
  final String userName; // تم الاحتفاظ به من ReviewModel
  
  /// صورة المستخدم (إن وجدت)
  final String? userImage; // تم الاحتفاظ به من ReviewModel
  
  /// قيمة التقييم (من 1 إلى 5)
  final double rating;
  
  /// نص المراجعة / التعليق
  final String? comment; // تم تغيير الاسم من review و comment
  
  /// روابط الصور المرفقة بالتقييم (إن وجدت)
  final List<String>? images; // تم الاحتفاظ به من ReviewModel
  
  /// هل التقييم معتمد ومنشور (قد يستخدمه المشرفون)
  final bool isApproved; // تم الاحتفاظ به من ReviewModel

  /// هل التقييم من مشتري مؤكد
  final bool isVerifiedPurchase; // تم إضافته من Rating entity
  
  /// تاريخ إنشاء التقييم
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للتقييم
  final DateTime updatedAt; // تم الاحتفاظ به من ReviewModel

  /// منشئ الكيان
  const RatingEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    this.comment,
    this.images,
    this.isApproved = false,
    this.isVerifiedPurchase = false, // القيمة الافتراضية false
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة من الكيان مع تحديث بعض الحقول
  RatingEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userImage,
    double? rating,
    String? comment,
    List<String>? images,
    bool? isApproved,
    bool? isVerifiedPurchase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isApproved: isApproved ?? this.isApproved,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userImage,
        rating,
        comment,
        images,
        isApproved,
        isVerifiedPurchase,
        createdAt,
        updatedAt,
      ];
}

/// ملخص التقييمات لمنتج معين
class RatingSummary extends Equatable {
  final String productId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingCounts; // مثال: {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  const RatingSummary({
    required this.productId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingCounts,
  });

  @override
  List<Object?> get props => [productId, averageRating, totalRatings, ratingCounts];
}


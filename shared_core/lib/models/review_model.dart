import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

/// نموذج التقييم
/// يستخدم لتمثيل بيانات تقييمات المستخدمين للمنتجات في التطبيق
@JsonSerializable()
class ReviewModel extends Equatable {
  /// معرف التقييم الفريد
  final String id;
  
  /// معرف المنتج الذي تم تقييمه
  final String productId;
  
  /// معرف المستخدم الذي قام بالتقييم
  final String userId;
  
  /// اسم المستخدم الذي قام بالتقييم
  final String userName;
  
  /// صورة المستخدم (إن وجدت)
  final String? userImage;
  
  /// عدد النجوم (من 1 إلى 5)
  final double rating;
  
  /// عنوان التقييم (إن وجد)
  final String? title;
  
  /// نص التقييم
  final String comment;
  
  /// روابط الصور المرفقة بالتقييم (إن وجدت)
  final List<String>? images;
  
  /// ما إذا كان التقييم معتمداً ومنشوراً
  final bool isApproved;
  
  /// تاريخ إنشاء التقييم
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للتقييم
  final DateTime updatedAt;

  /// منشئ النموذج
  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    this.title,
    required this.comment,
    this.images,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userImage,
    double? rating,
    String? title,
    String? comment,
    List<String>? images,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  /// إنشاء نموذج من Map
  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userImage,
        rating,
        title,
        comment,
        images,
        isApproved,
        createdAt,
        updatedAt,
      ];
}

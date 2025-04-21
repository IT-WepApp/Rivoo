import 'package:flutter/material.dart';
import 'package:user_app/features/ratings/data/datasources/rating_remote_datasource.dart';

/// مصدر بيانات التقييمات عن بعد
class RatingRemoteDataSource {
  final String baseUrl;
  final Map<String, String> headers;

  RatingRemoteDataSource({
    required this.baseUrl,
    required this.headers,
  });

  /// الحصول على تقييمات منتج معين
  Future<List<Map<String, dynamic>>> getRatingsForProduct(String productId) async {
    // محاكاة طلب HTTP للحصول على تقييمات منتج
    await Future.delayed(const Duration(milliseconds: 800));
    
    // بيانات وهمية للتقييمات
    return [
      {
        'id': 'rating1',
        'userId': 'user1',
        'productId': productId,
        'userName': 'أحمد محمد',
        'rating': 4.5,
        'comment': 'منتج رائع، أنصح به بشدة!',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'rating2',
        'userId': 'user2',
        'productId': productId,
        'userName': 'سارة علي',
        'rating': 5.0,
        'comment': 'جودة ممتازة وسعر مناسب',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'id': 'rating3',
        'userId': 'user3',
        'productId': productId,
        'userName': 'محمد خالد',
        'rating': 3.5,
        'comment': 'منتج جيد ولكن هناك بعض المشاكل البسيطة',
        'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
    ];
  }

  /// الحصول على تقييم محدد
  Future<Map<String, dynamic>> getRating(String ratingId) async {
    // محاكاة طلب HTTP للحصول على تقييم محدد
    await Future.delayed(const Duration(milliseconds: 500));
    
    // بيانات وهمية للتقييم
    return {
      'id': ratingId,
      'userId': 'user1',
      'productId': 'product1',
      'userName': 'أحمد محمد',
      'rating': 4.5,
      'comment': 'منتج رائع، أنصح به بشدة!',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    };
  }

  /// إضافة تقييم جديد
  Future<Map<String, dynamic>> addRating({
    required String userId,
    required String productId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    // محاكاة طلب HTTP لإضافة تقييم جديد
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // بيانات التقييم الجديد
    return {
      'id': 'rating_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'productId': productId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// تحديث تقييم موجود
  Future<Map<String, dynamic>> updateRating({
    required String ratingId,
    required double rating,
    required String comment,
  }) async {
    // محاكاة طلب HTTP لتحديث تقييم موجود
    await Future.delayed(const Duration(milliseconds: 800));
    
    // بيانات التقييم المحدث
    return {
      'id': ratingId,
      'userId': 'user1',
      'productId': 'product1',
      'userName': 'أحمد محمد',
      'rating': rating,
      'comment': comment,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// حذف تقييم
  Future<void> deleteRating(String ratingId) async {
    // محاكاة طلب HTTP لحذف تقييم
    await Future.delayed(const Duration(milliseconds: 600));
    
    // لا يوجد بيانات للإرجاع في حالة الحذف
    return;
  }

  /// الحصول على متوسط التقييم لمنتج معين
  Future<double> getAverageRating(String productId) async {
    // محاكاة طلب HTTP للحصول على متوسط التقييم
    await Future.delayed(const Duration(milliseconds: 400));
    
    // متوسط وهمي للتقييم
    return 4.2;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/ratings/data/datasources/rating_datasource.dart';

/// مزود حالة التقييمات
final ratingsNotifierProvider = StateNotifierProvider<RatingsNotifier, RatingsState>((ref) {
  return RatingsNotifier();
});

/// حالة التقييمات
class RatingsState {
  /// هل جاري التحميل
  final bool isLoading;
  
  /// هل حدث خطأ
  final bool hasError;
  
  /// رسالة الخطأ
  final String? errorMessage;
  
  /// ملخص التقييمات
  final RatingSummary? summary;
  
  /// قائمة التقييمات
  final List<Rating> ratings;
  
  /// التقييم الحالي للمستخدم
  final Rating? userRating;

  /// إنشاء حالة التقييمات
  const RatingsState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.summary,
    this.ratings = const [],
    this.userRating,
  });

  /// نسخة جديدة من الحالة مع تحديث بعض الحقول
  RatingsState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    RatingSummary? summary,
    List<Rating>? ratings,
    Rating? userRating,
    bool clearError = false,
  }) {
    return RatingsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      summary: summary ?? this.summary,
      ratings: ratings ?? this.ratings,
      userRating: userRating ?? this.userRating,
    );
  }
}

/// مدير حالة التقييمات
class RatingsNotifier extends StateNotifier<RatingsState> {
  /// إنشاء مدير حالة التقييمات
  RatingsNotifier() : super(const RatingsState());

  /// تحميل التقييمات لمنتج معين
  Future<void> loadRatings(String productId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // هنا يتم استدعاء مستودع التقييمات لجلب البيانات
      // await _repository.getRatings(productId)
      
      // لأغراض الاختبار، نستخدم بيانات وهمية
      await Future.delayed(const Duration(seconds: 1));
      
      final ratings = [
        Rating(
          id: '1',
          userId: 'user1',
          productId: productId,
          rating: 4.5,
          review: 'منتج رائع!',
          createdAt: DateTime.now(),
          userDisplayName: 'أحمد محمد',
          isVerifiedPurchase: true,
        ),
        Rating(
          id: '2',
          userId: 'user2',
          productId: productId,
          rating: 3.0,
          review: 'منتج جيد ولكن يمكن تحسينه',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          userDisplayName: 'سارة أحمد',
          isVerifiedPurchase: true,
        ),
      ];
      
      final summary = RatingSummary(
        productId: productId,
        averageRating: 3.8,
        totalRatings: 10,
        ratingDistribution: {
          5: 5,
          4: 2,
          3: 1,
          2: 1,
          1: 1,
        },
      );
      
      state = state.copyWith(
        isLoading: false,
        ratings: ratings,
        summary: summary,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// إضافة تقييم جديد
  Future<void> addRating(Rating rating) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // هنا يتم استدعاء مستودع التقييمات لإضافة التقييم
      // await _repository.addRating(rating)
      
      // لأغراض الاختبار، نستخدم تأخير وهمي
      await Future.delayed(const Duration(seconds: 1));
      
      // تحديث قائمة التقييمات وملخص التقييمات
      final updatedRatings = [...state.ratings, rating];
      
      state = state.copyWith(
        isLoading: false,
        ratings: updatedRatings,
        userRating: rating,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// تحديث تقييم موجود
  Future<void> updateRating(Rating rating) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // هنا يتم استدعاء مستودع التقييمات لتحديث التقييم
      // await _repository.updateRating(rating)
      
      // لأغراض الاختبار، نستخدم تأخير وهمي
      await Future.delayed(const Duration(seconds: 1));
      
      // تحديث قائمة التقييمات
      final updatedRatings = state.ratings.map((r) {
        if (r.id == rating.id) {
          return rating;
        }
        return r;
      }).toList();
      
      state = state.copyWith(
        isLoading: false,
        ratings: updatedRatings,
        userRating: rating,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// حذف تقييم
  Future<void> deleteRating(String ratingId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // هنا يتم استدعاء مستودع التقييمات لحذف التقييم
      // await _repository.deleteRating(ratingId)
      
      // لأغراض الاختبار، نستخدم تأخير وهمي
      await Future.delayed(const Duration(seconds: 1));
      
      // تحديث قائمة التقييمات
      final updatedRatings = state.ratings.where((r) => r.id != ratingId).toList();
      
      state = state.copyWith(
        isLoading: false,
        ratings: updatedRatings,
        userRating: state.userRating?.id == ratingId ? null : state.userRating,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/ratings/providers/ratings_notifier.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_summary.dart';
import 'package:user_app/features/ratings/presentation/widgets/review_card.dart';
import 'package:user_app/features/ratings/presentation/screens/add_review_screen.dart';

// مزود لقائمة مراجعات منتج معين
final productReviewsProvider =
    FutureProvider.family<List<RatingModel>, String>((ref, productId) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
      .collection('ratings')
      .where('targetId', isEqualTo: productId)
      .where('targetType', isEqualTo: 'product')
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs
      .map((doc) => RatingModel.fromMap(doc.id, doc.data()))
      .toList();
});

// مزود لتوزيع التقييمات لمنتج معين (1-5 نجوم)
final productRatingDistributionProvider =
    FutureProvider.family<Map<int, int>, String>((ref, productId) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
      .collection('ratings')
      .where('targetId', isEqualTo: productId)
      .where('targetType', isEqualTo: 'product')
      .get();

  final ratingDistribution = <int, int>{};
  for (int i = 1; i <= 5; i++) {
    ratingDistribution[i] = 0;
  }

  for (final doc in snapshot.docs) {
    final rating = (doc.data()['rating'] ?? 0.0).toDouble();
    final ratingInt = rating.round();
    if (ratingInt >= 1 && ratingInt <= 5) {
      ratingDistribution[ratingInt] = (ratingDistribution[ratingInt] ?? 0) + 1;
    }
  }

  return ratingDistribution;
});

class ProductReviewsScreen extends ConsumerWidget {
  final String productId;
  final String productName;

  const ProductReviewsScreen({
    Key? key,
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final distributionAsync =
        ref.watch(productRatingDistributionProvider(productId));
    final averageRatingAsync = ref.watch(productRatingProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييمات المنتج'),
        centerTitle: true,
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان المنتج
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // ملخص التقييمات
                      averageRatingAsync.when(
                        data: (averageRating) {
                          return distributionAsync.when(
                            data: (distribution) {
                              return RatingSummary(
                                averageRating: averageRating,
                                ratingsCount: reviews.length,
                                ratingDistribution: distribution,
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 24),

                      // عنوان المراجعات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المراجعات (${reviews.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة مراجعة'),
                            onPressed: () => _addReview(context, ref),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // قائمة المراجعات
              if (reviews.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('لا توجد مراجعات بعد. كن أول من يضيف مراجعة!'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final review = reviews[index];
                        return ReviewCard(
                          rating: review,
                          showActions: false,
                        );
                      },
                      childCount: reviews.length,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('حدث خطأ أثناء تحميل المراجعات: $error'),
        ),
      ),
    );
  }

  void _addReview(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(
          targetId: productId,
          targetType: 'product',
          targetName: productName,
        ),
      ),
    );

    if (result == true) {
      // تحديث المراجعات بعد الإضافة
      ref.refresh(productReviewsProvider(productId));
      ref.refresh(productRatingDistributionProvider(productId));
      ref.refresh(productRatingProvider(productId));
    }
  }
}

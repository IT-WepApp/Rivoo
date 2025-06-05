import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/widgets/widgets.dart';
import 'package:user_app/features/ratings/providers/ratings_notifier.dart';
import 'package:intl/intl.dart';

class RatingsPage extends ConsumerWidget {
  const RatingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(userRatingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييماتي'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ratingsAsync.when(
        data: (ratings) {
          if (ratings.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(userRatingsProvider.notifier).loadUserRatings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return _buildRatingCard(context, ref, rating);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('حدث خطأ أثناء تحميل التقييمات: $error'),
              const SizedBox(height: 16),
              AppButton(
                text: 'إعادة المحاولة',
                onPressed: () =>
                    ref.read(userRatingsProvider.notifier).loadUserRatings(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'لم تقم بإضافة أي تقييمات بعد',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'قم بتقييم المنتجات والمندوبين بعد استلام طلباتك',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(
      BuildContext context, WidgetRef ref, RatingModel rating) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(rating.createdAt);
    final isProduct = rating.targetType == 'product';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isProduct ? Icons.shopping_bag : Icons.delivery_dining,
                  color: isProduct ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isProduct ? 'تقييم منتج' : 'تقييم مندوب',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRatingStars(rating.rating),
                const SizedBox(width: 8),
                Text(
                  rating.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                rating.comment!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تعديل'),
                  onPressed: () {
                    _showRatingDialog(
                      context,
                      ref,
                      rating.targetId,
                      rating.targetType,
                      initialRating: rating.rating,
                      initialComment: rating.comment,
                    );
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('حذف'),
                  onPressed: () {
                    _confirmDeleteRating(context, ref, rating.id);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index < rating.ceil() && rating.floor() != rating.ceil()) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  void _showRatingDialog(
    BuildContext context,
    WidgetRef ref,
    String targetId,
    String targetType, {
    double initialRating = 0,
    String? initialComment,
  }) {
    double rating = initialRating;
    final commentController = TextEditingController(text: initialComment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(targetType == 'product' ? 'تقييم المنتج' : 'تقييم المندوب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر تقييمك:'),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'تعليق (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userRatingsProvider.notifier).addRating(
                    targetId: targetId,
                    targetType: targetType,
                    rating: rating,
                    comment: commentController.text.isEmpty
                        ? null
                        : commentController.text,
                  );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRating(
      BuildContext context, WidgetRef ref, String ratingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التقييم'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا التقييم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userRatingsProvider.notifier).deleteRating(ratingId);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

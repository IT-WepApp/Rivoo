import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/features/ratings/application/ratings_notifier.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_stars.dart';

class ReviewCard extends StatelessWidget {
  final RatingModel rating;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ReviewCard({
    Key? key,
    required this.rating,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(rating.createdAt);
    final isProduct = rating.targetType == 'product';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isProduct
                      ? Colors.blue.withValues(alpha: 26) // 0.1 * 255 = 26
                      : Colors.green.withValues(alpha: 26), // 0.1 * 255 = 26
                  child: Icon(
                    isProduct ? Icons.shopping_bag : Icons.delivery_dining,
                    color: isProduct ? Colors.blue : Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProduct ? 'تقييم منتج' : 'تقييم مندوب',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                RatingStars(
                  rating: rating.rating,
                  size: 18,
                  alignment: MainAxisAlignment.end,
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 26), // 0.1 * 255 = 26
                  ),
                ),
                child: Text(
                  rating.comment!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('تعديل'),
                      onPressed: onEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('حذف'),
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

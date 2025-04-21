import 'package:flutter/material.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_stars.dart';

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int ratingsCount;
  final Map<int, int>? ratingDistribution;

  const RatingSummary({
    Key? key,
    required this.averageRating,
    required this.ratingsCount,
    this.ratingDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'التقييم العام',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingStars(
                    rating: averageRating,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ratingsCount تقييم',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          if (ratingDistribution != null) ...[
            const SizedBox(height: 24),
            _buildRatingDistribution(context),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(BuildContext context) {
    final theme = Theme.of(context);
    final distribution = ratingDistribution!;
    final maxCount =
        distribution.values.fold(0, (max, count) => count > max ? count : max);

    return Column(
      children: List.generate(5, (index) {
        final starCount = 5 - index;
        final count = distribution[starCount] ?? 0;
        final percentage = maxCount > 0 ? count / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$starCount',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    color: Colors.amber,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  count.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

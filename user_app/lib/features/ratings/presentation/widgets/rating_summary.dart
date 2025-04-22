import 'package:flutter/material.dart';
import 'package:user_app/features/ratings/domain/entities/rating.dart';

/// مكون عرض ملخص التقييمات
class RatingSummaryWidget extends StatelessWidget {
  /// متوسط التقييم
  final double averageRating;
  
  /// إجمالي عدد التقييمات
  final int totalRatings;
  
  /// توزيع التقييمات (مفتاح: عدد النجوم، قيمة: عدد التقييمات)
  final Map<int, int> ratingDistribution;

  /// إنشاء مكون ملخص التقييمات
  const RatingSummaryWidget({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$totalRatings ${_getRatingsText()}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (index) {
          final starCount = 5 - index;
          final count = ratingDistribution[starCount] ?? 0;
          final percentage = totalRatings > 0 
              ? count / totalRatings 
              : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '$starCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorForRating(starCount),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// الحصول على نص التقييمات المناسب
  String _getRatingsText() {
    if (totalRatings == 0) {
      return 'تقييمات';
    } else if (totalRatings == 1) {
      return 'تقييم';
    } else if (totalRatings == 2) {
      return 'تقييمان';
    } else if (totalRatings >= 3 && totalRatings <= 10) {
      return 'تقييمات';
    } else {
      return 'تقييم';
    }
  }

  /// الحصول على لون مناسب لعدد النجوم
  Color _getColorForRating(int starCount) {
    switch (starCount) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

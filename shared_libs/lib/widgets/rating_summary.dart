import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/rating_stars.dart';

/// ملخص التقييمات
///
/// مكون يعرض ملخص التقييمات لمنتج معين، بما في ذلك متوسط التقييم وتوزيع النجوم
class RatingSummary extends StatelessWidget {
  /// متوسط التقييم (من 0 إلى 5)
  final double averageRating;
  
  /// عدد التقييمات
  final int totalRatings;
  
  /// توزيع التقييمات حسب عدد النجوم
  /// المفتاح هو عدد النجوم (1-5)، والقيمة هي عدد التقييمات
  final Map<int, int> ratingDistribution;
  
  /// هل يتم عرض توزيع التقييمات؟
  final bool showDistribution;
  
  /// إنشاء ملخص التقييمات
  const RatingSummary({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    this.showDistribution = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAverageRating(),
          if (showDistribution && ratingDistribution.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRatingDistribution(),
          ],
        ],
      ),
    );
  }

  /// بناء متوسط التقييم
  Widget _buildAverageRating() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$totalRatings ${_getRatingsText()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingStars(
                rating: averageRating,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                _getRatingDescription(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء توزيع التقييمات
  Widget _buildRatingDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'توزيع التقييمات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          final starCount = 5 - index;
          final ratingCount = ratingDistribution[starCount] ?? 0;
          final percentage = totalRatings > 0
              ? (ratingCount / totalRatings) * 100
              : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRatingBar(starCount, ratingCount, percentage),
          );
        }),
      ],
    );
  }

  /// بناء شريط التقييم
  Widget _buildRatingBar(int starCount, int ratingCount, double percentage) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            '$starCount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(
          Icons.star,
          size: 16,
          color: AppTheme.starColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getColorForStarCount(starCount),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '($ratingCount)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// الحصول على لون لعدد النجوم
  Color _getColorForStarCount(int starCount) {
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

  /// الحصول على نص التقييمات
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

  /// الحصول على وصف التقييم
  String _getRatingDescription() {
    if (averageRating >= 4.5) {
      return 'ممتاز';
    } else if (averageRating >= 3.5) {
      return 'جيد جداً';
    } else if (averageRating >= 2.5) {
      return 'جيد';
    } else if (averageRating >= 1.5) {
      return 'مقبول';
    } else {
      return 'ضعيف';
    }
  }
}

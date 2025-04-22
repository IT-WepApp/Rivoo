import 'package:flutter/material.dart';
import 'package:user_app/features/ratings/data/datasources/rating_datasource.dart';

/// مكون ملخص التقييمات
class RatingSummaryWidget extends StatelessWidget {
  /// متوسط التقييم
  final double averageRating;
  
  /// إجمالي عدد التقييمات
  final int totalRatings;
  
  /// توزيع التقييمات (عدد التقييمات لكل نجمة)
  final Map<int, int> ratingDistribution;
  
  /// الحجم
  final double size;
  
  /// إنشاء مكون ملخص التقييمات
  const RatingSummaryWidget({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    this.size = 16,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // متوسط التقييم والنجوم
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: size * 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    if (index < averageRating.floor()) {
                      return Icon(Icons.star, size: size, color: Colors.amber);
                    } else if (index == averageRating.floor() && averageRating % 1 > 0) {
                      return Icon(Icons.star_half, size: size, color: Colors.amber);
                    } else {
                      return Icon(Icons.star_border, size: size, color: Colors.amber);
                    }
                  }),
                ),
                Text(
                  '$totalRatings تقييمات',
                  style: TextStyle(
                    fontSize: size * 0.8,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // توزيع التقييمات
        ...List.generate(5, (index) {
          final starNumber = 5 - index;
          final count = ratingDistribution[starNumber] ?? 0;
          final percentage = totalRatings > 0
              ? (count / totalRatings) * 100
              : 0.0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  '$starNumber',
                  style: TextStyle(
                    fontSize: size * 0.9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star, size: size * 0.9, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: size * 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: size * 0.9,
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
}

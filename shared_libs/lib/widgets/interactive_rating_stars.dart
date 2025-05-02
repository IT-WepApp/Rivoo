import 'package:flutter/material.dart';
import 'package:user_app/features/product_details/domain/entities/rating.dart';

/// مكون نجوم التقييم التفاعلية
class InteractiveRatingStars extends StatefulWidget {
  /// قيمة التقييم الأولية
  final double initialRating;
  
  /// الحجم
  final double size;
  
  /// اللون
  final Color? color;
  
  /// دالة تنفذ عند تغيير التقييم
  final Function(double) onRatingChanged;
  
  /// إنشاء نجوم التقييم التفاعلية
  const InteractiveRatingStars({
    Key? key,
    this.initialRating = 0.0,
    this.size = 40,
    this.color,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  late double _rating;
  
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }
  
  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
              widget.onRatingChanged(_rating);
            });
          },
          onHorizontal: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final starWidth = box.size.width / 5;
            final starIndex = (localPosition.dx / starWidth).floor();
            
            if (starIndex >= 0 && starIndex < 5) {
              final position = localPosition.dx - (starIndex * starWidth);
              final rating = starIndex + (position / starWidth);
              
              setState(() {
                _rating = rating.clamp(0.0, 5.0);
                widget.onRatingChanged(_rating);
              });
            }
          },
          child: Icon(
            index < _rating.floor()
                ? Icons.star
                : (index == _rating.floor() && _rating % 1 > 0)
                    ? Icons.star_half
                    : Icons.star_border,
            size: widget.size,
            color: starColor,
          ),
        );
      }),
    );
  }
}

/// مكون ملخص التقييمات
class RatingSummaryWidget extends StatelessWidget {
  /// ملخص التقييمات
  final RatingSummary summary;
  
  /// الحجم
  final double size;
  
  /// إنشاء مكون ملخص التقييمات
  const RatingSummaryWidget({
    Key? key,
    required this.summary,
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
              summary.averageRating.toStringAsFixed(1),
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
                    if (index < summary.averageRating.floor()) {
                      return Icon(Icons.star, size: size, color: Colors.amber);
                    } else if (index == summary.averageRating.floor() && summary.averageRating % 1 > 0) {
                      return Icon(Icons.star_half, size: size, color: Colors.amber);
                    } else {
                      return Icon(Icons.star_border, size: size, color: Colors.amber);
                    }
                  }),
                ),
                Text(
                  '${summary.totalRatings} تقييم',
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
          final count = summary.ratingDistribution[starNumber] ?? 0;
          final percentage = summary.totalRatings > 0
              ? (count / summary.totalRatings) * 100
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

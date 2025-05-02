import 'package:flutter/material.dart';
import 'package:shared_libs/entities/rating_entity.dart';

/// نجوم التقييم
class RatingStars extends StatelessWidget {
  /// قيمة التقييم
  final double rating;
  
  /// الحجم
  final double size;
  
  /// اللون
  final Color? color;
  
  /// عرض الرقم
  final bool showNumber;

  /// إنشاء نجوم التقييم
  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 20,
    this.color,
    this.showNumber = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // النجوم
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              // نجمة كاملة
              return Icon(
                Icons.star,
                size: size,
                color: starColor,
              );
            } else if (index == rating.floor() && rating % 1 > 0) {
              // نجمة نصفية
              return Icon(
                Icons.star_half,
                size: size,
                color: starColor,
              );
            } else {
              // نجمة فارغة
              return Icon(
                Icons.star_border,
                size: size,
                color: starColor,
              );
            }
          }),
        ),
        
        // عرض الرقم
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }
}

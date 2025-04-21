import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';

/// نجوم التقييم التفاعلية
class InteractiveRatingStars extends StatefulWidget {
  /// القيمة الأولية للتقييم
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
    this.initialRating = 0,
    this.size = 40,
    this.color,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  /// قيمة التقييم الحالية
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? AppTheme.primaryColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
              widget.onRatingChanged(_currentRating);
            });
          },
          child: Icon(
            index < _currentRating.floor()
                ? Icons.star
                : (index == _currentRating.floor() && _currentRating % 1 > 0)
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

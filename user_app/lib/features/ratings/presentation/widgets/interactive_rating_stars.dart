import 'package:flutter/material.dart';

class InteractiveRatingStars extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final Color color;
  final Color borderColor;
  final bool showRatingNumber;
  final TextStyle? ratingTextStyle;

  const InteractiveRatingStars({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 36,
    this.color = Colors.amber,
    this.borderColor = Colors.amber,
    this.showRatingNumber = true,
    this.ratingTextStyle,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
                widget.onRatingChanged(_rating);
              },
              child: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: widget.color,
                size: widget.size,
              ),
            );
          }),
        ),
        if (widget.showRatingNumber) ...[
          const SizedBox(width: 8),
          Text(
            _rating.toStringAsFixed(1),
            style: widget.ratingTextStyle ?? TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: widget.size * 0.7,
            ),
          ),
        ],
      ],
    );
  }
}

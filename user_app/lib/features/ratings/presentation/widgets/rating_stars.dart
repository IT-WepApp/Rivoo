import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Color borderColor;
  final MainAxisAlignment alignment;
  final bool showRatingNumber;
  final TextStyle? ratingTextStyle;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 20,
    this.color = Colors.amber,
    this.borderColor = Colors.amber,
    this.alignment = MainAxisAlignment.start,
    this.showRatingNumber = false,
    this.ratingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Icons.star, color: color, size: size);
            } else if (index < rating.ceil() &&
                rating.floor() != rating.ceil()) {
              return Icon(Icons.star_half, color: color, size: size);
            } else {
              return Icon(Icons.star_border, color: borderColor, size: size);
            }
          }),
        ),
        if (showRatingNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.8,
                ),
          ),
        ],
      ],
    );
  }
}

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
            style: widget.ratingTextStyle ??
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.size * 0.7,
                ),
          ),
        ],
      ],
    );
  }
}

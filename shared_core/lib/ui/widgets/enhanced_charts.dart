import 'package:flutter/material.dart';

/// مكونات الرسوم البيانية المحسنة للتطبيق
/// توفر رسوم بيانية بتصميم موحد وتجربة مستخدم محسنة
class EnhancedCharts {
  /// رسم بياني خطي محسن
  /// يوفر رسم بياني خطي بتصميم موحد مع تأثيرات تفاعلية
  static Widget lineChart({
    required List<double> data,
    required List<String> labels,
    String? title,
    double height = 300.0,
    Color? lineColor,
    Color? pointColor,
    Color? fillColor,
    Color? gridColor,
    Color? labelColor,
    Color? titleColor,
    bool showGrid = true,
    bool showPoints = true,
    bool showFill = true,
    bool showLabels = true,
    bool animate = true,
    Duration animationDuration = const Duration(milliseconds: 1500),
    double strokeWidth = 3.0,
    double pointRadius = 4.0,
  }) {
    return _EnhancedLineChart(
      data: data,
      labels: labels,
      title: title,
      height: height,
      lineColor: lineColor,
      pointColor: pointColor,
      fillColor: fillColor,
      gridColor: gridColor,
      labelColor: labelColor,
      titleColor: titleColor,
      showGrid: showGrid,
      showPoints: showPoints,
      showFill: showFill,
      showLabels: showLabels,
      animate: animate,
      animationDuration: animationDuration,
      strokeWidth: strokeWidth,
      pointRadius: pointRadius,
    );
  }

  /// رسم بياني دائري محسن
  /// يوفر رسم بياني دائري بتصميم موحد مع تأثيرات تفاعلية
  static Widget pieChart({
    required List<double> data,
    required List<String> labels,
    required List<Color> colors,
    String? title,
    double height = 300.0,
    Color? labelColor,
    Color? titleColor,
    bool showLabels = true,
    bool showPercentages = true,
    bool animate = true,
    Duration animationDuration = const Duration(milliseconds: 1500),
  }) {
    return _EnhancedPieChart(
      data: data,
      labels: labels,
      colors: colors,
      title: title,
      height: height,
      labelColor: labelColor,
      titleColor: titleColor,
      showLabels: showLabels,
      showPercentages: showPercentages,
      animate: animate,
      animationDuration: animationDuration,
    );
  }

  /// رسم بياني عمودي محسن
  /// يوفر رسم بياني عمودي بتصميم موحد مع تأثيرات تفاعلية
  static Widget barChart({
    required List<double> data,
    required List<String> labels,
    String? title,
    double height = 300.0,
    Color? barColor,
    Color? gridColor,
    Color? labelColor,
    Color? titleColor,
    bool showGrid = true,
    bool showLabels = true,
    bool animate = true,
    Duration animationDuration = const Duration(milliseconds: 1500),
    double barWidth = 0.6,
    double cornerRadius = 4.0,
  }) {
    return _EnhancedBarChart(
      data: data,
      labels: labels,
      title: title,
      height: height,
      barColor: barColor,
      gridColor: gridColor,
      labelColor: labelColor,
      titleColor: titleColor,
      showGrid: showGrid,
      showLabels: showLabels,
      animate: animate,
      animationDuration: animationDuration,
      barWidth: barWidth,
      cornerRadius: cornerRadius,
    );
  }
}

/// رسم بياني خطي محسن
class _EnhancedLineChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final String? title;
  final double height;
  final Color? lineColor;
  final Color? pointColor;
  final Color? fillColor;
  final Color? gridColor;
  final Color? labelColor;
  final Color? titleColor;
  final bool showGrid;
  final bool showPoints;
  final bool showFill;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final double strokeWidth;
  final double pointRadius;

  const _EnhancedLineChart({
    required this.data,
    required this.labels,
    this.title,
    required this.height,
    this.lineColor,
    this.pointColor,
    this.fillColor,
    this.gridColor,
    this.labelColor,
    this.titleColor,
    required this.showGrid,
    required this.showPoints,
    required this.showFill,
    required this.showLabels,
    required this.animate,
    required this.animationDuration,
    required this.strokeWidth,
    required this.pointRadius,
  });

  @override
  _EnhancedLineChartState createState() => _EnhancedLineChartState();
}

class _EnhancedLineChartState extends State<_EnhancedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveLineColor = widget.lineColor ?? theme.primaryColor;
    final effectivePointColor = widget.pointColor ?? theme.primaryColor;
    final effectiveFillColor =
        widget.fillColor ?? theme.primaryColor.withOpacity(0.2);
    final effectiveGridColor = widget.gridColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);
    final effectiveLabelColor = widget.labelColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);
    final effectiveTitleColor = widget.titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              color: effectiveTitleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _LineChartPainter(
                  data: widget.data,
                  labels: widget.labels,
                  lineColor: effectiveLineColor,
                  pointColor: effectivePointColor,
                  fillColor: effectiveFillColor,
                  gridColor: effectiveGridColor,
                  labelColor: effectiveLabelColor,
                  showGrid: widget.showGrid,
                  showPoints: widget.showPoints,
                  showFill: widget.showFill,
                  showLabels: widget.showLabels,
                  animationValue: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  pointRadius: widget.pointRadius,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color lineColor;
  final Color pointColor;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;
  final bool showGrid;
  final bool showPoints;
  final bool showFill;
  final bool showLabels;
  final double animationValue;
  final double strokeWidth;
  final double pointRadius;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.lineColor,
    required this.pointColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
    required this.showGrid,
    required this.showPoints,
    required this.showFill,
    required this.showLabels,
    required this.animationValue,
    required this.strokeWidth,
    required this.pointRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 40.0;
    final double graphWidth = size.width - (padding * 2);
    final double graphHeight = size.height - (padding * 2);
    final double graphBottom = size.height - padding;
    const double graphLeft = padding;

    // Find min and max values
    double minValue =
        data.isNotEmpty ? data.reduce((a, b) => a < b ? a : b) : 0;
    double maxValue =
        data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 0;

    // Ensure min value is 0 or less
    minValue = minValue > 0 ? 0 : minValue;

    // Ensure max value is greater than min value
    if (maxValue <= minValue) {
      maxValue = minValue + 1;
    }

    // Add some padding to max value
    maxValue += (maxValue - minValue) * 0.1;

    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.5;

      // Horizontal grid lines
      const horizontalLinesCount = 5;
      for (int i = 0; i <= horizontalLinesCount; i++) {
        final y = graphBottom - (i / horizontalLinesCount) * graphHeight;
        canvas.drawLine(
          Offset(graphLeft, y),
          Offset(size.width - padding, y),
          gridPaint,
        );
      }

      // Vertical grid lines
      final verticalLinesCount = data.length - 1;
      for (int i = 0; i <= verticalLinesCount; i++) {
        final x = graphLeft + (i / verticalLinesCount) * graphWidth;
        canvas.drawLine(
          Offset(x, padding),
          Offset(x, graphBottom),
          gridPaint,
        );
      }
    }

    // Draw labels
    if (showLabels) {
      final labelPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      // X-axis labels
      for (int i = 0; i < labels.length; i++) {
        final x = graphLeft + (i / (labels.length - 1)) * graphWidth;

        labelPaint.text = TextSpan(
          text: labels[i],
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
          ),
        );

        labelPaint.layout();

        labelPaint.paint(
          canvas,
          Offset(x - labelPaint.width / 2, graphBottom + 5),
        );
      }

      // Y-axis labels
      const yLabelCount = 5;
      for (int i = 0; i <= yLabelCount; i++) {
        final y = graphBottom - (i / yLabelCount) * graphHeight;
        final value = minValue + (i / yLabelCount) * (maxValue - minValue);

        labelPaint.text = TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
          ),
        );

        labelPaint.layout();

        labelPaint.paint(
          canvas,
          Offset(padding - labelPaint.width - 5, y - labelPaint.height / 2),
        );
      }
    }

    // Draw line chart
    if (data.length > 1) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();

      for (int i = 0; i < data.length; i++) {
        final animatedIndex = (i * animationValue).floor();
        final animatedProgress = (i * animationValue) - animatedIndex;

        if (i > animatedIndex + 1) {
          break;
        }

        final normalizedValue = (data[i] - minValue) / (maxValue - minValue);
        final x = graphLeft + (i / (data.length - 1)) * graphWidth;
        final y = graphBottom - normalizedValue * graphHeight;

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, graphBottom);
          fillPath.lineTo(x, y);
        } else if (i == animatedIndex + 1) {
          final prevNormalizedValue =
              (data[i - 1] - minValue) / (maxValue - minValue);
          final prevX = graphLeft + ((i - 1) / (data.length - 1)) * graphWidth;
          final prevY = graphBottom - prevNormalizedValue * graphHeight;

          final currentX = prevX + (x - prevX) * animatedProgress;
          final currentY = prevY + (y - prevY) * animatedProgress;

          path.lineTo(currentX, currentY);
          fillPath.lineTo(currentX, currentY);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      // Complete fill path
      if (animationValue > 0) {
        final lastIndex = (data.length * animationValue).floor();
        if (lastIndex < data.length - 1) {
          final animatedProgress = (data.length * animationValue) - lastIndex;

          final normalizedValue =
              (data[lastIndex] - minValue) / (maxValue - minValue);
          final nextNormalizedValue =
              (data[lastIndex + 1] - minValue) / (maxValue - minValue);

          final x = graphLeft + (lastIndex / (data.length - 1)) * graphWidth;
          final nextX =
              graphLeft + ((lastIndex + 1) / (data.length - 1)) * graphWidth;

          final y = graphBottom - normalizedValue * graphHeight;
          final nextY = graphBottom - nextNormalizedValue * graphHeight;

          final currentX = x + (nextX - x) * animatedProgress;

          fillPath.lineTo(currentX, graphBottom);
          fillPath.close();
        } else {
          final lastX =
              graphLeft + ((data.length - 1) / (data.length - 1)) * graphWidth;
          fillPath.lineTo(lastX, graphBottom);
          fillPath.close();
        }
      }

      // Draw fill
      if (showFill) {
        canvas.drawPath(fillPath, fillPaint);
      }

      // Draw line
      canvas.drawPath(path, linePaint);

      // Draw points
      if (showPoints) {
        final pointPaint = Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill;

        for (int i = 0; i < data.length; i++) {
          if (i > (data.length * animationValue).floor()) {
            break;
          }

          final normalizedValue = (data[i] - minValue) / (maxValue - minValue);
          final x = graphLeft + (i / (data.length - 1)) * graphWidth;
          final y = graphBottom - normalizedValue * graphHeight;

          canvas.drawCircle(Offset(x, y), pointRadius, pointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showPoints != showPoints ||
        oldDelegate.showFill != showFill ||
        oldDelegate.showLabels != showLabels;
  }
}

/// رسم بياني دائري محسن
class _EnhancedPieChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final List<Color> colors;
  final String? title;
  final double height;
  final Color? labelColor;
  final Color? titleColor;
  final bool showLabels;
  final bool showPercentages;
  final bool animate;
  final Duration animationDuration;

  const _EnhancedPieChart({
    required this.data,
    required this.labels,
    required this.colors,
    this.title,
    required this.height,
    this.labelColor,
    this.titleColor,
    required this.showLabels,
    required this.showPercentages,
    required this.animate,
    required this.animationDuration,
  });

  @override
  _EnhancedPieChartState createState() => _EnhancedPieChartState();
}

class _EnhancedPieChartState extends State<_EnhancedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveLabelColor = widget.labelColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);
    final effectiveTitleColor = widget.titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    // Calculate total for percentages
    final total = widget.data.fold(0.0, (sum, value) => sum + value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              color: effectiveTitleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: widget.height,
          child: Row(
            children: [
              // Pie chart
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _PieChartPainter(
                        data: widget.data,
                        colors: widget.colors,
                        animationValue: _animation.value,
                      ),
                    );
                  },
                ),
              ),
              // Legend
              if (widget.showLabels) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      widget.data.length,
                      (index) {
                        final percentage = (widget.data[index] / total) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: widget
                                      .colors[index % widget.colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.showPercentages
                                      ? '${widget.labels[index]} (${percentage.toStringAsFixed(1)}%)'
                                      : widget.labels[index],
                                  style: TextStyle(
                                    color: effectiveLabelColor,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final double animationValue;

  _PieChartPainter({
    required this.data,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;

    // Calculate total
    final total = data.fold(0.0, (sum, value) => sum + value);

    // Draw pie slices
    double startAngle = -90 * (3.14159 / 180); // Start from top (in radians)

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * 3.14159 * animationValue;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.8),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationValue != animationValue;
  }
}

/// رسم بياني عمودي محسن
class _EnhancedBarChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final String? title;
  final double height;
  final Color? barColor;
  final Color? gridColor;
  final Color? labelColor;
  final Color? titleColor;
  final bool showGrid;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final double barWidth;
  final double cornerRadius;

  const _EnhancedBarChart({
    required this.data,
    required this.labels,
    this.title,
    required this.height,
    this.barColor,
    this.gridColor,
    this.labelColor,
    this.titleColor,
    required this.showGrid,
    required this.showLabels,
    required this.animate,
    required this.animationDuration,
    required this.barWidth,
    required this.cornerRadius,
  });

  @override
  _EnhancedBarChartState createState() => _EnhancedBarChartState();
}

class _EnhancedBarChartState extends State<_EnhancedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBarColor = widget.barColor ?? theme.primaryColor;
    final effectiveGridColor = widget.gridColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);
    final effectiveLabelColor = widget.labelColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);
    final effectiveTitleColor = widget.titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              color: effectiveTitleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _BarChartPainter(
                  data: widget.data,
                  labels: widget.labels,
                  barColor: effectiveBarColor,
                  gridColor: effectiveGridColor,
                  labelColor: effectiveLabelColor,
                  showGrid: widget.showGrid,
                  showLabels: widget.showLabels,
                  animationValue: _animation.value,
                  barWidth: widget.barWidth,
                  cornerRadius: widget.cornerRadius,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color barColor;
  final Color gridColor;
  final Color labelColor;
  final bool showGrid;
  final bool showLabels;
  final double animationValue;
  final double barWidth;
  final double cornerRadius;

  _BarChartPainter({
    required this.data,
    required this.labels,
    required this.barColor,
    required this.gridColor,
    required this.labelColor,
    required this.showGrid,
    required this.showLabels,
    required this.animationValue,
    required this.barWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 40.0;
    final double graphWidth = size.width - (padding * 2);
    final double graphHeight = size.height - (padding * 2);
    final double graphBottom = size.height - padding;
    const double graphLeft = padding;

    // Find max value
    double maxValue =
        data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 0;

    // Ensure max value is greater than 0
    if (maxValue <= 0) {
      maxValue = 1;
    }

    // Add some padding to max value
    maxValue += maxValue * 0.1;

    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.5;

      // Horizontal grid lines
      const horizontalLinesCount = 5;
      for (int i = 0; i <= horizontalLinesCount; i++) {
        final y = graphBottom - (i / horizontalLinesCount) * graphHeight;
        canvas.drawLine(
          Offset(graphLeft, y),
          Offset(size.width - padding, y),
          gridPaint,
        );
      }
    }

    // Draw labels
    if (showLabels) {
      final labelPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      // X-axis labels
      for (int i = 0; i < labels.length; i++) {
        final barCenterX = graphLeft + ((i + 0.5) / data.length) * graphWidth;

        labelPaint.text = TextSpan(
          text: labels[i],
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
          ),
        );

        labelPaint.layout();

        labelPaint.paint(
          canvas,
          Offset(barCenterX - labelPaint.width / 2, graphBottom + 5),
        );
      }

      // Y-axis labels
      const yLabelCount = 5;
      for (int i = 0; i <= yLabelCount; i++) {
        final y = graphBottom - (i / yLabelCount) * graphHeight;
        final value = (i / yLabelCount) * maxValue;

        labelPaint.text = TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
          ),
        );

        labelPaint.layout();

        labelPaint.paint(
          canvas,
          Offset(padding - labelPaint.width - 5, y - labelPaint.height / 2),
        );
      }
    }

    // Draw bars
    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final normalizedValue = data[i] / maxValue;
      final barHeight = normalizedValue * graphHeight * animationValue;

      final barLeft = graphLeft + (i / data.length) * graphWidth;
      final barRight = barLeft + (graphWidth / data.length) * barWidth;
      final barTop = graphBottom - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
          barLeft + (graphWidth / data.length) * (1 - barWidth) / 2,
          barTop,
          barRight - (graphWidth / data.length) * (1 - barWidth) / 2,
          graphBottom,
        ),
        topLeft: Radius.circular(cornerRadius),
        topRight: Radius.circular(cornerRadius),
      );

      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showLabels != showLabels;
  }
}

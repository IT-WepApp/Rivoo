import 'package:flutter/material.dart';
import 'dart:math';
/// مدير الرسوم المتحركة للتطبيق
/// يوفر رسوم متحركة متناسقة للعناصر المختلفة
class AppAnimations {
  /// رسم متحرك للنبض
  /// يستخدم لجذب انتباه المستخدم إلى عنصر معين
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    bool repeat = true,
  }) {
    return _AnimatedPulse(
      duration: duration,
      repeat: repeat,
      child: child,
    );
  }

  /// رسم متحرك للظهور التدريجي
  /// يستخدم لإظهار العناصر بشكل تدريجي
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeIn,
    bool repeat = false,
  }) {
    return _AnimatedFadeIn(
      duration: duration,
      curve: curve,
      repeat: repeat,
      child: child,
    );
  }

  /// رسم متحرك للانزلاق
  /// يستخدم لإظهار العناصر بحركة انزلاق
  static Widget slideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOut,
    SlideDirection direction = SlideDirection.fromBottom,
    double offset = 100.0,
  }) {
    return _AnimatedSlideIn(
      duration: duration,
      curve: curve,
      direction: direction,
      offset: offset,
      child: child,
    );
  }

  /// رسم متحرك للتكبير
  /// يستخدم لإظهار العناصر بحركة تكبير
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.elasticOut,
  }) {
    return _AnimatedScaleIn(
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// رسم متحرك للاهتزاز
  /// يستخدم لتنبيه المستخدم إلى خطأ أو تحذير
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 10.0,
    int cycles = 3,
  }) {
    return _AnimatedShake(
      duration: duration,
      offset: offset,
      cycles: cycles,
      child: child,
    );
  }

  /// رسم متحرك للتحميل
  /// يستخدم لإظهار حالة التحميل
  static Widget loading({
    double size = 50.0,
    Color color = Colors.blue,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _AnimatedLoading(
      size: size,
      color: color,
      duration: duration,
    );
  }
}

/// اتجاهات الانزلاق المتاحة
enum SlideDirection {
  fromRight,
  fromLeft,
  fromTop,
  fromBottom,
}

/// رسم متحرك للنبض
class _AnimatedPulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;

  const _AnimatedPulse({
    required this.child,
    required this.duration,
    required this.repeat,
  });

  @override
  _AnimatedPulseState createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<_AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// رسم متحرك للظهور التدريجي
class _AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool repeat;

  const _AnimatedFadeIn({
    required this.child,
    required this.duration,
    required this.curve,
    required this.repeat,
  });

  @override
  _AnimatedFadeInState createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<_AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// رسم متحرك للانزلاق
class _AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;
  final double offset;

  const _AnimatedSlideIn({
    required this.child,
    required this.duration,
    required this.curve,
    required this.direction,
    required this.offset,
  });

  @override
  _AnimatedSlideInState createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<_AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Offset begin;
    switch (widget.direction) {
      case SlideDirection.fromRight:
        begin = Offset(widget.offset / 100, 0.0);
        break;
      case SlideDirection.fromLeft:
        begin = Offset(-widget.offset / 100, 0.0);
        break;
      case SlideDirection.fromTop:
        begin = Offset(0.0, -widget.offset / 100);
        break;
      case SlideDirection.fromBottom:
        begin = Offset(0.0, widget.offset / 100);
        break;
    }

    _animation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// رسم متحرك للتكبير
class _AnimatedScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _AnimatedScaleIn({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  _AnimatedScaleInState createState() => _AnimatedScaleInState();
}

class _AnimatedScaleInState extends State<_AnimatedScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// رسم متحرك للاهتزاز
class _AnimatedShake extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final int cycles;

  const _AnimatedShake({
    required this.child,
    required this.duration,
    required this.offset,
    required this.cycles,
  });

  @override
  _AnimatedShakeState createState() => _AnimatedShakeState();
}

class _AnimatedShakeState extends State<_AnimatedShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue = sin(widget.cycles * 2 * 3.14159 * _animation.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.offset, 0.0),
          child: widget.child,
        );
      },
    );
  }
}

/// رسم متحرك للتحميل
class _AnimatedLoading extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const _AnimatedLoading({
    required this.size,
    required this.color,
    required this.duration,
  });

  @override
  _AnimatedLoadingState createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<_AnimatedLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _LoadingPainter(
                animation: _controller,
                color: widget.color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _LoadingPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width / 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final rotatedAngle = angle + animation.value * 2 * 3.14159;
      final opacity = (1.0 - ((i / 8) + animation.value) % 1.0).clamp(0.1, 1.0);

      paint.color = color.withValues(alpha: (opacity * 255).toDouble());
      final x = center.dx + radius * cos(rotatedAngle);
      final y = center.dy + radius * sin(rotatedAngle);

      canvas.drawCircle(
        Offset(x, y),
        size.width / 20,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) {
    return animation != oldDelegate.animation || color != oldDelegate.color;
  }
}

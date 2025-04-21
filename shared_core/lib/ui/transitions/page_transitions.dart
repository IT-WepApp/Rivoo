import 'package:flutter/material.dart';

/// مدير الحركات الانتقالية للتطبيق
/// يوفر حركات انتقالية متناسقة بين الصفحات والعناصر
class AppTransitions {
  /// انتقال تلاشي
  /// يستخدم للانتقال بين الصفحات بشكل سلس
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// انتقال انزلاق
  /// يستخدم للانتقال بين الصفحات بحركة انزلاق من الجانب
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;

        switch (direction) {
          case SlideDirection.fromRight:
            begin = const Offset(1.0, 0.0);
            break;
          case SlideDirection.fromLeft:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.fromTop:
            begin = const Offset(0.0, -1.0);
            break;
          case SlideDirection.fromBottom:
            begin = const Offset(0.0, 1.0);
            break;
        }

        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// انتقال تكبير
  /// يستخدم للانتقال بين الصفحات بحركة تكبير
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Alignment alignment = Alignment.center,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          alignment: alignment,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// انتقال دوران
  /// يستخدم للانتقال بين الصفحات بحركة دوران
  static PageRouteBuilder<T> rotationTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// انتقال مزدوج
  /// يجمع بين حركتي التلاشي والانزلاق
  static PageRouteBuilder<T> fadeSlideTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;

        switch (direction) {
          case SlideDirection.fromRight:
            begin = const Offset(0.2, 0.0);
            break;
          case SlideDirection.fromLeft:
            begin = const Offset(-0.2, 0.0);
            break;
          case SlideDirection.fromTop:
            begin = const Offset(0.0, -0.2);
            break;
          case SlideDirection.fromBottom:
            begin = const Offset(0.0, 0.2);
            break;
        }

        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// انتقال بطاقة
  /// يستخدم للانتقال بين الصفحات بحركة بطاقة
  static PageRouteBuilder<T> cardTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// انتقال مخصص
  /// يسمح بإنشاء انتقال مخصص باستخدام دالة مخصصة
  static PageRouteBuilder<T> customTransition<T>({
    required Widget page,
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) transitionsBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: duration,
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

import 'package:flutter/material.dart';

/// مكونات الإشعارات المحسنة للتطبيق
/// توفر إشعارات بتصميم موحد وتجربة مستخدم محسنة
class EnhancedNotifications {
  /// إشعار سناكبار محسن
  /// يعرض إشعار سناكبار بتصميم موحد مع تأثيرات تفاعلية
  static void showSnackBar(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Color? backgroundColor,
    Color? textColor,
    Color? actionColor,
    IconData? icon,
    Color? iconColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry margin = const EdgeInsets.all(8.0),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 10.0,
    ),
    NotificationType type = NotificationType.info,
  }) {
    final theme = Theme.of(context);

    Color effectiveBackgroundColor;
    Color effectiveIconColor;
    IconData effectiveIcon;

    switch (type) {
      case NotificationType.success:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.green.shade800
                : Colors.green.shade600);
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.check_circle;
        break;
      case NotificationType.error:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.red.shade800
                : Colors.red.shade600);
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.error;
        break;
      case NotificationType.warning:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.amber.shade800
                : Colors.amber.shade600);
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.warning;
        break;
      case NotificationType.info:
      default:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.blue.shade800
                : Colors.blue.shade600);
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.info;
        break;
    }

    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveActionColor = actionColor ?? Colors.white;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              effectiveIcon,
              color: effectiveIconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: effectiveActionColor,
                onPressed: onAction ?? () {},
              )
            : null,
        backgroundColor: effectiveBackgroundColor,
        behavior: behavior,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        margin: behavior == SnackBarBehavior.floating ? margin : null,
        padding: padding,
      ),
    );
  }

  /// إشعار منبثق محسن
  /// يعرض إشعار منبثق بتصميم موحد مع تأثيرات تفاعلية
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? backgroundColor,
    Color? titleColor,
    Color? messageColor,
    Color? confirmColor,
    Color? cancelColor,
    bool barrierDismissible = true,
    NotificationType type = NotificationType.info,
    IconData? icon,
    Color? iconColor,
  }) async {
    final theme = Theme.of(context);

    Color effectiveIconColor;
    IconData effectiveIcon;

    switch (type) {
      case NotificationType.success:
        effectiveIconColor = iconColor ??
            (theme.brightness == Brightness.dark
                ? Colors.green.shade400
                : Colors.green);
        effectiveIcon = icon ?? Icons.check_circle;
        break;
      case NotificationType.error:
        effectiveIconColor = iconColor ??
            (theme.brightness == Brightness.dark
                ? Colors.red.shade400
                : Colors.red);
        effectiveIcon = icon ?? Icons.error;
        break;
      case NotificationType.warning:
        effectiveIconColor = iconColor ??
            (theme.brightness == Brightness.dark
                ? Colors.amber.shade400
                : Colors.amber);
        effectiveIcon = icon ?? Icons.warning;
        break;
      case NotificationType.info:
      default:
        effectiveIconColor = iconColor ??
            (theme.brightness == Brightness.dark
                ? Colors.blue.shade400
                : Colors.blue);
        effectiveIcon = icon ?? Icons.info;
        break;
    }

    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    final effectiveTitleColor = titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveMessageColor = messageColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    final effectiveConfirmColor = confirmColor ?? theme.primaryColor;
    final effectiveCancelColor = cancelColor ?? Colors.grey;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AlertDialog(
          backgroundColor: effectiveBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                effectiveIcon,
                color: effectiveIconColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: effectiveTitleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: effectiveMessageColor,
              fontSize: 16,
            ),
          ),
          actions: [
            if (cancelLabel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onCancel != null) {
                    onCancel();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: effectiveCancelColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (confirmLabel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onConfirm != null) {
                    onConfirm();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: effectiveConfirmColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  confirmLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.2);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// إشعار منبثق من الأسفل محسن
  /// يعرض إشعار منبثق من الأسفل بتصميم موحد مع تأثيرات تفاعلية
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    double borderRadius = 16.0,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    BoxConstraints? constraints,
  }) async {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      constraints: constraints,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }

  /// إشعار توست محسن
  /// يعرض إشعار توست بتصميم موحد مع تأثيرات تفاعلية
  static void showToast({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    NotificationType type = NotificationType.info,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    double borderRadius = 24.0,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(
      horizontal: 32.0,
      vertical: 64.0,
    ),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 10.0,
    ),
    Alignment alignment = Alignment.bottomCenter,
  }) {
    final theme = Theme.of(context);

    Color effectiveBackgroundColor;
    Color effectiveIconColor;
    IconData effectiveIcon;

    switch (type) {
      case NotificationType.success:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.green.shade800.withOpacity(0.9)
                : Colors.green.shade600.withOpacity(0.9));
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.check_circle;
        break;
      case NotificationType.error:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.red.shade800.withOpacity(0.9)
                : Colors.red.shade600.withOpacity(0.9));
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.error;
        break;
      case NotificationType.warning:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.amber.shade800.withOpacity(0.9)
                : Colors.amber.shade600.withOpacity(0.9));
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.warning;
        break;
      case NotificationType.info:
      default:
        effectiveBackgroundColor = backgroundColor ??
            (theme.brightness == Brightness.dark
                ? Colors.blue.shade800.withOpacity(0.9)
                : Colors.blue.shade600.withOpacity(0.9));
        effectiveIconColor = iconColor ?? Colors.white;
        effectiveIcon = icon ?? Icons.info;
        break;
    }

    final effectiveTextColor = textColor ?? Colors.white;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: margin.horizontal / 2,
          right: margin.horizontal / 2,
          bottom:
              alignment == Alignment.bottomCenter ? margin.vertical / 2 : null,
          top: alignment == Alignment.topCenter ? margin.vertical / 2 : null,
          child: _ToastWidget(
            message: message,
            backgroundColor: effectiveBackgroundColor,
            textColor: effectiveTextColor,
            icon: effectiveIcon,
            iconColor: effectiveIconColor,
            borderRadius: borderRadius,
            padding: padding,
            onDismiss: () {
              overlayEntry.remove();
            },
            duration: duration,
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}

/// أنواع الإشعارات المتاحة
enum NotificationType {
  info,
  success,
  warning,
  error,
}

/// ويدجت توست محسن
class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.borderRadius,
    required this.padding,
    required this.onDismiss,
    required this.duration,
  });

  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: widget.padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

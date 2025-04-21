import 'package:flutter/material.dart';

/// أزرار محسنة للتطبيق
/// توفر أزرار بتصميم موحد وتجربة مستخدم محسنة
class EnhancedButtons {
  /// زر أساسي محسن
  /// يوفر زر بتصميم موحد مع تأثيرات تفاعلية
  static Widget primary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    double elevation = 2.0,
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: isDisabled ? null : onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor ?? Colors.blue,
      textColor: textColor ?? Colors.white,
      borderRadius: borderRadius,
      padding: padding,
      elevation: elevation,
      type: _ButtonType.primary,
    );
  }

  /// زر ثانوي محسن
  /// يوفر زر بتصميم ثانوي مع تأثيرات تفاعلية
  static Widget secondary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    double elevation = 1.0,
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: isDisabled ? null : onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      textColor: textColor ?? Colors.black87,
      borderRadius: borderRadius,
      padding: padding,
      elevation: elevation,
      type: _ButtonType.secondary,
    );
  }

  /// زر مسطح محسن
  /// يوفر زر بدون خلفية مع تأثيرات تفاعلية
  static Widget flat({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    Color? textColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: isDisabled ? null : onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? Colors.blue,
      borderRadius: borderRadius,
      padding: padding,
      elevation: 0.0,
      type: _ButtonType.flat,
    );
  }

  /// زر مخطط محسن
  /// يوفر زر بحدود مع تأثيرات تفاعلية
  static Widget outlined({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    Color? borderColor,
    Color? textColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: isDisabled ? null : onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? Colors.blue,
      borderColor: borderColor ?? Colors.blue,
      borderRadius: borderRadius,
      padding: padding,
      elevation: 0.0,
      type: _ButtonType.outlined,
    );
  }

  /// زر أيقونة محسن
  /// يوفر زر أيقونة دائري مع تأثيرات تفاعلية
  static Widget icon({
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Color? backgroundColor,
    Color? iconColor,
    double size = 48.0,
    double iconSize = 24.0,
    double elevation = 2.0,
  }) {
    return _EnhancedIconButton(
      icon: icon,
      onPressed: isDisabled ? null : onPressed,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? Colors.blue,
      iconColor: iconColor ?? Colors.white,
      size: size,
      iconSize: iconSize,
      elevation: elevation,
    );
  }
}

/// أنواع الأزرار المتاحة
enum _ButtonType {
  primary,
  secondary,
  flat,
  outlined,
}

/// زر محسن
class _EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final _ButtonType type;

  const _EnhancedButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.padding,
    required this.elevation,
    required this.type,
    this.icon,
    this.borderColor,
  });

  @override
  _EnhancedButtonState createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<_EnhancedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final effectiveBackgroundColor = isDisabled
        ? widget.backgroundColor.withValues(alpha: 153) // 0.6 * 255 = 153
        : _isPressed
            ? widget.backgroundColor.withValues(alpha: 204) // 0.8 * 255 = 204
            : _isHovered
                ? widget.backgroundColor.withValues(alpha: 230) // 0.9 * 255 = 230
                : widget.backgroundColor;

    final effectiveTextColor =
        isDisabled ? widget.textColor.withValues(alpha: 153) : widget.textColor; // 0.6 * 255 = 153

    final effectiveBorderColor = widget.borderColor != null
        ? isDisabled
            ? widget.borderColor!.withValues(alpha: 153) // 0.6 * 255 = 153
            : widget.borderColor
        : null;

    final effectiveElevation = isDisabled
        ? 0.0
        : _isPressed
            ? widget.elevation * 0.5
            : _isHovered
                ? widget.elevation * 1.2
                : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: widget.type == _ButtonType.outlined
                  ? Colors.transparent
                  : effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.type == _ButtonType.outlined
                  ? Border.all(
                      color: effectiveBorderColor ?? Colors.transparent,
                      width: 1.5,
                    )
                  : null,
              boxShadow: widget.elevation > 0 && !isDisabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 51), // 0.2 * 255 = 51
                        blurRadius: effectiveElevation * 2,
                        offset: Offset(0, effectiveElevation),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: widget.textColor.withValues(alpha: 26), // 0.1 * 255 = 26
                highlightColor: widget.textColor.withValues(alpha: 13), // 0.05 * 255 = 13
                child: Padding(
                  padding: widget.padding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              effectiveTextColor,
                            ),
                          ),
                        )
                      else if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: effectiveTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (!widget.isLoading)
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: effectiveTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر أيقونة محسن
class _EnhancedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double elevation;

  const _EnhancedIconButton({
    required this.icon,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
    required this.iconSize,
    required this.elevation,
  });

  @override
  _EnhancedIconButtonState createState() => _EnhancedIconButtonState();
}

class _EnhancedIconButtonState extends State<_EnhancedIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final effectiveBackgroundColor = isDisabled
        ? widget.backgroundColor.withValues(alpha: 153) // 0.6 * 255 = 153
        : _isPressed
            ? widget.backgroundColor.withValues(alpha: 204) // 0.8 * 255 = 204
            : _isHovered
                ? widget.backgroundColor.withValues(alpha: 230) // 0.9 * 255 = 230
                : widget.backgroundColor;

    final effectiveIconColor =
        isDisabled ? widget.iconColor.withValues(alpha: 153) : widget.iconColor; // 0.6 * 255 = 153

    final effectiveElevation = isDisabled
        ? 0.0
        : _isPressed
            ? widget.elevation * 0.5
            : _isHovered
                ? widget.elevation * 1.2
                : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: widget.elevation > 0 && !isDisabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 51), // 0.2 * 255 = 51
                        blurRadius: effectiveElevation * 2,
                        offset: Offset(0, effectiveElevation),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(widget.size / 2),
                splashColor: widget.iconColor.withValues(alpha: 26), // 0.1 * 255 = 26
                highlightColor: widget.iconColor.withValues(alpha: 13), // 0.05 * 255 = 13
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: widget.iconSize,
                          height: widget.iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              effectiveIconColor,
                            ),
                          ),
                        )
                      : Icon(
                          widget.icon,
                          color: effectiveIconColor,
                          size: widget.iconSize,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

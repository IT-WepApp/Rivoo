import 'package:flutter/material.dart';

/// بطاقات محسنة للتطبيق
/// توفر بطاقات بتصميم موحد وتجربة مستخدم محسنة
class EnhancedCards {
  /// بطاقة أساسية محسنة
  /// توفر بطاقة بتصميم موحد مع تأثيرات تفاعلية
  static Widget basic({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    double borderRadius = 12.0,
    Color? backgroundColor,
    Color? shadowColor,
    double elevation = 2.0,
    VoidCallback? onTap,
    BorderSide? border,
  }) {
    return _EnhancedCard(
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      elevation: elevation,
      onTap: onTap,
      border: border,
      child: child,
    );
  }

  /// بطاقة معلومات محسنة
  /// توفر بطاقة معلومات بتصميم موحد مع عنوان ومحتوى
  static Widget info({
    required String title,
    required Widget content,
    Widget? leading,
    Widget? trailing,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    double borderRadius = 12.0,
    Color? backgroundColor,
    Color? shadowColor,
    Color? titleColor,
    double elevation = 2.0,
    VoidCallback? onTap,
    BorderSide? border,
  }) {
    return _EnhancedInfoCard(
      title: title,
      content: content,
      leading: leading,
      trailing: trailing,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      titleColor: titleColor,
      elevation: elevation,
      onTap: onTap,
      border: border,
    );
  }

  /// بطاقة عمل محسنة
  /// توفر بطاقة عمل بتصميم موحد مع عنوان ومحتوى وأزرار
  static Widget action({
    required String title,
    required Widget content,
    required List<Widget> actions,
    Widget? leading,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    double borderRadius = 12.0,
    Color? backgroundColor,
    Color? shadowColor,
    Color? titleColor,
    double elevation = 2.0,
    VoidCallback? onTap,
    BorderSide? border,
  }) {
    return _EnhancedActionCard(
      title: title,
      content: content,
      actions: actions,
      leading: leading,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      titleColor: titleColor,
      elevation: elevation,
      onTap: onTap,
      border: border,
    );
  }

  /// بطاقة صورة محسنة
  /// توفر بطاقة صورة بتصميم موحد مع صورة وعنوان ومحتوى
  static Widget image({
    required ImageProvider image,
    required String title,
    Widget? content,
    double imageHeight = 180.0,
    BoxFit imageFit = BoxFit.cover,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    double borderRadius = 12.0,
    Color? backgroundColor,
    Color? shadowColor,
    Color? titleColor,
    double elevation = 2.0,
    VoidCallback? onTap,
    BorderSide? border,
  }) {
    return _EnhancedImageCard(
      image: image,
      title: title,
      content: content,
      imageHeight: imageHeight,
      imageFit: imageFit,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      titleColor: titleColor,
      elevation: elevation,
      onTap: onTap,
      border: border,
    );
  }
}

/// بطاقة محسنة
class _EnhancedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double elevation;
  final VoidCallback? onTap;
  final BorderSide? border;

  const _EnhancedCard({
    required this.child,
    required this.padding,
    required this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    required this.elevation,
    this.onTap,
    this.border,
  });

  @override
  _EnhancedCardState createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<_EnhancedCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = widget.backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    final effectiveShadowColor = widget.shadowColor ??
        (theme.brightness == Brightness.dark ? Colors.black54 : Colors.black26);

    final effectiveElevation = _isPressed
        ? widget.elevation * 0.5
        : _isHovered
            ? widget.elevation * 1.5
            : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null
                ? Border.all(
                    color: widget.border!.color,
                    width: widget.border!.width,
                    style: widget.border!.style,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: effectiveShadowColor.withOpacity(
                  _isHovered ? 0.3 : 0.2,
                ),
                blurRadius: effectiveElevation * 2,
                spreadRadius: effectiveElevation * 0.5,
                offset: Offset(0, effectiveElevation),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة معلومات محسنة
class _EnhancedInfoCard extends StatefulWidget {
  final String title;
  final Widget content;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? titleColor;
  final double elevation;
  final VoidCallback? onTap;
  final BorderSide? border;

  const _EnhancedInfoCard({
    required this.title,
    required this.content,
    this.leading,
    this.trailing,
    required this.padding,
    required this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    this.titleColor,
    required this.elevation,
    this.onTap,
    this.border,
  });

  @override
  _EnhancedInfoCardState createState() => _EnhancedInfoCardState();
}

class _EnhancedInfoCardState extends State<_EnhancedInfoCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = widget.backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    final effectiveShadowColor = widget.shadowColor ??
        (theme.brightness == Brightness.dark ? Colors.black54 : Colors.black26);

    final effectiveTitleColor = widget.titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveElevation = _isPressed
        ? widget.elevation * 0.5
        : _isHovered
            ? widget.elevation * 1.5
            : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null
                ? Border.all(
                    color: widget.border!.color,
                    width: widget.border!.width,
                    style: widget.border!.style,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: effectiveShadowColor.withOpacity(
                  _isHovered ? 0.3 : 0.2,
                ),
                blurRadius: effectiveElevation * 2,
                spreadRadius: effectiveElevation * 0.5,
                offset: Offset(0, effectiveElevation),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: widget.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: effectiveTitleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    ),
                    const SizedBox(height: 12),
                    widget.content,
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

/// بطاقة عمل محسنة
class _EnhancedActionCard extends StatefulWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? titleColor;
  final double elevation;
  final VoidCallback? onTap;
  final BorderSide? border;

  const _EnhancedActionCard({
    required this.title,
    required this.content,
    required this.actions,
    this.leading,
    required this.padding,
    required this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    this.titleColor,
    required this.elevation,
    this.onTap,
    this.border,
  });

  @override
  _EnhancedActionCardState createState() => _EnhancedActionCardState();
}

class _EnhancedActionCardState extends State<_EnhancedActionCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = widget.backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    final effectiveShadowColor = widget.shadowColor ??
        (theme.brightness == Brightness.dark ? Colors.black54 : Colors.black26);

    final effectiveTitleColor = widget.titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveElevation = _isPressed
        ? widget.elevation * 0.5
        : _isHovered
            ? widget.elevation * 1.5
            : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null
                ? Border.all(
                    color: widget.border!.color,
                    width: widget.border!.width,
                    style: widget.border!.style,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: effectiveShadowColor.withOpacity(
                  _isHovered ? 0.3 : 0.2,
                ),
                blurRadius: effectiveElevation * 2,
                spreadRadius: effectiveElevation * 0.5,
                offset: Offset(0, effectiveElevation),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: widget.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: effectiveTitleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    widget.content,
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.actions
                          .map((action) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: action,
                              ))
                          .toList(),
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

/// بطاقة صورة محسنة
class _EnhancedImageCard extends StatefulWidget {
  final ImageProvider image;
  final String title;
  final Widget? content;
  final double imageHeight;
  final BoxFit imageFit;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? titleColor;
  final double elevation;
  final VoidCallback? onTap;
  final BorderSide? border;

  const _EnhancedImageCard({
    required this.image,
    required this.title,
    this.content,
    required this.imageHeight,
    required this.imageFit,
    required this.padding,
    required this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    this.titleColor,
    required this.elevation,
    this.onTap,
    this.border,
  });

  @override
  _EnhancedImageCardState createState() => _EnhancedImageCardState();
}

class _EnhancedImageCardState extends State<_EnhancedImageCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = widget.backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    final effectiveShadowColor = widget.shadowColor ??
        (theme.brightness == Brightness.dark ? Colors.black54 : Colors.black26);

    final effectiveTitleColor = widget.titleColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveElevation = _isPressed
        ? widget.elevation * 0.5
        : _isHovered
            ? widget.elevation * 1.5
            : widget.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null
                ? Border.all(
                    color: widget.border!.color,
                    width: widget.border!.width,
                    style: widget.border!.style,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: effectiveShadowColor.withOpacity(
                  _isHovered ? 0.3 : 0.2,
                ),
                blurRadius: effectiveElevation * 2,
                spreadRadius: effectiveElevation * 0.5,
                offset: Offset(0, effectiveElevation),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: widget.image,
                    height: widget.imageHeight,
                    width: double.infinity,
                    fit: widget.imageFit,
                  ),
                  Padding(
                    padding: widget.padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: effectiveTitleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.content != null) ...[
                          const SizedBox(height: 8),
                          widget.content!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

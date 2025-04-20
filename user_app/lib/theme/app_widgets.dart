import 'package:flutter/material.dart';

/// مكونات واجهة المستخدم المشتركة
/// 
/// يحتوي هذا الملف على مكونات واجهة المستخدم المشتركة المستخدمة في جميع أنحاء التطبيق
/// مثل الأزرار وحقول الإدخال والبطاقات وغيرها

/// زر التطبيق الموحد
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double height;
  final double borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.height = 48.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    return SizedBox(
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(context, buttonColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(context, Colors.white),
            ),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? Theme.of(context).colorScheme.primary : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isOutlined ? textColor : Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isOutlined ? textColor : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: isOutlined ? textColor : Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// حقل إدخال النص الموحد
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceVariant,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}

/// بطاقة العنصر الموحدة
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? color;
  final Color? shadowColor;
  final double elevation;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 12.0,
    this.color,
    this.shadowColor,
    this.elevation = 2.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.surface;
    
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: cardColor,
      shadowColor: shadowColor,
      elevation: elevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// شريط التنقل السفلي الموحد
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
      unselectedItemColor: unselectedItemColor ?? theme.colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8.0,
    );
  }
}

/// شريط البحث الموحد
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) {
                      onClear!();
                    }
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}

/// شارة العدد الموحدة
class AppBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? color;
  final double size;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    Key? key,
    required this.child,
    required this.count,
    this.color,
    this.size = 18.0,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.error;
    
    if (count <= 0) {
      return child;
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(
              minWidth: size,
              minHeight: size,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// مؤشر التحميل الموحد
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const AppLoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// رسالة الخطأ الموحدة
class AppErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;

  const AppErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ],
    );
  }
}

/// قائمة فارغة موحدة
class AppEmptyList extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyList({
    Key? key,
    required this.message,
    this.icon = Icons.hourglass_empty,
    this.iconSize = 64.0,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}

/// شريط التقدم الموحد
class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;
  final String? label;

  const AppProgressBar({
    Key? key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
    this.borderRadius = 4.0,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceVariant;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: bgColor,
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

/// شريط التبويب الموحد
class AppTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final Function(int)? onTap;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;

  const AppTabBar({
    Key? key,
    required this.controller,
    required this.tabs,
    this.onTap,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TabBar(
      controller: controller,
      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      onTap: onTap,
      indicatorColor: indicatorColor ?? theme.colorScheme.primary,
      labelColor: labelColor ?? theme.colorScheme.primary,
      unselectedLabelColor: unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
      indicatorWeight: 3.0,
      labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: theme.textTheme.titleSmall,
    );
  }
}

/// مربع الاختيار الموحد
class AppCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String label;
  final Color? activeColor;
  final bool enabled;

  const AppCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: activeColor ?? theme.colorScheme.primary,
            ),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر الراديو الموحد
class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Function(T?) onChanged;
  final String label;
  final Color? activeColor;
  final bool enabled;

  const AppRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.activeColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled ? () => onChanged(value) : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: enabled ? onChanged : null,
              activeColor: activeColor ?? theme.colorScheme.primary,
            ),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// مربع الحوار الموحد
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final bool dismissible;
  final double borderRadius;

  const AppDialog({
    Key? key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.dismissible = true,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(title),
      content: message != null
          ? Text(message!)
          : content,
      actions: actions,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
  
  /// عرض مربع الحوار
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    bool dismissible = true,
    double borderRadius = 16.0,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        dismissible: dismissible,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// مربع حوار التأكيد الموحد
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool dismissible;

  const AppConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.dismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) {
              onCancel!();
            }
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          child: Text(confirmText),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
  
  /// عرض مربع حوار التأكيد
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool dismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          Navigator.of(context).pop(true);
          if (onConfirm != null) {
            onConfirm();
          }
        },
        onCancel: () {
          Navigator.of(context).pop(false);
          if (onCancel != null) {
            onCancel();
          }
        },
        isDestructive: isDestructive,
        dismissible: dismissible,
      ),
    );
    
    return result ?? false;
  }
}

/// شريط التطبيق الموحد
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.0,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// شريط التمرير الموحد
class AppScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool thumbVisibility;
  final bool trackVisibility;
  final double thickness;
  final Radius radius;

  const AppScrollbar({
    Key? key,
    required this.child,
    this.controller,
    this.thumbVisibility = false,
    this.trackVisibility = false,
    this.thickness = 8.0,
    this.radius = const Radius.circular(4.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      thickness: thickness,
      radius: radius,
      child: child,
    );
  }
}

/// مؤشر التقييم الموحد
class AppRatingBar extends StatelessWidget {
  final double rating;
  final double maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(double)? onRatingChanged;
  final bool readOnly;

  const AppRatingBar({
    Key? key,
    required this.rating,
    this.maxRating = 5.0,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.readOnly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? theme.colorScheme.surfaceVariant;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating.toInt(), (index) {
        final isActive = index < rating;
        final isHalf = index == rating.floor() && rating % 1 != 0;
        
        return GestureDetector(
          onTap: readOnly
              ? null
              : () => onRatingChanged?.call(index + 1.0),
          child: Icon(
            isHalf
                ? Icons.star_half
                : (isActive ? Icons.star : Icons.star_border),
            color: isActive || isHalf ? activeStarColor : inactiveStarColor,
            size: size,
          ),
        );
      }),
    );
  }
}

/// شارة الحالة الموحدة
class AppStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppStatusBadge({
    Key? key,
    required this.text,
    required this.color,
    this.textColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: textColor ?? Colors.white,
      fontWeight: FontWeight.bold,
    );
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}

/// زر الأيقونة الموحد
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;
  final bool enabled;

  const AppIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24.0,
    this.tooltip,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;
    
    return IconButton(
      icon: Icon(
        icon,
        color: enabled ? iconColor : theme.colorScheme.onSurface.withOpacity(0.38),
        size: size,
      ),
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
    );
  }
}

/// زر النص الموحد
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool enabled;

  const AppTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.icon,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    if (icon != null) {
      return TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(text),
        style: TextButton.styleFrom(
          foregroundColor: buttonColor,
        ),
      );
    }
    
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
      ),
      child: Text(text),
    );
  }
}

/// مؤشر الكمية الموحد
class AppQuantitySelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  final int minValue;
  final int maxValue;
  final double height;
  final double width;
  final Color? color;

  const AppQuantitySelector({
    Key? key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
    this.height = 36.0,
    this.width = 120.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر النقصان
          InkWell(
            onTap: value > minValue
                ? () => onChanged(value - 1)
                : null,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
            child: Container(
              width: height,
              height: height,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                size: 16,
                color: value > minValue
                    ? buttonColor
                    : theme.colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ),
          
          // القيمة الحالية
          Text(
            value.toString(),
            style: theme.textTheme.titleMedium,
          ),
          
          // زر الزيادة
          InkWell(
            onTap: value < maxValue
                ? () => onChanged(value + 1)
                : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
            ),
            child: Container(
              width: height,
              height: height,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 16,
                color: value < maxValue
                    ? buttonColor
                    : theme.colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر الخطوات الموحد
class AppStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int)? onStepTapped;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppStepper({
    Key? key,
    required this.currentStep,
    required this.steps,
    this.onStepTapped,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive = inactiveColor ?? theme.colorScheme.surfaceVariant;
    
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        // إذا كان الفهرس زوجياً، فهو خطوة
        if (index % 2 == 0) {
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentStep;
          
          return Expanded(
            child: GestureDetector(
              onTap: onStepTapped != null
                  ? () => onStepTapped!(stepIndex)
                  : null,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? active : inactive,
                    ),
                    child: Center(
                      child: Text(
                        (stepIndex + 1).toString(),
                        style: TextStyle(
                          color: isActive
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[stepIndex],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          // إذا كان الفهرس فردياً، فهو خط رابط
          final prevStepIndex = index ~/ 2;
          final isActive = prevStepIndex < currentStep;
          
          return Expanded(
            child: Container(
              height: 2,
              color: isActive ? active : inactive,
            ),
          );
        }
      }),
    );
  }
}

/// مؤشر التقدم الدائري الموحد
class AppCircularProgressIndicator extends StatelessWidget {
  final double value;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final String? label;
  final TextStyle? labelStyle;

  const AppCircularProgressIndicator({
    Key? key,
    required this.value,
    this.size = 80.0,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 8.0,
    this.label,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceVariant;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: bgColor,
            strokeWidth: strokeWidth,
          ),
          if (label != null)
            Text(
              label!,
              style: labelStyle ?? theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// مؤشر التبديل الموحد
class AppSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final String? label;
  final Color? activeColor;
  final bool enabled;

  const AppSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (label == null) {
      return Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: activeColor ?? theme.colorScheme.primary,
      );
    }
    
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: activeColor ?? theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// مؤشر التمرير الموحد
class AppSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enabled;

  const AppSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Slider(
      value: value,
      onChanged: enabled ? onChanged : null,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor ?? theme.colorScheme.primary,
      inactiveColor: inactiveColor ?? theme.colorScheme.surfaceVariant,
    );
  }
}

/// مؤشر التاريخ الموحد
class AppDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final IconData icon;

  const AppDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.label,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.icon = Icons.calendar_today,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled
          ? () => _selectDate(context)
          : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? theme.colorScheme.outline
                : theme.colorScheme.outline.withOpacity(0.38),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(selectedDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// مؤشر الوقت الموحد
class AppTimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeChanged;
  final String label;
  final bool enabled;
  final IconData icon;

  const AppTimePicker({
    Key? key,
    required this.selectedTime,
    required this.onTimeChanged,
    required this.label,
    this.enabled = true,
    this.icon = Icons.access_time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled
          ? () => _selectTime(context)
          : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? theme.colorScheme.outline
                : theme.colorScheme.outline.withOpacity(0.38),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(selectedTime),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    
    if (picked != null && picked != selectedTime) {
      onTimeChanged(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// مؤشر التحميل المتموج الموحد
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const AppShimmer({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = baseColor ?? theme.colorScheme.surfaceVariant;
    final highlight = highlightColor ?? theme.colorScheme.surface;
    
    return ShimmerEffect(
      baseColor: base,
      highlightColor: highlight,
      duration: duration,
      child: child,
    );
  }
}

/// تأثير التحميل المتموج
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 3.0 - 1.0),
      0.0,
      0.0,
    );
  }
}

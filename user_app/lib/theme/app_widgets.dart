import 'package:flutter/material.dart';

/// مكونات واجهة المستخدم المشتركة للتطبيق
class AppWidgets {
  /// حقل نص مخصص للتطبيق
  static Widget AppTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int maxLines = 1,
    int? maxLength,
    void Function(String)? onChanged,
    void Function()? onTap,
    FocusNode? focusNode,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    EdgeInsetsGeometry? contentPadding,
    bool autofocus = false,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: contentPadding ?? const EdgeInsets.all(16),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        onTap: onTap,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        autofocus: autofocus,
        readOnly: readOnly,
      ),
    );
  }

  /// زر مخصص للتطبيق
  static Widget AppButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isOutlined = false,
    Color? backgroundColor,
    Color? textColor,
    double width = double.infinity,
    double height = 50,
    double borderRadius = 12,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    bool disabled = false,
  }) {
    final buttonStyle = isOutlined
        ? ElevatedButton.styleFrom(
            foregroundColor: textColor ?? Colors.blue,
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                  color: disabled ? Colors.grey : (textColor ?? Colors.blue)),
            ),
            minimumSize: Size(width, height),
          )
        : ElevatedButton.styleFrom(
            foregroundColor: textColor ?? Colors.white,
            backgroundColor:
                disabled ? Colors.grey : (backgroundColor ?? Colors.blue),
            elevation: 2,
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: Size(width, height),
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: disabled ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );
  }

  /// بطاقة مخصصة للتطبيق
  static Widget AppCard({
    required Widget child,
    double elevation = 2,
    Color? color,
    double borderRadius = 12,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: 8),
    void Function()? onTap,
  }) {
    return Card(
      elevation: elevation,
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: margin,
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

  /// شريط تنقل سفلي مخصص للتطبيق
  static Widget AppBottomNavigationBar({
    required int currentIndex,
    required void Function(int) onTap,
    required List<BottomNavigationBarItem> items,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor ?? Colors.white,
      selectedItemColor: selectedItemColor ?? Colors.blue,
      unselectedItemColor: unselectedItemColor ?? Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  /// شريط تطبيق مخصص للتطبيق
  static PreferredSizeWidget AppAppBar({
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
    Widget? leading,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: centerTitle,
      leading: leading,
      bottom: bottom,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  /// مؤشر تحميل مخصص للتطبيق
  static Widget AppLoadingIndicator({
    double size = 40,
    Color? color,
    double strokeWidth = 4,
  }) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? Colors.blue,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }

  /// رسالة خطأ مخصصة للتطبيق
  static Widget AppErrorMessage({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
    Color? iconColor,
    double iconSize = 48,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.red,
            size: iconSize,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }

  /// قائمة فارغة مخصصة للتطبيق
  static Widget AppEmptyList({
    required String message,
    IconData icon = Icons.hourglass_empty,
    Color? iconColor,
    double iconSize = 48,
    VoidCallback? onRefresh,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.grey,
            size: iconSize,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('تحديث'),
            ),
          ],
        ],
      ),
    );
  }

  /// شريط بحث مخصص للتطبيق
  static Widget AppSearchBar({
    required TextEditingController controller,
    required void Function(String) onChanged,
    String hintText = 'بحث...',
    void Function()? onClear,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) {
                      onClear();
                    } else {
                      onChanged('');
                    }
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// شريط تبويب مخصص للتطبيق
  static Widget AppTabBar({
    required TabController controller,
    required List<String> tabs,
    Color? indicatorColor,
    Color? labelColor,
    Color? unselectedLabelColor,
    double indicatorWeight = 3,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        indicatorColor: indicatorColor ?? Colors.blue,
        labelColor: labelColor ?? Colors.blue,
        unselectedLabelColor: unselectedLabelColor ?? Colors.grey,
        indicatorWeight: indicatorWeight,
      ),
    );
  }

  /// شارة مخصصة للتطبيق
  static Widget AppBadge({
    required Widget child,
    required int count,
    Color? backgroundColor,
    Color? textColor,
    double size = 20,
    EdgeInsetsGeometry? padding,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: padding ?? const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.red,
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
                    color: textColor ?? Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// شريط تقدم مخصص للتطبيق
  static Widget AppProgressBar({
    required double value,
    double height = 8,
    Color? backgroundColor,
    Color? progressColor,
    double borderRadius = 4,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? Colors.blue),
      ),
    );
  }
}

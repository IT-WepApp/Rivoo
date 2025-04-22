import 'package:flutter/material.dart';

/// زر التطبيق المخصص
/// يوفر زر موحد بتصميم متناسق مع هوية التطبيق
class AppButton extends StatelessWidget {
  /// نص الزر
  final String text;
  
  /// دالة يتم تنفيذها عند النقر على الزر
  final VoidCallback? onPressed;
  
  /// لون الزر الأساسي
  final Color? color;
  
  /// لون النص
  final Color? textColor;
  
  /// حجم النص
  final double? fontSize;
  
  /// عرض الزر (null للعرض التلقائي)
  final double? width;
  
  /// ارتفاع الزر
  final double height;
  
  /// نصف قطر حواف الزر
  final double borderRadius;
  
  /// سماكة الحدود
  final double borderWidth;
  
  /// لون حدود الزر
  final Color? borderColor;
  
  /// أيقونة الزر (اختياري)
  final IconData? icon;
  
  /// موضع الأيقونة (قبل أو بعد النص)
  final bool iconAfterText;
  
  /// المسافة بين الأيقونة والنص
  final double iconSpacing;
  
  /// ما إذا كان الزر معطلاً
  final bool isDisabled;
  
  /// لون الزر عندما يكون معطلاً
  final Color disabledColor;
  
  /// لون النص عندما يكون الزر معطلاً
  final Color disabledTextColor;
  
  /// ما إذا كان الزر يعرض مؤشر تحميل
  final bool isLoading;
  
  /// لون مؤشر التحميل
  final Color? loadingColor;
  
  /// حجم مؤشر التحميل
  final double loadingSize;
  
  /// نوع الزر (أساسي، ثانوي، نص فقط)
  final AppButtonType type;

  /// منشئ الزر
  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.fontSize,
    this.width,
    this.height = 50,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.borderColor,
    this.icon,
    this.iconAfterText = false,
    this.iconSpacing = 8,
    this.isDisabled = false,
    this.disabledColor = const Color(0xFFE0E0E0),
    this.disabledTextColor = const Color(0xFF9E9E9E),
    this.isLoading = false,
    this.loadingColor,
    this.loadingSize = 24,
    this.type = AppButtonType.primary,
  }) : super(key: key);

  /// زر أساسي
  factory AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Color? color,
    Color? textColor,
    double? fontSize,
    double? width,
    double height = 50,
    double borderRadius = 8,
    IconData? icon,
    bool iconAfterText = false,
    double iconSpacing = 8,
    bool isDisabled = false,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      color: color,
      textColor: textColor ?? Colors.white,
      fontSize: fontSize,
      width: width,
      height: height,
      borderRadius: borderRadius,
      icon: icon,
      iconAfterText: iconAfterText,
      iconSpacing: iconSpacing,
      isDisabled: isDisabled,
      isLoading: isLoading,
      loadingColor: loadingColor ?? Colors.white,
      type: AppButtonType.primary,
    );
  }

  /// زر ثانوي
  factory AppButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Color? color,
    Color? textColor,
    Color? borderColor,
    double? fontSize,
    double? width,
    double height = 50,
    double borderRadius = 8,
    double borderWidth = 1,
    IconData? icon,
    bool iconAfterText = false,
    double iconSpacing = 8,
    bool isDisabled = false,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      color: color ?? Colors.transparent,
      textColor: textColor,
      fontSize: fontSize,
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
      icon: icon,
      iconAfterText: iconAfterText,
      iconSpacing: iconSpacing,
      isDisabled: isDisabled,
      isLoading: isLoading,
      loadingColor: loadingColor,
      type: AppButtonType.secondary,
    );
  }

  /// زر نصي
  factory AppButton.text({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Color? textColor,
    double? fontSize,
    IconData? icon,
    bool iconAfterText = false,
    double iconSpacing = 8,
    bool isDisabled = false,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      color: Colors.transparent,
      textColor: textColor,
      fontSize: fontSize,
      icon: icon,
      iconAfterText: iconAfterText,
      iconSpacing: iconSpacing,
      isDisabled: isDisabled,
      isLoading: isLoading,
      loadingColor: loadingColor,
      type: AppButtonType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // تحديد الألوان بناءً على نوع الزر وحالته
    final buttonColor = _getButtonColor(theme);
    final buttonTextColor = _getTextColor(theme);
    final buttonBorderColor = _getBorderColor(theme);
    
    // بناء محتوى الزر
    Widget content = _buildButtonContent(buttonTextColor);
    
    // إنشاء الزر بناءً على نوعه
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: (isDisabled || isLoading) ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: type != AppButtonType.text
                  ? Border.all(
                      color: buttonBorderColor,
                      width: borderWidth,
                    )
                  : null,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء محتوى الزر (نص وأيقونة ومؤشر تحميل)
  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: loadingSize,
        width: loadingSize,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? textColor,
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.bold,
      ),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      icon,
      color: textColor,
      size: (fontSize ?? 16) + 4,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAfterText
          ? [
              textWidget,
              SizedBox(width: iconSpacing),
              iconWidget,
            ]
          : [
              iconWidget,
              SizedBox(width: iconSpacing),
              textWidget,
            ],
    );
  }

  /// الحصول على لون الزر بناءً على نوعه وحالته
  Color _getButtonColor(ThemeData theme) {
    if (isDisabled) {
      return disabledColor;
    }

    switch (type) {
      case AppButtonType.primary:
        return color ?? theme.primaryColor;
      case AppButtonType.secondary:
        return color ?? Colors.transparent;
      case AppButtonType.text:
        return Colors.transparent;
    }
  }

  /// الحصول على لون النص بناءً على نوع الزر وحالته
  Color _getTextColor(ThemeData theme) {
    if (isDisabled) {
      return disabledTextColor;
    }

    switch (type) {
      case AppButtonType.primary:
        return textColor ?? Colors.white;
      case AppButtonType.secondary:
        return textColor ?? theme.primaryColor;
      case AppButtonType.text:
        return textColor ?? theme.primaryColor;
    }
  }

  /// الحصول على لون الحدود بناءً على نوع الزر وحالته
  Color _getBorderColor(ThemeData theme) {
    if (isDisabled) {
      return disabledColor;
    }

    switch (type) {
      case AppButtonType.primary:
        return borderColor ?? Colors.transparent;
      case AppButtonType.secondary:
        return borderColor ?? theme.primaryColor;
      case AppButtonType.text:
        return Colors.transparent;
    }
  }
}

/// أنواع الأزرار المتاحة
enum AppButtonType {
  /// زر أساسي (ملون بالكامل)
  primary,
  
  /// زر ثانوي (حدود فقط)
  secondary,
  
  /// زر نصي (بدون خلفية أو حدود)
  text,
}

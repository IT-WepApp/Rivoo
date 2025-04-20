import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// حقل إدخال النص الموحد للتطبيق
///
/// يستخدم هذا الحقل في جميع أنحاء التطبيق للحفاظ على تناسق واجهة المستخدم
class AppTextField extends StatelessWidget {
  /// تسمية الحقل (إجباري)
  final String label;

  /// نص التلميح
  final String? hint;

  /// وحدة التحكم في النص
  final TextEditingController? controller;

  /// نوع لوحة المفاتيح
  final TextInputType? keyboardType;

  /// ما إذا كان الحقل للنص السري
  final bool obscureText;

  /// أيقونة بداية الحقل
  final IconData? prefixIcon;

  /// أيقونة نهاية الحقل
  final IconData? suffixIcon;

  /// وظيفة تنفذ عند النقر على أيقونة النهاية
  final VoidCallback? onSuffixIconPressed;

  /// وظيفة تنفذ عند تغيير النص
  final ValueChanged<String>? onChanged;

  /// وظيفة تنفذ عند الإرسال
  final ValueChanged<String>? onSubmitted;

  /// وظيفة التحقق من صحة الإدخال
  final String? Function(String?)? validator;

  /// ما إذا كان الحقل للقراءة فقط
  final bool readOnly;

  /// عدد الأسطر الأقصى
  final int? maxLines;

  /// عدد الأسطر الأدنى
  final int? minLines;

  /// الحد الأقصى لعدد الأحرف
  final int? maxLength;

  /// منسقات الإدخال
  final List<TextInputFormatter>? inputFormatters;

  /// لون الخلفية
  final Color? fillColor;

  /// ما إذا كان الحقل معطلاً
  final bool enabled;

  /// النص الافتراضي
  final String? initialValue;

  /// مرجع الحقل
  final FocusNode? focusNode;

  /// وظيفة تنفذ عند التركيز
  final VoidCallback? onTap;

  /// نص الخطأ
  final String? errorText;

  /// لون الحدود
  final Color? borderColor;

  /// لون الحدود عند التركيز
  final Color? focusedBorderColor;

  /// لون النص
  final Color? textColor;

  /// حجم النص
  final double? fontSize;

  /// نمط النص
  final TextStyle? textStyle;

  /// نمط التسمية
  final TextStyle? labelStyle;

  /// نمط التلميح
  final TextStyle? hintStyle;

  /// إنشاء حقل إدخال النص الموحد
  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.fillColor,
    this.enabled = true,
    this.initialValue,
    this.focusNode,
    this.onTap,
    this.errorText,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.fontSize,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // تحديد الألوان والأنماط
    final effectiveFillColor = fillColor ?? theme.inputDecorationTheme.fillColor;
    final effectiveBorderColor = borderColor ?? theme.inputDecorationTheme.enabledBorder?.borderSide.color;
    final effectiveFocusedBorderColor = focusedBorderColor ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? theme.textTheme.bodyLarge?.color;
    
    // إنشاء أيقونة النهاية إذا كانت موجودة
    Widget? suffixIconWidget;
    if (suffixIcon != null) {
      suffixIconWidget = IconButton(
        icon: Icon(suffixIcon),
        onPressed: onSuffixIconPressed,
        color: theme.colorScheme.primary,
      );
    }
    
    // إنشاء حقل النص
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      focusNode: focusNode,
      onTap: onTap,
      style: textStyle ?? TextStyle(
        color: effectiveTextColor,
        fontSize: fontSize ?? 16.0,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: effectiveFillColor,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: theme.colorScheme.primary) : null,
        suffixIcon: suffixIconWidget,
        labelStyle: labelStyle ?? TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        hintStyle: hintStyle ?? TextStyle(color: theme.hintColor),
        errorStyle: TextStyle(color: theme.colorScheme.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: effectiveBorderColor ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: effectiveBorderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
    );
  }
}

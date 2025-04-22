import 'package:flutter/material.dart';

/// قائمة منسدلة مخصصة للتطبيق
/// توفر قائمة منسدلة موحدة بتصميم متناسق مع هوية التطبيق
class AppDropdown<T> extends StatelessWidget {
  /// قائمة العناصر
  final List<DropdownMenuItem<T>> items;
  
  /// القيمة المحددة
  final T? value;
  
  /// دالة يتم تنفيذها عند تغيير القيمة
  final ValueChanged<T?>? onChanged;
  
  /// عنوان القائمة
  final String? label;
  
  /// نص التلميح
  final String? hint;
  
  /// أيقونة بداية القائمة
  final IconData? prefixIcon;
  
  /// لون القائمة
  final Color? fillColor;
  
  /// ما إذا كانت القائمة مطلوبة
  final bool isRequired;
  
  /// رسالة الخطأ
  final String? errorText;
  
  /// ما إذا كانت القائمة معطلة
  final bool enabled;
  
  /// نص المساعدة
  final String? helperText;
  
  /// لون الحدود
  final Color? borderColor;
  
  /// نصف قطر حواف القائمة
  final double borderRadius;
  
  /// سماكة الحدود
  final double borderWidth;
  
  /// لون النص
  final Color? textColor;
  
  /// حجم النص
  final double? fontSize;
  
  /// ما إذا كانت القائمة تحتوي على حدود
  final bool hasBorder;
  
  /// ما إذا كانت القائمة تحتوي على تعبئة
  final bool filled;
  
  /// دالة للتحقق من صحة الاختيار
  final FormFieldValidator<T>? validator;
  
  /// ما إذا كانت القائمة تظهر أيقونة السهم
  final bool showArrow;
  
  /// أيقونة السهم المخصصة
  final Widget? dropdownIcon;
  
  /// ارتفاع القائمة
  final double height;
  
  /// عرض القائمة
  final double? width;
  
  /// محاذاة النص
  final TextAlign textAlign;

  /// منشئ القائمة المنسدلة
  const AppDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.fillColor,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.helperText,
    this.borderColor,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.textColor,
    this.fontSize,
    this.hasBorder = true,
    this.filled = true,
    this.validator,
    this.showArrow = true,
    this.dropdownIcon,
    this.height = 56,
    this.width,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // تحديد الألوان والأنماط
    final textColor = this.textColor ?? theme.textTheme.bodyLarge?.color;
    final labelText = isRequired ? '$label *' : label;
    
    return SizedBox(
      height: height,
      width: width,
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        isExpanded: true,
        icon: dropdownIcon ?? (showArrow
            ? Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.grey : Colors.grey.shade400,
              )
            : const SizedBox.shrink()),
        iconSize: 24,
        elevation: 8,
        style: TextStyle(
          color: enabled ? textColor : Colors.grey,
          fontSize: fontSize ?? 16,
        ),
        dropdownColor: theme.cardColor,
        alignment: Alignment.centerLeft,
        borderRadius: BorderRadius.circular(borderRadius),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          filled: filled,
          fillColor: enabled
              ? (fillColor ?? theme.cardColor)
              : Colors.grey.shade100,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: enabled ? Colors.grey : Colors.grey.shade400,
                )
              : null,
          labelStyle: TextStyle(
            color: enabled ? Colors.grey : Colors.grey.shade400,
            fontSize: fontSize != null ? fontSize! - 2 : 14,
          ),
          hintStyle: TextStyle(
            color: enabled ? Colors.grey : Colors.grey.shade400,
            fontSize: fontSize != null ? fontSize! - 2 : 14,
          ),
          border: _buildBorder(theme, false),
          enabledBorder: _buildBorder(theme, false),
          focusedBorder: _buildBorder(theme, true),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: borderWidth,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: borderWidth + 0.5,
            ),
          ),
          disabledBorder: _buildBorder(theme, false, isDisabled: true),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          enabled: enabled,
        ),
      ),
    );
  }

  /// بناء حدود القائمة
  InputBorder _buildBorder(ThemeData theme, bool isFocused, {bool isDisabled = false}) {
    if (!hasBorder) {
      return InputBorder.none;
    }
    
    Color borderColor;
    if (isDisabled) {
      borderColor = Colors.grey.shade300;
    } else {
      borderColor = this.borderColor ??
          (isFocused ? theme.primaryColor : Colors.grey.shade300);
    }
    
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: borderColor,
        width: isFocused ? borderWidth + 0.5 : borderWidth,
      ),
    );
  }
}

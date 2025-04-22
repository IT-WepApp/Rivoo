import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// حقل نص مخصص للتطبيق
/// يوفر حقل إدخال موحد بتصميم متناسق مع هوية التطبيق
class AppTextField extends StatefulWidget {
  /// عنوان الحقل
  final String? label;
  
  /// نص التلميح
  final String? hint;
  
  /// وحدة التحكم بالنص
  final TextEditingController? controller;
  
  /// نوع لوحة المفاتيح
  final TextInputType keyboardType;
  
  /// ما إذا كان الحقل للنص السري
  final bool obscureText;
  
  /// أيقونة بداية الحقل
  final IconData? prefixIcon;
  
  /// أيقونة نهاية الحقل
  final IconData? suffixIcon;
  
  /// دالة يتم تنفيذها عند النقر على أيقونة النهاية
  final VoidCallback? onSuffixIconPressed;
  
  /// دالة يتم تنفيذها عند تغيير النص
  final ValueChanged<String>? onChanged;
  
  /// دالة يتم تنفيذها عند الانتهاء من التحرير
  final ValueChanged<String>? onSubmitted;
  
  /// دالة للتحقق من صحة الإدخال
  final FormFieldValidator<String>? validator;
  
  /// ما إذا كان الحقل للقراءة فقط
  final bool readOnly;
  
  /// دالة يتم تنفيذها عند النقر على الحقل
  final VoidCallback? onTap;
  
  /// عدد الأسطر الأقصى
  final int? maxLines;
  
  /// عدد الأسطر الأدنى
  final int? minLines;
  
  /// الحد الأقصى لعدد الأحرف
  final int? maxLength;
  
  /// قائمة منسقات الإدخال
  final List<TextInputFormatter>? inputFormatters;
  
  /// لون الحقل
  final Color? fillColor;
  
  /// ما إذا كان الحقل مطلوباً
  final bool isRequired;
  
  /// رسالة الخطأ
  final String? errorText;
  
  /// ما إذا كان الحقل معطلاً
  final bool enabled;
  
  /// نص المساعدة
  final String? helperText;
  
  /// لون الحدود
  final Color? borderColor;
  
  /// نصف قطر حواف الحقل
  final double borderRadius;
  
  /// سماكة الحدود
  final double borderWidth;
  
  /// لون النص
  final Color? textColor;
  
  /// حجم النص
  final double? fontSize;
  
  /// محاذاة النص
  final TextAlign textAlign;
  
  /// نمط النص
  final TextStyle? style;
  
  /// نمط التلميح
  final TextStyle? hintStyle;
  
  /// نمط العنوان
  final TextStyle? labelStyle;
  
  /// ما إذا كان الحقل يحتوي على حدود
  final bool hasBorder;
  
  /// ما إذا كان الحقل يحتوي على تعبئة
  final bool filled;
  
  /// ما إذا كان الحقل يركز تلقائياً
  final bool autofocus;
  
  /// ما إذا كان الحقل يصحح تلقائياً
  final bool autocorrect;
  
  /// ما إذا كان الحقل يقترح كلمات تلقائياً
  final bool enableSuggestions;
  
  /// ما إذا كان الحقل يحتوي على عداد أحرف
  final bool showCounter;
  
  /// ما إذا كان الحقل يحتوي على حدود عند التركيز
  final bool showFocusBorder;

  /// منشئ حقل النص
  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
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
    this.textAlign = TextAlign.start,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.hasBorder = true,
    this.filled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.showCounter = false,
    this.showFocusBorder = true,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // تحديد الألوان والأنماط
    final textColor = widget.textColor ?? theme.textTheme.bodyLarge?.color;
    final labelText = widget.isRequired ? '${widget.label} *' : widget.label;
    
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      textAlign: widget.textAlign,
      style: widget.style ??
          TextStyle(
            color: textColor,
            fontSize: widget.fontSize ?? 16,
          ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        filled: widget.filled,
        fillColor: widget.fillColor ?? theme.cardColor,
        counterText: widget.showCounter ? null : '',
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _isFocused ? theme.primaryColor : Colors.grey,
              )
            : null,
        suffixIcon: _buildSuffixIcon(),
        labelStyle: widget.labelStyle ??
            TextStyle(
              color: _isFocused ? theme.primaryColor : Colors.grey,
              fontSize: widget.fontSize != null ? widget.fontSize! - 2 : 14,
            ),
        hintStyle: widget.hintStyle ??
            TextStyle(
              color: Colors.grey,
              fontSize: widget.fontSize != null ? widget.fontSize! - 2 : 14,
            ),
        border: _buildBorder(theme, false),
        enabledBorder: _buildBorder(theme, false),
        focusedBorder: widget.showFocusBorder
            ? _buildBorder(theme, true)
            : _buildBorder(theme, false),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: widget.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: widget.borderWidth + 0.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  /// بناء أيقونة النهاية
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _isFocused ? Theme.of(context).primaryColor : Colors.grey,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }
    return null;
  }

  /// بناء حدود الحقل
  InputBorder _buildBorder(ThemeData theme, bool isFocused) {
    if (!widget.hasBorder) {
      return InputBorder.none;
    }
    
    final borderColor = widget.borderColor ??
        (isFocused ? theme.primaryColor : Colors.grey.shade300);
    
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: borderColor,
        width: isFocused ? widget.borderWidth + 0.5 : widget.borderWidth,
      ),
    );
  }
}

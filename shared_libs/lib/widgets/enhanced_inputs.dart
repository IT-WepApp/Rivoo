import 'package:flutter/material.dart';

/// حقول إدخال محسنة للتطبيق
/// توفر حقول إدخال بتصميم موحد وتجربة مستخدم محسنة
class EnhancedInputs {
  /// حقل نص محسن
  /// يوفر حقل نص بتصميم موحد مع تأثيرات تفاعلية
  static Widget textField({
    required String label,
    String? hint,
    TextEditingController? controller,
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 16.0,
    ),
    double borderRadius = 8.0,
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? textColor,
    Color? labelColor,
    Color? hintColor,
    Color? errorColor,
    FocusNode? focusNode,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    return _EnhancedTextField(
      label: label,
      hint: hint,
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconPressed: onSuffixIconPressed,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      fillColor: fillColor,
      borderColor: borderColor,
      focusedBorderColor: focusedBorderColor,
      textColor: textColor,
      labelColor: labelColor,
      hintColor: hintColor,
      errorColor: errorColor,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
    );
  }

  /// حقل بحث محسن
  /// يوفر حقل بحث بتصميم موحد مع تأثيرات تفاعلية
  static Widget searchField({
    String? hint,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    VoidCallback? onClear,
    bool enabled = true,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    double borderRadius = 24.0,
    Color? fillColor,
    Color? borderColor,
    Color? textColor,
    Color? hintColor,
    Color? iconColor,
    FocusNode? focusNode,
  }) {
    return _EnhancedSearchField(
      hint: hint ?? 'بحث...',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onClear: onClear,
      enabled: enabled,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      fillColor: fillColor,
      borderColor: borderColor,
      textColor: textColor,
      hintColor: hintColor,
      iconColor: iconColor,
      focusNode: focusNode,
    );
  }

  /// حقل اختيار محسن
  /// يوفر حقل اختيار بتصميم موحد مع تأثيرات تفاعلية
  static Widget dropdown<T>({
    required String label,
    required List<DropdownMenuItem<T>> items,
    required T? value,
    required void Function(T?) onChanged,
    String? hint,
    bool enabled = true,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 16.0,
    ),
    double borderRadius = 8.0,
    Color? fillColor,
    Color? borderColor,
    Color? textColor,
    Color? labelColor,
    Color? hintColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return _EnhancedDropdown<T>(
      label: label,
      items: items,
      value: value,
      onChanged: enabled ? onChanged : null,
      hint: hint,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      fillColor: fillColor,
      borderColor: borderColor,
      textColor: textColor,
      labelColor: labelColor,
      hintColor: hintColor,
      icon: icon,
      iconColor: iconColor,
    );
  }

  /// حقل تاريخ محسن
  /// يوفر حقل اختيار تاريخ بتصميم موحد مع تأثيرات تفاعلية
  static Widget dateField({
    required String label,
    required DateTime? value,
    required void Function(DateTime?) onChanged,
    String? hint,
    DateTime? firstDate,
    DateTime? lastDate,
    bool enabled = true,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 16.0,
    ),
    double borderRadius = 8.0,
    Color? fillColor,
    Color? borderColor,
    Color? textColor,
    Color? labelColor,
    Color? hintColor,
    Color? iconColor,
    String? Function(DateTime?)? validator,
    String dateFormat = 'yyyy/MM/dd',
    FocusNode? focusNode,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    return _EnhancedDateField(
      label: label,
      value: value,
      onChanged: onChanged,
      hint: hint,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      enabled: enabled,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      fillColor: fillColor,
      borderColor: borderColor,
      textColor: textColor,
      labelColor: labelColor,
      hintColor: hintColor,
      iconColor: iconColor,
      validator: validator,
      dateFormat: dateFormat,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// حقل نص محسن
class _EnhancedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? errorColor;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;

  const _EnhancedTextField({
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    required this.keyboardType,
    required this.textInputAction,
    required this.obscureText,
    required this.enabled,
    required this.readOnly,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    required this.contentPadding,
    required this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.errorColor,
    this.focusNode,
    required this.autovalidateMode,
  });

  @override
  _EnhancedTextFieldState createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<_EnhancedTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveFillColor = widget.fillColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100);

    final effectiveBorderColor = widget.borderColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);

    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? theme.primaryColor;

    final effectiveTextColor = widget.textColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveLabelColor = widget.labelColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    final effectiveHintColor = widget.hintColor ??
        (theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38);

    final effectiveErrorColor = widget.errorColor ?? theme.colorScheme.error;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: effectiveLabelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? effectiveFillColor
                  : effectiveFillColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isFocused
                    ? effectiveFocusedBorderColor
                    : _isHovered
                        ? effectiveBorderColor.withOpacity(0.8)
                        : effectiveBorderColor,
                width: _isFocused ? 2 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: effectiveFocusedBorderColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              initialValue: widget.initialValue,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: effectiveHintColor,
                ),
                contentPadding: widget.contentPadding,
                border: InputBorder.none,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? effectiveFocusedBorderColor
                            : effectiveHintColor,
                      )
                    : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: effectiveHintColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : widget.suffixIcon != null
                        ? IconButton(
                            icon: Icon(
                              widget.suffixIcon,
                              color: _isFocused
                                  ? effectiveFocusedBorderColor
                                  : effectiveHintColor,
                            ),
                            onPressed: widget.onSuffixIconPressed,
                          )
                        : null,
                errorStyle: TextStyle(
                  color: effectiveErrorColor,
                  fontSize: 12,
                ),
              ),
              style: TextStyle(
                color: widget.enabled
                    ? effectiveTextColor
                    : effectiveTextColor.withOpacity(0.7),
                fontSize: 16,
              ),
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: _obscureText,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
            ),
          ),
        ],
      ),
    );
  }
}

/// حقل بحث محسن
class _EnhancedSearchField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final FocusNode? focusNode;

  const _EnhancedSearchField({
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    required this.enabled,
    required this.contentPadding,
    required this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.focusNode,
  });

  @override
  _EnhancedSearchFieldState createState() => _EnhancedSearchFieldState();
}

class _EnhancedSearchFieldState extends State<_EnhancedSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleClear() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveFillColor = widget.fillColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100);

    final effectiveBorderColor = widget.borderColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);

    final effectiveTextColor = widget.textColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveHintColor = widget.hintColor ??
        (theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38);

    final effectiveIconColor = widget.iconColor ??
        (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.enabled
              ? effectiveFillColor
              : effectiveFillColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isFocused
                ? theme.primaryColor
                : _isHovered
                    ? effectiveBorderColor.withOpacity(0.8)
                    : effectiveBorderColor,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: effectiveHintColor,
            ),
            contentPadding: widget.contentPadding,
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: _isFocused ? theme.primaryColor : effectiveIconColor,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: effectiveIconColor,
                    ),
                    onPressed: _handleClear,
                  )
                : null,
          ),
          style: TextStyle(
            color: widget.enabled
                ? effectiveTextColor
                : effectiveTextColor.withOpacity(0.7),
            fontSize: 16,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          enabled: widget.enabled,
          onChanged: (value) {
            setState(() {}); // Update to show/hide clear button
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}

/// حقل اختيار محسن
class _EnhancedDropdown<T> extends StatefulWidget {
  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? hint;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final IconData? icon;
  final Color? iconColor;

  const _EnhancedDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    required this.contentPadding,
    required this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.icon,
    this.iconColor,
  });

  @override
  _EnhancedDropdownState<T> createState() => _EnhancedDropdownState<T>();
}

class _EnhancedDropdownState<T> extends State<_EnhancedDropdown<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveFillColor = widget.fillColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100);

    final effectiveBorderColor = widget.borderColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);

    final effectiveTextColor = widget.textColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveLabelColor = widget.labelColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    final effectiveHintColor = widget.hintColor ??
        (theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38);

    final effectiveIconColor = widget.iconColor ??
        (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: effectiveLabelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.onChanged != null
                  ? effectiveFillColor
                  : effectiveFillColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isHovered && widget.onChanged != null
                    ? theme.primaryColor
                    : effectiveBorderColor,
                width: _isHovered && widget.onChanged != null ? 2 : 1,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.contentPadding.horizontal / 2,
              vertical: 4,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: widget.value,
                items: widget.items,
                onChanged: widget.onChanged,
                hint: widget.hint != null
                    ? Text(
                        widget.hint!,
                        style: TextStyle(
                          color: effectiveHintColor,
                        ),
                      )
                    : null,
                icon: Icon(
                  widget.icon ?? Icons.arrow_drop_down,
                  color: effectiveIconColor,
                ),
                isExpanded: true,
                dropdownColor: effectiveFillColor,
                style: TextStyle(
                  color: widget.onChanged != null
                      ? effectiveTextColor
                      : effectiveTextColor.withOpacity(0.7),
                  fontSize: 16,
                ),
                padding: widget.contentPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// حقل تاريخ محسن
class _EnhancedDateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime?) onChanged;
  final String? hint;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? iconColor;
  final String? Function(DateTime?)? validator;
  final String dateFormat;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;

  const _EnhancedDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    required this.firstDate,
    required this.lastDate,
    required this.enabled,
    required this.contentPadding,
    required this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.iconColor,
    this.validator,
    required this.dateFormat,
    this.focusNode,
    required this.autovalidateMode,
  });

  @override
  _EnhancedDateFieldState createState() => _EnhancedDateFieldState();
}

class _EnhancedDateFieldState extends State<_EnhancedDateField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerValue();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(_EnhancedDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateControllerValue();
    }
  }

  void _updateControllerValue() {
    if (widget.value != null) {
      // تنسيق التاريخ حسب الصيغة المطلوبة
      final formattedDate = _formatDate(widget.value!);
      _controller.text = formattedDate;
    } else {
      _controller.text = '';
    }
  }

  String _formatDate(DateTime date) {
    // تنفيذ بسيط لتنسيق التاريخ
    // في التطبيق الحقيقي، يمكن استخدام مكتبة intl
    final format = widget.dateFormat;
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return format
        .replaceAll('yyyy', year)
        .replaceAll('MM', month)
        .replaceAll('dd', day);
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final theme = Theme.of(context);

    // إخفاء لوحة المفاتيح إذا كانت مفتوحة
    FocusScope.of(context).requestFocus(FocusNode());

    final initialDate = widget.value ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      widget.onChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveFillColor = widget.fillColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100);

    final effectiveBorderColor = widget.borderColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);

    final effectiveTextColor = widget.textColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    final effectiveLabelColor = widget.labelColor ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    final effectiveHintColor = widget.hintColor ??
        (theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38);

    final effectiveIconColor = widget.iconColor ??
        (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: effectiveLabelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? effectiveFillColor
                    : effectiveFillColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: _isFocused
                      ? theme.primaryColor
                      : _isHovered && widget.enabled
                          ? effectiveBorderColor.withOpacity(0.8)
                          : effectiveBorderColor,
                  width: _isFocused || (_isHovered && widget.enabled) ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: effectiveHintColor,
                  ),
                  contentPadding: widget.contentPadding,
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: widget.enabled
                        ? effectiveIconColor
                        : effectiveIconColor.withOpacity(0.7),
                  ),
                  errorStyle: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
                style: TextStyle(
                  color: widget.enabled
                      ? effectiveTextColor
                      : effectiveTextColor.withOpacity(0.7),
                  fontSize: 16,
                ),
                readOnly: true,
                enabled: widget.enabled,
                onTap: () => _selectDate(context),
                validator: widget.validator != null
                    ? (value) => widget.validator!(widget.value)
                    : null,
                autovalidateMode: widget.autovalidateMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

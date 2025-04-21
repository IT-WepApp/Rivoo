import 'package:flutter/material.dart';

/// زر التطبيق الموحد
///
/// يستخدم هذا الزر في جميع أنحاء التطبيق للحفاظ على تناسق واجهة المستخدم
class AppButton extends StatelessWidget {
  /// نص الزر
  final String text;

  /// وظيفة يتم تنفيذها عند النقر على الزر
  final VoidCallback? onPressed;

  /// أيقونة الزر (اختيارية)
  final IconData? icon;

  /// لون خلفية الزر (اختياري)
  final Color? backgroundColor;

  /// لون النص (اختياري)
  final Color? textColor;

  /// حجم النص (اختياري)
  final double? fontSize;

  /// عرض الزر (اختياري)
  final double? width;

  /// ارتفاع الزر (اختياري)
  final double? height;

  /// نصف قطر حواف الزر (اختياري)
  final double? borderRadius;

  /// سماكة الحدود (اختيارية)
  final double? borderWidth;

  /// لون الحدود (اختياري)
  final Color? borderColor;

  /// ما إذا كان الزر معطلاً
  final bool isDisabled;

  /// ما إذا كان الزر قيد التحميل
  final bool isLoading;

  /// نص التحميل (اختياري)
  final String loadingText;

  /// موضع الأيقونة (اختياري)
  final bool iconLeading;

  /// المسافة بين الأيقونة والنص (اختيارية)
  final double iconSpacing;

  /// حجم الأيقونة (اختياري)
  final double? iconSize;

  /// لون الأيقونة (اختياري)
  final Color? iconColor;

  /// إنشاء زر التطبيق الموحد
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.borderWidth,
    this.borderColor,
    this.isDisabled = false,
    this.isLoading = false,
    this.loadingText = 'جاري التحميل...',
    this.iconLeading = true,
    this.iconSpacing = 8.0,
    this.iconSize,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // تحديد الألوان بناءً على حالة الزر
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? theme.colorScheme.onPrimary;
    final effectiveIconColor = iconColor ?? effectiveTextColor;

    // إنشاء محتوى الزر
    Widget buttonContent;

    if (isLoading) {
      // محتوى الزر أثناء التحميل
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          ),
          SizedBox(width: iconSpacing),
          Text(
            loadingText,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: fontSize ?? 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      // محتوى الزر مع أيقونة
      final iconWidget = Icon(
        icon,
        size: iconSize ?? 20.0,
        color: effectiveIconColor,
      );

      final textWidget = Text(
        text,
        style: TextStyle(
          color: effectiveTextColor,
          fontSize: fontSize ?? 16.0,
          fontWeight: FontWeight.bold,
        ),
      );

      if (iconLeading) {
        buttonContent = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(width: iconSpacing),
            textWidget,
          ],
        );
      } else {
        buttonContent = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textWidget,
            SizedBox(width: iconSpacing),
            iconWidget,
          ],
        );
      }
    } else {
      // محتوى الزر بدون أيقونة
      buttonContent = Text(
        text,
        style: TextStyle(
          color: effectiveTextColor,
          fontSize: fontSize ?? 16.0,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // إنشاء الزر
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBackgroundColor.withValues(alpha: 153), // 0.6 * 255 = 153
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 153), // 0.6 * 255 = 153
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
            side: borderWidth != null && borderColor != null
                ? BorderSide(width: borderWidth!, color: borderColor!)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          elevation: 2.0,
        ),
        child: Center(child: buttonContent),
      ),
    );
  }
}

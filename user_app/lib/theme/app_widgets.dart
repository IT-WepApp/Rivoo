import 'package:flutter/material.dart';
import 'app_theme.dart';

/// مكونات واجهة المستخدم الموحدة
///
/// يحتوي هذا الملف على مكونات واجهة المستخدم الموحدة المستخدمة في جميع أنحاء التطبيق
/// مثل الأزرار وحقول الإدخال والبطاقات وغيرها

class AppWidgets {
  // منع إنشاء نسخة من الفئة
  AppWidgets._();

  /// زر التطبيق الموحد
  static Widget AppButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double? height,
    double? width,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    final buttonHeight = height ?? AppDimensions.buttonHeight;
    final buttonWidth = width ?? (isFullWidth ? double.infinity : null);
    final buttonPadding = padding ??
        const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL);
    final buttonBorderRadius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusS);

    if (isOutlined) {
      return SizedBox(
        height: buttonHeight,
        width: buttonWidth,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: buttonBorderRadius,
            ),
            side: BorderSide(color: backgroundColor ?? AppColors.primary),
          ),
          child: _buildButtonContent(text, icon, isLoading),
        ),
      );
    } else {
      return SizedBox(
        height: buttonHeight,
        width: buttonWidth,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.textOnPrimary,
            backgroundColor: backgroundColor ?? AppColors.primary,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: buttonBorderRadius,
            ),
          ),
          child: _buildButtonContent(text, icon, isLoading),
        ),
      );
    }
  }

  /// محتوى الزر (نص + أيقونة + مؤشر التحميل)
  static Widget _buildButtonContent(
      String text, IconData? icon, bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      return Text(text);
    }
  }

  /// حقل إدخال النص الموحد
  static Widget AppTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    Function()? onTap,
    IconData? prefixIcon,
    Widget? suffix,
    bool readOnly = false,
    int? maxLines = 1,
    int? maxLength,
    bool enabled = true,
    String? Function(String?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffix: suffix,
      ),
    );
  }

  /// بطاقة التطبيق الموحدة
  static Widget AppCard({
    required Widget child,
    VoidCallback? onTap,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    double? elevation,
  }) {
    final cardWidget = Card(
      color: backgroundColor ?? AppColors.surface,
      elevation: elevation ?? AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppDimensions.radiusM),
      ),
      margin: margin ?? const EdgeInsets.all(AppDimensions.paddingS),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusM),
        child: cardWidget,
      );
    } else {
      return cardWidget;
    }
  }

  /// قائمة فارغة مع رسالة ودعوة للإجراء
  static Widget AppEmptyList({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData icon = Icons.inbox_outlined,
    double? iconSize,
    Color? iconColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize ?? 64,
            color: iconColor ?? AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimensions.paddingL),
            AppButton(
              text: actionLabel,
              onPressed: onAction,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }

  /// شريط تحميل مع نسبة مئوية
  static Widget AppProgressBar({
    required double value,
    double? height,
    Color? backgroundColor,
    Color? progressColor,
    BorderRadius? borderRadius,
    bool showPercentage = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppDimensions.radiusXS),
          child: LinearProgressIndicator(
            value: value,
            minHeight: height ?? 8,
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? AppColors.primary),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// شارة العدد
  static Widget AppBadge({
    required Widget child,
    required int count,
    Color? backgroundColor,
    Color? textColor,
    double? size,
    EdgeInsetsGeometry? padding,
  }) {
    final badgeSize = size ?? 18;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              padding: padding ?? EdgeInsets.zero,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: TextStyle(
                    color: textColor ?? AppColors.textOnPrimary,
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

  /// مؤشر الحالة
  static Widget AppStatusIndicator({
    required String status,
    required Color color,
    double? size,
    double? textSize,
  }) {
    final indicatorSize = size ?? 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: TextStyle(
            fontSize: textSize ?? 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// شريط البحث
  static Widget AppSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String hintText = 'بحث...',
    VoidCallback? onFilterTap,
    bool showFilterButton = true,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingXS,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: AppColors.textHint),
              ),
              onSubmitted: onSearch,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: () {
                controller.clear();
                onSearch('');
              },
            ),
          if (showFilterButton)
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
              onPressed: onFilterTap,
            ),
        ],
      ),
    );
  }

  /// عنصر قائمة مع صورة
  static Widget AppListItem({
    required String title,
    String? subtitle,
    String? imageUrl,
    IconData? icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: Image.network(
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.textSecondary),
                  );
                },
              ),
            )
          : icon != null
              ? Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                )
              : null,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

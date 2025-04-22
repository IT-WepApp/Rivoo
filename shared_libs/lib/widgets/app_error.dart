import 'package:flutter/material.dart';

/// عنصر عرض الأخطاء المخصص للتطبيق
/// يوفر عنصر موحد لعرض رسائل الخطأ بتصميم متناسق مع هوية التطبيق
class AppError extends StatelessWidget {
  /// رسالة الخطأ
  final String message;
  
  /// أيقونة الخطأ
  final IconData icon;
  
  /// لون أيقونة الخطأ
  final Color? iconColor;
  
  /// حجم أيقونة الخطأ
  final double iconSize;
  
  /// نمط نص الخطأ
  final TextStyle? textStyle;
  
  /// المسافة بين الأيقونة والنص
  final double spacing;
  
  /// دالة يتم تنفيذها عند النقر على زر إعادة المحاولة
  final VoidCallback? onRetry;
  
  /// نص زر إعادة المحاولة
  final String retryText;
  
  /// ما إذا كان يظهر زر إعادة المحاولة
  final bool showRetryButton;
  
  /// لون زر إعادة المحاولة
  final Color? retryButtonColor;
  
  /// لون نص زر إعادة المحاولة
  final Color? retryTextColor;
  
  /// ما إذا كان الخطأ يظهر على كامل الشاشة
  final bool fullScreen;
  
  /// لون الخلفية
  final Color? backgroundColor;
  
  /// نصف قطر حواف الخلفية
  final double backgroundRadius;

  /// منشئ عنصر الخطأ
  const AppError({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.iconSize = 48,
    this.textStyle,
    this.spacing = 16,
    this.onRetry,
    this.retryText = 'إعادة المحاولة',
    this.showRetryButton = true,
    this.retryButtonColor,
    this.retryTextColor,
    this.fullScreen = false,
    this.backgroundColor,
    this.backgroundRadius = 8,
  }) : super(key: key);

  /// عنصر خطأ للشبكة
  factory AppError.network({
    Key? key,
    String message = 'حدث خطأ في الاتصال بالشبكة',
    VoidCallback? onRetry,
    bool showRetryButton = true,
    bool fullScreen = false,
    Color? backgroundColor,
    double backgroundRadius = 8,
  }) {
    return AppError(
      key: key,
      message: message,
      icon: Icons.wifi_off,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      fullScreen: fullScreen,
      backgroundColor: backgroundColor,
      backgroundRadius: backgroundRadius,
    );
  }

  /// عنصر خطأ للخادم
  factory AppError.server({
    Key? key,
    String message = 'حدث خطأ في الخادم',
    VoidCallback? onRetry,
    bool showRetryButton = true,
    bool fullScreen = false,
    Color? backgroundColor,
    double backgroundRadius = 8,
  }) {
    return AppError(
      key: key,
      message: message,
      icon: Icons.cloud_off,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      fullScreen: fullScreen,
      backgroundColor: backgroundColor,
      backgroundRadius: backgroundRadius,
    );
  }

  /// عنصر خطأ للبيانات غير الموجودة
  factory AppError.notFound({
    Key? key,
    String message = 'لم يتم العثور على البيانات المطلوبة',
    VoidCallback? onRetry,
    bool showRetryButton = true,
    bool fullScreen = false,
    Color? backgroundColor,
    double backgroundRadius = 8,
  }) {
    return AppError(
      key: key,
      message: message,
      icon: Icons.search_off,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      fullScreen: fullScreen,
      backgroundColor: backgroundColor,
      backgroundRadius: backgroundRadius,
    );
  }

  /// عنصر خطأ للصلاحيات
  factory AppError.permission({
    Key? key,
    String message = 'ليس لديك صلاحية للوصول إلى هذا المحتوى',
    VoidCallback? onRetry,
    bool showRetryButton = false,
    bool fullScreen = false,
    Color? backgroundColor,
    double backgroundRadius = 8,
  }) {
    return AppError(
      key: key,
      message: message,
      icon: Icons.no_accounts,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      fullScreen: fullScreen,
      backgroundColor: backgroundColor,
      backgroundRadius: backgroundRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = iconColor ?? theme.colorScheme.error;
    
    // بناء محتوى الخطأ
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: errorColor,
          size: iconSize,
        ),
        SizedBox(height: spacing),
        Text(
          message,
          style: textStyle ??
              TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        if (showRetryButton && onRetry != null) ...[
          SizedBox(height: spacing),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: retryButtonColor ?? theme.primaryColor,
              foregroundColor: retryTextColor ?? Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(retryText),
          ),
        ],
      ],
    );
    
    // إضافة خلفية إذا كانت مطلوبة
    if (backgroundColor != null) {
      content = Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(backgroundRadius),
        ),
        child: content,
      );
    }
    
    // إذا كان الخطأ على كامل الشاشة
    if (fullScreen) {
      return Container(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      );
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}

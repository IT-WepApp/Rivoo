import 'package:flutter/material.dart';

/// مؤشر تحميل مخصص للتطبيق
/// يوفر مؤشر تحميل موحد بتصميم متناسق مع هوية التطبيق
class AppLoading extends StatelessWidget {
  /// حجم مؤشر التحميل
  final double size;
  
  /// سماكة مؤشر التحميل
  final double strokeWidth;
  
  /// لون مؤشر التحميل
  final Color? color;
  
  /// نص التحميل
  final String? text;
  
  /// نمط نص التحميل
  final TextStyle? textStyle;
  
  /// المسافة بين مؤشر التحميل والنص
  final double textSpacing;
  
  /// ما إذا كان النص يظهر أسفل مؤشر التحميل
  final bool textBelow;
  
  /// نوع مؤشر التحميل
  final LoadingType type;
  
  /// لون الخلفية
  final Color? backgroundColor;
  
  /// ما إذا كان مؤشر التحميل يظهر على كامل الشاشة
  final bool fullScreen;
  
  /// نصف قطر حواف الخلفية
  final double backgroundRadius;

  /// منشئ مؤشر التحميل
  const AppLoading({
    Key? key,
    this.size = 40,
    this.strokeWidth = 4,
    this.color,
    this.text,
    this.textStyle,
    this.textSpacing = 16,
    this.textBelow = true,
    this.type = LoadingType.circular,
    this.backgroundColor,
    this.fullScreen = false,
    this.backgroundRadius = 8,
  }) : super(key: key);

  /// مؤشر تحميل دائري
  factory AppLoading.circular({
    Key? key,
    double size = 40,
    double strokeWidth = 4,
    Color? color,
    String? text,
    TextStyle? textStyle,
    double textSpacing = 16,
    bool textBelow = true,
    Color? backgroundColor,
    bool fullScreen = false,
    double backgroundRadius = 8,
  }) {
    return AppLoading(
      key: key,
      size: size,
      strokeWidth: strokeWidth,
      color: color,
      text: text,
      textStyle: textStyle,
      textSpacing: textSpacing,
      textBelow: textBelow,
      type: LoadingType.circular,
      backgroundColor: backgroundColor,
      fullScreen: fullScreen,
      backgroundRadius: backgroundRadius,
    );
  }

  /// مؤشر تحميل خطي
  factory AppLoading.linear({
    Key? key,
    double size = 4,
    double strokeWidth = 4,
    Color? color,
    String? text,
    TextStyle? textStyle,
    double textSpacing = 16,
    bool textBelow = true,
    Color? backgroundColor,
    bool fullScreen = false,
    double backgroundRadius = 8,
  }) {
    return AppLoading(
      key: key,
      size: size,
      strokeWidth: strokeWidth,
      color: color,
      text: text,
      textStyle: textStyle,
      textSpacing: textSpacing,
      textBelow: textBelow,
      type: LoadingType.linear,
      backgroundColor: backgroundColor,
      fullScreen: fullScreen,
      backgroundRadius: backgroundRadius,
    );
  }

  /// مؤشر تحميل على كامل الشاشة
  factory AppLoading.fullScreen({
    Key? key,
    double size = 50,
    double strokeWidth = 4,
    Color? color,
    String? text,
    TextStyle? textStyle,
    double textSpacing = 16,
    bool textBelow = true,
    Color? backgroundColor,
    double backgroundRadius = 8,
  }) {
    return AppLoading(
      key: key,
      size: size,
      strokeWidth: strokeWidth,
      color: color,
      text: text,
      textStyle: textStyle,
      textSpacing: textSpacing,
      textBelow: textBelow,
      type: LoadingType.circular,
      backgroundColor: backgroundColor,
      fullScreen: true,
      backgroundRadius: backgroundRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.primaryColor;
    
    // بناء مؤشر التحميل
    Widget loadingIndicator;
    switch (type) {
      case LoadingType.circular:
        loadingIndicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        );
        break;
      case LoadingType.linear:
        loadingIndicator = SizedBox(
          height: size,
          width: double.infinity,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            backgroundColor: theme.colorScheme.background,
          ),
        );
        break;
    }
    
    // إضافة النص إذا كان موجوداً
    Widget content;
    if (text != null) {
      final textWidget = Text(
        text!,
        style: textStyle ??
            TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
        textAlign: TextAlign.center,
      );
      
      if (textBelow) {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            loadingIndicator,
            SizedBox(height: textSpacing),
            textWidget,
          ],
        );
      } else {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            loadingIndicator,
            SizedBox(width: textSpacing),
            textWidget,
          ],
        );
      }
    } else {
      content = loadingIndicator;
    }
    
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
    
    // إذا كان مؤشر التحميل على كامل الشاشة
    if (fullScreen) {
      return Container(
        color: backgroundColor != null
            ? backgroundColor!.withOpacity(0.7)
            : Colors.black.withOpacity(0.3),
        child: Center(
          child: content,
        ),
      );
    }
    
    return Center(child: content);
  }
}

/// أنواع مؤشرات التحميل
enum LoadingType {
  /// مؤشر تحميل دائري
  circular,
  
  /// مؤشر تحميل خطي
  linear,
}

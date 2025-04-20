import 'package:flutter/material.dart';
import 'package:user_app/core/utils/responsive_utils.dart';

/// بناء متجاوب للواجهات
///
/// يسمح هذا المكون ببناء واجهات مختلفة بناءً على حجم الشاشة
class ResponsiveBuilder extends StatelessWidget {
  /// بناء الواجهة للهاتف المحمول
  final Widget Function(BuildContext context) mobileBuilder;

  /// بناء الواجهة للجهاز اللوحي الصغير (اختياري)
  final Widget Function(BuildContext context)? smallTabletBuilder;

  /// بناء الواجهة للجهاز اللوحي الكبير (اختياري)
  final Widget Function(BuildContext context)? largeTabletBuilder;

  /// بناء الواجهة لسطح المكتب (اختياري)
  final Widget Function(BuildContext context)? desktopBuilder;

  const ResponsiveBuilder({
    Key? key,
    required this.mobileBuilder,
    this.smallTabletBuilder,
    this.largeTabletBuilder,
    this.desktopBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد نوع الجهاز
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    // إرجاع الواجهة المناسبة بناءً على نوع الجهاز
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopBuilder?.call(context) ?? 
               largeTabletBuilder?.call(context) ?? 
               smallTabletBuilder?.call(context) ?? 
               mobileBuilder(context);
      
      case DeviceType.largeTablet:
        return largeTabletBuilder?.call(context) ?? 
               smallTabletBuilder?.call(context) ?? 
               mobileBuilder(context);
      
      case DeviceType.smallTablet:
        return smallTabletBuilder?.call(context) ?? 
               mobileBuilder(context);
      
      case DeviceType.phone:
      default:
        return mobileBuilder(context);
    }
  }
}

/// بناء متجاوب للواجهات بناءً على الاتجاه
///
/// يسمح هذا المكون ببناء واجهات مختلفة بناءً على اتجاه الشاشة
class OrientationResponsiveBuilder extends StatelessWidget {
  /// بناء الواجهة للوضع العمودي
  final Widget Function(BuildContext context) portraitBuilder;

  /// بناء الواجهة للوضع الأفقي
  final Widget Function(BuildContext context) landscapeBuilder;

  const OrientationResponsiveBuilder({
    Key? key,
    required this.portraitBuilder,
    required this.landscapeBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد اتجاه الشاشة
    final isPortrait = ResponsiveUtils.isPortrait(context);
    
    // إرجاع الواجهة المناسبة بناءً على اتجاه الشاشة
    return isPortrait ? portraitBuilder(context) : landscapeBuilder(context);
  }
}

/// عرض متجاوب
///
/// يسمح هذا المكون بتحديد عرض متجاوب بناءً على حجم الشاشة
class ResponsiveWidth extends StatelessWidget {
  /// المحتوى
  final Widget child;
  
  /// نسبة العرض الأساسية (للهاتف)
  final double baseWidthRatio;
  
  const ResponsiveWidth({
    Key? key,
    required this.child,
    this.baseWidthRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب العرض المتجاوب
    final widthRatio = ResponsiveUtils.getResponsiveWidthRatio(context, baseWidthRatio);
    final width = MediaQuery.of(context).size.width * widthRatio;
    
    // إرجاع المكون بالعرض المحسوب
    return SizedBox(
      width: width,
      child: child,
    );
  }
}

/// حاوية متجاوبة
///
/// يسمح هذا المكون بتطبيق حشوات وهوامش متجاوبة
class ResponsiveContainer extends StatelessWidget {
  /// المحتوى
  final Widget child;
  
  /// الحشوة الأساسية الأفقية
  final double basePaddingHorizontal;
  
  /// الحشوة الأساسية العمودية
  final double basePaddingVertical;
  
  /// الهامش الأساسي الأفقي
  final double baseMarginHorizontal;
  
  /// الهامش الأساسي العمودي
  final double baseMarginVertical;
  
  /// لون الخلفية
  final Color? backgroundColor;
  
  /// نصف قطر الحواف الأساسي
  final double baseBorderRadius;
  
  /// حدود
  final Border? border;
  
  /// ظل
  final List<BoxShadow>? boxShadow;
  
  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.basePaddingHorizontal = 16.0,
    this.basePaddingVertical = 16.0,
    this.baseMarginHorizontal = 0.0,
    this.baseMarginVertical = 0.0,
    this.backgroundColor,
    this.baseBorderRadius = 0.0,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب الحشوة والهامش المتجاوبين
    final padding = ResponsiveUtils.getResponsivePadding(
      context,
      baseHorizontal: basePaddingHorizontal,
      baseVertical: basePaddingVertical,
    );
    
    final margin = ResponsiveUtils.getResponsiveMargin(
      context,
      baseHorizontal: baseMarginHorizontal,
      baseVertical: baseMarginVertical,
    );
    
    // حساب نصف قطر الحواف المتجاوب
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context, baseBorderRadius);
    
    // إرجاع الحاوية المتجاوبة
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// نص متجاوب
///
/// يسمح هذا المكون بعرض نص بحجم متجاوب
class ResponsiveText extends StatelessWidget {
  /// النص
  final String text;
  
  /// نمط النص
  final TextStyle? style;
  
  /// محاذاة النص
  final TextAlign? textAlign;
  
  /// عدد الأسطر الأقصى
  final int? maxLines;
  
  /// سلوك تجاوز النص
  final TextOverflow? overflow;
  
  /// عامل تكبير النص الإضافي
  final double scaleFactor;
  
  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على نمط النص الأساسي
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    
    // حساب حجم الخط المتجاوب
    final responsiveFontSize = baseStyle!.fontSize != null
        ? ResponsiveUtils.getResponsiveFontSize(context, baseStyle.fontSize! * scaleFactor)
        : null;
    
    // إنشاء نمط النص المتجاوب
    final responsiveStyle = baseStyle.copyWith(
      fontSize: responsiveFontSize,
    );
    
    // إرجاع النص بالنمط المتجاوب
    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// أيقونة متجاوبة
///
/// يسمح هذا المكون بعرض أيقونة بحجم متجاوب
class ResponsiveIcon extends StatelessWidget {
  /// الأيقونة
  final IconData icon;
  
  /// الحجم الأساسي
  final double baseSize;
  
  /// اللون
  final Color? color;
  
  const ResponsiveIcon(
    this.icon, {
    Key? key,
    this.baseSize = 24.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب حجم الأيقونة المتجاوب
    final responsiveSize = ResponsiveUtils.getResponsiveIconSize(context, baseSize);
    
    // إرجاع الأيقونة بالحجم المتجاوب
    return Icon(
      icon,
      size: responsiveSize,
      color: color,
    );
  }
}

/// شبكة متجاوبة
///
/// يسمح هذا المكون بعرض شبكة بعدد أعمدة متجاوب
class ResponsiveGrid extends StatelessWidget {
  /// العناصر
  final List<Widget> children;
  
  /// المسافة بين العناصر
  final double spacing;
  
  /// نسبة العرض إلى الارتفاع للعناصر
  final double childAspectRatio;
  
  /// الحشوة
  final EdgeInsetsGeometry? padding;
  
  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب عدد الأعمدة المتجاوب
    final crossAxisCount = ResponsiveUtils.getResponsiveGridCount(context);
    
    // حساب المسافة المتجاوبة
    final responsiveSpacing = spacing * ResponsiveUtils.getResponsiveScale(context);
    
    // إرجاع الشبكة المتجاوبة
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: responsiveSpacing,
        mainAxisSpacing: responsiveSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// زر متجاوب
///
/// يسمح هذا المكون بعرض زر بحجم متجاوب
class ResponsiveButton extends StatelessWidget {
  /// النص
  final String text;
  
  /// الأيقونة (اختيارية)
  final IconData? icon;
  
  /// الإجراء عند الضغط
  final VoidCallback onPressed;
  
  /// لون الزر
  final Color? color;
  
  /// لون النص
  final Color? textColor;
  
  /// الارتفاع الأساسي
  final double baseHeight;
  
  /// العرض (اختياري)
  final double? width;
  
  /// نصف قطر الحواف الأساسي
  final double baseBorderRadius;
  
  /// حجم الخط الأساسي
  final double baseFontSize;
  
  const ResponsiveButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.color,
    this.textColor,
    this.baseHeight = 48.0,
    this.width,
    this.baseBorderRadius = 8.0,
    this.baseFontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب الارتفاع المتجاوب
    final responsiveHeight = ResponsiveUtils.getResponsiveHeight(context, baseHeight);
    
    // حساب نصف قطر الحواف المتجاوب
    final responsiveBorderRadius = ResponsiveUtils.getResponsiveBorderRadius(context, baseBorderRadius);
    
    // حساب حجم الخط المتجاوب
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(context, baseFontSize);
    
    // الألوان
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;
    final buttonTextColor = textColor ?? Theme.of(context).colorScheme.onPrimary;
    
    // إرجاع الزر المتجاوب
    return SizedBox(
      height: responsiveHeight,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: buttonTextColor,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              SizedBox(width: responsiveFontSize / 2),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: responsiveFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

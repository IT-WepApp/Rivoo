import 'package:flutter/material.dart';

/// أداة مساعدة للتصميم المتجاوب
/// 
/// توفر هذه الأداة طرقًا مساعدة للتعامل مع مختلف أحجام الشاشات
/// وتسهيل إنشاء واجهات مستخدم متجاوبة
class ResponsiveUtils {
  /// الحصول على حجم الشاشة
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  
  /// الحصول على عرض الشاشة
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// الحصول على ارتفاع الشاشة
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// الحصول على نسبة العرض إلى الارتفاع
  static double getAspectRatio(BuildContext context) {
    return MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
  }
  
  /// التحقق مما إذا كان الجهاز هاتفًا
  static bool isPhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width < 600;
  }
  
  /// التحقق مما إذا كان الجهاز جهاز لوحي صغير
  static bool isSmallTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 900;
  }
  
  /// التحقق مما إذا كان الجهاز جهاز لوحي كبير
  static bool isLargeTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 900 && width < 1200;
  }
  
  /// التحقق مما إذا كان الجهاز سطح مكتب
  static bool isDesktop(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 1200;
  }
  
  /// الحصول على نوع الجهاز
  static DeviceType getDeviceType(BuildContext context) {
    if (isPhone(context)) {
      return DeviceType.phone;
    } else if (isSmallTablet(context)) {
      return DeviceType.smallTablet;
    } else if (isLargeTablet(context)) {
      return DeviceType.largeTablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// الحصول على حجم الخط المتجاوب
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return baseFontSize;
      case DeviceType.smallTablet:
        return baseFontSize * 1.2;
      case DeviceType.largeTablet:
        return baseFontSize * 1.4;
      case DeviceType.desktop:
        return baseFontSize * 1.6;
    }
  }
  
  /// الحصول على حجم الأيقونة المتجاوب
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return baseIconSize;
      case DeviceType.smallTablet:
        return baseIconSize * 1.2;
      case DeviceType.largeTablet:
        return baseIconSize * 1.4;
      case DeviceType.desktop:
        return baseIconSize * 1.6;
    }
  }
  
  /// الحصول على حشوة متجاوبة
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double baseHorizontal = 16.0,
    double baseVertical = 16.0,
  }) {
    final deviceType = getDeviceType(context);
    double horizontalFactor;
    double verticalFactor;
    
    switch (deviceType) {
      case DeviceType.phone:
        horizontalFactor = 1.0;
        verticalFactor = 1.0;
        break;
      case DeviceType.smallTablet:
        horizontalFactor = 1.5;
        verticalFactor = 1.3;
        break;
      case DeviceType.largeTablet:
        horizontalFactor = 2.0;
        verticalFactor = 1.5;
        break;
      case DeviceType.desktop:
        horizontalFactor = 2.5;
        verticalFactor = 1.8;
        break;
    }
    
    return EdgeInsets.symmetric(
      horizontal: baseHorizontal * horizontalFactor,
      vertical: baseVertical * verticalFactor,
    );
  }
  
  /// الحصول على هامش متجاوب
  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double baseHorizontal = 16.0,
    double baseVertical = 16.0,
  }) {
    return getResponsivePadding(
      context,
      baseHorizontal: baseHorizontal,
      baseVertical: baseVertical,
    );
  }
  
  /// الحصول على عدد الأعمدة المناسب للشبكة
  static int getResponsiveGridCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return 2;
      case DeviceType.smallTablet:
        return 3;
      case DeviceType.largeTablet:
        return 4;
      case DeviceType.desktop:
        return 6;
    }
  }
  
  /// الحصول على نسبة العرض المتجاوبة
  static double getResponsiveWidthRatio(BuildContext context, double baseRatio) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return baseRatio;
      case DeviceType.smallTablet:
        return baseRatio * 0.85;
      case DeviceType.largeTablet:
        return baseRatio * 0.7;
      case DeviceType.desktop:
        return baseRatio * 0.5;
    }
  }
  
  /// الحصول على ارتفاع متجاوب
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return baseHeight;
      case DeviceType.smallTablet:
        return baseHeight * 1.2;
      case DeviceType.largeTablet:
        return baseHeight * 1.4;
      case DeviceType.desktop:
        return baseHeight * 1.6;
    }
  }
  
  /// التحقق من اتجاه الشاشة
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// التحقق من اتجاه الشاشة
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// الحصول على عامل القياس المتجاوب
  static double getResponsiveScale(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return 1.0;
      case DeviceType.smallTablet:
        return 1.2;
      case DeviceType.largeTablet:
        return 1.4;
      case DeviceType.desktop:
        return 1.6;
    }
  }
  
  /// التحقق من حجم الخط المفضل للمستخدم
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
  
  /// التحقق من وضع النظام المظلم
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// الحصول على حجم الشاشة الآمن (بدون تداخل مع شريط الحالة وغيره)
  static EdgeInsets getSafePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  /// الحصول على نصف قطر الحواف المتجاوب
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return baseRadius;
      case DeviceType.smallTablet:
        return baseRadius * 1.2;
      case DeviceType.largeTablet:
        return baseRadius * 1.4;
      case DeviceType.desktop:
        return baseRadius * 1.6;
    }
  }
}

/// أنواع الأجهزة
enum DeviceType {
  phone,
  smallTablet,
  largeTablet,
  desktop,
}

/// امتداد للسياق لتسهيل استخدام الأدوات المتجاوبة
extension ResponsiveContext on BuildContext {
  /// الحصول على حجم الشاشة
  Size get screenSize => ResponsiveUtils.getScreenSize(this);
  
  /// الحصول على عرض الشاشة
  double get screenWidth => ResponsiveUtils.getScreenWidth(this);
  
  /// الحصول على ارتفاع الشاشة
  double get screenHeight => ResponsiveUtils.getScreenHeight(this);
  
  /// التحقق مما إذا كان الجهاز هاتفًا
  bool get isPhone => ResponsiveUtils.isPhone(this);
  
  /// التحقق مما إذا كان الجهاز جهاز لوحي صغير
  bool get isSmallTablet => ResponsiveUtils.isSmallTablet(this);
  
  /// التحقق مما إذا كان الجهاز جهاز لوحي كبير
  bool get isLargeTablet => ResponsiveUtils.isLargeTablet(this);
  
  /// التحقق مما إذا كان الجهاز سطح مكتب
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  
  /// الحصول على نوع الجهاز
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  
  /// التحقق من اتجاه الشاشة
  bool get isPortrait => ResponsiveUtils.isPortrait(this);
  
  /// التحقق من اتجاه الشاشة
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  
  /// التحقق من وضع النظام المظلم
  bool get isDarkMode => ResponsiveUtils.isDarkMode(this);
  
  /// الحصول على حجم الخط المتجاوب
  double responsiveFontSize(double baseFontSize) => 
      ResponsiveUtils.getResponsiveFontSize(this, baseFontSize);
  
  /// الحصول على حجم الأيقونة المتجاوب
  double responsiveIconSize(double baseIconSize) => 
      ResponsiveUtils.getResponsiveIconSize(this, baseIconSize);
  
  /// الحصول على حشوة متجاوبة
  EdgeInsets responsivePadding({double baseHorizontal = 16.0, double baseVertical = 16.0}) => 
      ResponsiveUtils.getResponsivePadding(this, baseHorizontal: baseHorizontal, baseVertical: baseVertical);
  
  /// الحصول على هامش متجاوب
  EdgeInsets responsiveMargin({double baseHorizontal = 16.0, double baseVertical = 16.0}) => 
      ResponsiveUtils.getResponsiveMargin(this, baseHorizontal: baseHorizontal, baseVertical: baseVertical);
  
  /// الحصول على عدد الأعمدة المناسب للشبكة
  int get responsiveGridCount => ResponsiveUtils.getResponsiveGridCount(this);
  
  /// الحصول على نسبة العرض المتجاوبة
  double responsiveWidthRatio(double baseRatio) => 
      ResponsiveUtils.getResponsiveWidthRatio(this, baseRatio);
  
  /// الحصول على ارتفاع متجاوب
  double responsiveHeight(double baseHeight) => 
      ResponsiveUtils.getResponsiveHeight(this, baseHeight);
  
  /// الحصول على عامل القياس المتجاوب
  double get responsiveScale => ResponsiveUtils.getResponsiveScale(this);
  
  /// الحصول على نصف قطر الحواف المتجاوب
  double responsiveBorderRadius(double baseRadius) => 
      ResponsiveUtils.getResponsiveBorderRadius(this, baseRadius);
}

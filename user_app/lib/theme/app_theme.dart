import 'package:flutter/material.dart';

/// سمات التطبيق الموحدة
///
/// يحتوي هذا الملف على سمات التطبيق الموحدة المستخدمة في جميع أنحاء التطبيق
/// مثل الألوان والخطوط والأحجام وغيرها

/// ألوان التطبيق
class AppColors {
  // ألوان العلامة التجارية الأساسية
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color accent = Color(0xFFFF9800);
  
  // ألوان الخلفية
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  
  // ألوان النص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF000000);
  
  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // ألوان الحدود والفواصل
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  
  // ألوان الوضع الداكن
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF9E9E9E);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkBorder = Color(0xFF616161);
}

/// قياسات التطبيق
class AppDimensions {
  // الهوامش والحشوات
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // نصف قطر الحواف
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  
  // ارتفاعات العناصر
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;
  static const double bottomNavBarHeight = 56.0;
  
  // أحجام الخط
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;
  
  // أحجام الأيقونات
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  
  // سماكة الحدود
  static const double borderWidthThin = 0.5;
  static const double borderWidthRegular = 1.0;
  static const double borderWidthThick = 2.0;
  
  // ارتفاع الظل
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // مدة الحركات
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
}

/// سمة التطبيق الفاتحة
ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      secondaryContainer: Color(0xFFFFE0B2),
      onSecondaryContainer: Color(0xFFE65100),
      tertiary: Color(0xFF2196F3),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFBBDEFB),
      onTertiaryContainer: Color(0xFF0D47A1),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF121212),
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFFA5D6A7),
    ),
    
    // الخطوط
    fontFamily: 'Cairo',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
    
    // أنماط الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textOnPrimary,
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        elevation: AppDimensions.elevationS,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        side: const BorderSide(color: AppColors.primary),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    ),
    
    // أنماط حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textHint),
      errorStyle: const TextStyle(color: AppColors.error),
    ),
    
    // أنماط البطاقات
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      margin: const EdgeInsets.all(AppDimensions.paddingS),
    ),
    
    // أنماط شريط التطبيق
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    
    // أنماط شريط التنقل السفلي
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: AppDimensions.elevationM,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    
    // أنماط شريط التبويب
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
    
    // أنماط القوائم
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      minLeadingWidth: 24,
      iconColor: AppColors.primary,
    ),
    
    // أنماط الفواصل
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: AppDimensions.paddingM,
    ),
    
    // أنماط مؤشر التقدم
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      circularTrackColor: AppColors.surfaceVariant,
      linearTrackColor: AppColors.surfaceVariant,
    ),
    
    // أنماط مربع الحوار
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      elevation: AppDimensions.elevationL,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
    ),
    
    // أنماط مؤشر التبديل
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return Colors.grey.shade300;
      }),
    ),
    
    // أنماط مربع الاختيار
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
      checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
    ),
    
    // أنماط زر الراديو
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondary;
      }),
    ),
    
    // أنماط مؤشر التمرير
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceVariant,
      thumbColor: AppColors.primary,
      overlayColor: Color(0x1F4CAF50),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: TextStyle(color: AppColors.textOnPrimary),
    ),
    
    // أنماط الرسوم المتحركة
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    // اتجاه النص
    textDirection: TextDirection.rtl,
  );
}

/// سمة التطبيق الداكنة
ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF81C784),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF1B5E20),
      onPrimaryContainer: Color(0xFFC8E6C9),
      secondary: Color(0xFFFFB74D),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFE65100),
      onSecondaryContainer: Color(0xFFFFE0B2),
      tertiary: Color(0xFF64B5F6),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF0D47A1),
      onTertiaryContainer: Color(0xFFBBDEFB),
      error: Color(0xFFEF5350),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFB71C1C),
      onErrorContainer: Color(0xFFFFCDD2),
      background: AppColors.darkBackground,
      onBackground: AppColors.darkTextPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceVariant: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: AppColors.primary,
    ),
    
    // الخطوط
    fontFamily: 'Cairo',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkTextPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextSecondary,
      ),
    ),
    
    // أنماط الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFF81C784),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        elevation: AppDimensions.elevationS,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF81C784),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        side: const BorderSide(color: Color(0xFF81C784)),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF81C784),
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    ),
    
    // أنماط حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      hintStyle: const TextStyle(color: AppColors.darkTextHint),
      errorStyle: const TextStyle(color: Color(0xFFEF5350)),
    ),
    
    // أنماط البطاقات
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      margin: const EdgeInsets.all(AppDimensions.paddingS),
    ),
    
    // أنماط شريط التطبيق
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF81C784)),
    ),
    
    // أنماط شريط التنقل السفلي
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: Color(0xFF81C784),
      unselectedItemColor: AppColors.darkTextSecondary,
      elevation: AppDimensions.elevationM,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    
    // أنماط شريط التبويب
    tabBarTheme: const TabBarTheme(
      labelColor: Color(0xFF81C784),
      unselectedLabelColor: AppColors.darkTextSecondary,
      indicatorColor: Color(0xFF81C784),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
    
    // أنماط القوائم
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      minLeadingWidth: 24,
      iconColor: Color(0xFF81C784),
    ),
    
    // أنماط الفواصل
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: AppDimensions.paddingM,
    ),
    
    // أنماط مؤشر التقدم
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF81C784),
      circularTrackColor: AppColors.darkSurfaceVariant,
      linearTrackColor: AppColors.darkSurfaceVariant,
    ),
    
    // أنماط مربع الحوار
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: AppDimensions.elevationL,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
    ),
    
    // أنماط مؤشر التبديل
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xFF81C784);
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0x801B5E20);
        }
        return Colors.grey.shade800;
      }),
    ),
    
    // أنماط مربع الاختيار
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xFF81C784);
        }
        return null;
      }),
      checkColor: MaterialStateProperty.all(Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
    ),
    
    // أنماط زر الراديو
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xFF81C784);
        }
        return AppColors.darkTextSecondary;
      }),
    ),
    
    // أنماط مؤشر التمرير
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF81C784),
      inactiveTrackColor: AppColors.darkSurfaceVariant,
      thumbColor: Color(0xFF81C784),
      overlayColor: Color(0x1F81C784),
      valueIndicatorColor: Color(0xFF81C784),
      valueIndicatorTextStyle: TextStyle(color: Colors.black),
    ),
    
    // أنماط الرسوم المتحركة
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    // اتجاه النص
    textDirection: TextDirection.rtl,
  );
}

/// مزود سمة التطبيق
class AppTheme {
  static ThemeData light = getLightTheme();
  static ThemeData dark = getDarkTheme();
  
  /// الحصول على سمة التطبيق بناءً على الوضع
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? dark : light;
  }
}

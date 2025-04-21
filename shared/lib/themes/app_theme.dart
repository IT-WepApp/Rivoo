import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// نظام الثيم الموحد للتطبيق
class AppTheme {
  // منع إنشاء نسخ من الكلاس
  AppTheme._();

  /// إنشاء الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.accentColor,
        secondaryContainer: AppColors.accentVariant,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      textTheme: TextTheme(
        displayLarge:
            AppTypography.heading1.copyWith(color: AppColors.textPrimary),
        displayMedium:
            AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        displaySmall:
            AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        headlineMedium:
            AppTypography.heading4.copyWith(color: AppColors.textPrimary),
        headlineSmall:
            AppTypography.heading5.copyWith(color: AppColors.textPrimary),
        titleLarge:
            AppTypography.subtitle.copyWith(color: AppColors.textPrimary),
        bodyLarge:
            AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium:
            AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        bodySmall:
            AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimary),
        labelMedium: AppTypography.label.copyWith(color: AppColors.textPrimary),
        labelSmall:
            AppTypography.overline.copyWith(color: AppColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// إنشاء الثيم الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.accentColor,
        secondaryContainer: AppColors.accentVariant,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: AppColors.textSecondaryDark),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: AppColors.textSecondaryDark),
      ),
      textTheme: TextTheme(
        displayLarge:
            AppTypography.heading1.copyWith(color: AppColors.textPrimaryDark),
        displayMedium:
            AppTypography.heading2.copyWith(color: AppColors.textPrimaryDark),
        displaySmall:
            AppTypography.heading3.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium:
            AppTypography.heading4.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall:
            AppTypography.heading5.copyWith(color: AppColors.textPrimaryDark),
        titleLarge:
            AppTypography.subtitle.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge:
            AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTypography.bodySmall
            .copyWith(color: AppColors.textSecondaryDark),
        labelLarge:
            AppTypography.button.copyWith(color: AppColors.textPrimaryDark),
        labelMedium:
            AppTypography.label.copyWith(color: AppColors.textPrimaryDark),
        labelSmall:
            AppTypography.overline.copyWith(color: AppColors.textSecondaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

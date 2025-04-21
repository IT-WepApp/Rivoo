import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/core/widgets/app_button.dart';
import 'package:user_app/flutter_gen/gen_l10n/app_localizations.dart';

/// شاشة غير مصرح بها
class UnauthorizedScreen extends StatelessWidget {
  /// إنشاء شاشة غير مصرح بها
  const UnauthorizedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة القفل
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
                
                const SizedBox(height: 32),
                
                // عنوان الشاشة
                Text(
                  localizations.unauthorizedTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // وصف الشاشة
                Text(
                  localizations.unauthorizedMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // زر تسجيل الدخول
                AppButton(
                  text: localizations.login,
                  onPressed: () {
                    // التنقل إلى شاشة تسجيل الدخول
                  },
                ),
                
                const SizedBox(height: 16),
                
                // زر إنشاء حساب
                AppButton(
                  text: localizations.register,
                  type: AppButtonType.secondary,
                  onPressed: () {
                    // التنقل إلى شاشة إنشاء حساب
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

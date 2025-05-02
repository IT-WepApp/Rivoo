import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:shared_libs/widgets/app_button.dart';
import 'package:user_app/core/widgets/app_text_field.dart';
import 'package:user_app/l10n/app_localizations.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  /// إنشاء شاشة تسجيل الدخول
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شعار التطبيق
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // عنوان الشاشة
                  Text(
                    localizations.loginTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // وصف الشاشة
                  Text(
                    localizations.loginSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // حقل البريد الإلكتروني
                  AppTextField(
                    controller: _emailController,
                    labelText: localizations.email,
                    hintText: localizations.emailHint,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.emailRequired;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return localizations.emailInvalid;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // حقل كلمة المرور
                  AppTextField(
                    controller: _passwordController,
                    labelText: localizations.password,
                    hintText: localizations.passwordHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.passwordRequired;
                      }
                      if (value.length < 6) {
                        return localizations.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // رابط نسيت كلمة المرور
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // التنقل إلى شاشة نسيت كلمة المرور
                      },
                      child: Text(localizations.forgotPassword),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // زر تسجيل الدخول
                  AppButton(
                    text: localizations.login,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleLogin,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // أو المتابعة باستخدام
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          localizations.orContinueWith,
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // أزرار تسجيل الدخول بواسطة وسائل التواصل الاجتماعي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر جوجل
                      _buildSocialButton(
                        icon: 'assets/icons/google.png',
                        onPressed: () {
                          // تسجيل الدخول بواسطة جوجل
                        },
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // زر فيسبوك
                      _buildSocialButton(
                        icon: 'assets/icons/facebook.png',
                        onPressed: () {
                          // تسجيل الدخول بواسطة فيسبوك
                        },
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // زر آبل
                      _buildSocialButton(
                        icon: 'assets/icons/apple.png',
                        onPressed: () {
                          // تسجيل الدخول بواسطة آبل
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // رابط إنشاء حساب جديد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.dontHaveAccount,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // التنقل إلى شاشة إنشاء حساب
                        },
                        child: Text(localizations.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء زر وسائل التواصل الاجتماعي
  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  /// معالجة تسجيل الدخول
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // تنفيذ عملية تسجيل الدخول
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // التنقل إلى الشاشة الرئيسية بعد تسجيل الدخول بنجاح
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

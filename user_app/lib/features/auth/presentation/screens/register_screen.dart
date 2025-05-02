import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:shared_libs/widgets/app_button.dart';
import 'package:user_app/core/widgets/app_text_field.dart';
import 'package:user_app/l10n/app_localizations.dart';

/// شاشة إنشاء حساب جديد
class RegisterScreen extends StatefulWidget {
  /// إنشاء شاشة إنشاء حساب جديد
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    height: 100,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // عنوان الشاشة
                  Text(
                    localizations.registerTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // وصف الشاشة
                  Text(
                    localizations.registerSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // حقل الاسم
                  AppTextField(
                    controller: _nameController,
                    labelText: localizations.fullName,
                    hintText: localizations.fullNameHint,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.fullNameRequired;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                    textInputAction: TextInputAction.next,
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
                  
                  const SizedBox(height: 16),
                  
                  // حقل تأكيد كلمة المرور
                  AppTextField(
                    controller: _confirmPasswordController,
                    labelText: localizations.confirmPassword,
                    hintText: localizations.confirmPasswordHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.confirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return localizations.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // الموافقة على الشروط والأحكام
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: localizations.iAgree,
                              style: TextStyle(
                                color: AppTheme.textPrimaryColor,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ${localizations.termsAndConditions}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // زر إنشاء حساب
                  AppButton(
                    text: localizations.register,
                    isLoading: _isLoading,
                    onPressed: _isLoading || !_acceptTerms ? null : _handleRegister,
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
                  
                  // رابط تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.alreadyHaveAccount,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // التنقل إلى شاشة تسجيل الدخول
                        },
                        child: Text(localizations.login),
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

  /// معالجة إنشاء حساب
  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // تنفيذ عملية إنشاء حساب
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // التنقل إلى الشاشة الرئيسية بعد إنشاء الحساب بنجاح
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

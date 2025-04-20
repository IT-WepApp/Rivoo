import 'package:flutter/material.dart';
import 'package:user_app/core/utils/validators.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/theme/app_widgets.dart';
import 'package:user_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      try {
        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.signUp(_emailController.text, _passwordController.text);
        
        // بعد التسجيل بنجاح، انتقل إلى صفحة تأكيد البريد الإلكتروني
        if (!mounted) return;
        context.go(RouteConstants.verifyEmail);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إنشاء الحساب: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // شعار التطبيق
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_cart,
                      size: 100,
                      color: Colors.green,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // حقل الاسم
                AppTextField(
                  controller: _nameController,
                  labelText: 'الاسم الكامل',
                  hintText: 'أدخل اسمك الكامل',
                  prefixIcon: Icons.person,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateName,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // حقل البريد الإلكتروني
                AppTextField(
                  controller: _emailController,
                  labelText: 'البريد الإلكتروني',
                  hintText: 'أدخل بريدك الإلكتروني',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // حقل كلمة المرور
                AppTextField(
                  controller: _passwordController,
                  labelText: 'كلمة المرور',
                  hintText: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                  enabled: !isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // حقل تأكيد كلمة المرور
                AppTextField(
                  controller: _confirmPasswordController,
                  labelText: 'تأكيد كلمة المرور',
                  hintText: 'أعد إدخال كلمة المرور',
                  prefixIcon: Icons.lock,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.validateConfirmPassword(
                    _passwordController.text,
                    value,
                  ),
                  enabled: !isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // الموافقة على الشروط والأحكام
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
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
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text: 'أوافق على ',
                              ),
                              TextSpan(
                                text: 'الشروط والأحكام',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                // يمكن إضافة معالج النقر هنا للانتقال إلى صفحة الشروط والأحكام
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // زر إنشاء الحساب
                AppButton(
                  text: 'إنشاء حساب',
                  onPressed: _register,
                  isLoading: isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // رابط تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لديك حساب بالفعل؟'),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(RouteConstants.login),
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

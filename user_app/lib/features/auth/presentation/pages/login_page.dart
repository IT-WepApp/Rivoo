import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_libs/utils/validators.dart';
import '../../application/auth_service.dart';
import '../../../../theme/app_widgets.dart';
import '../../../../core/constants/route_constants.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.signIn(
            _emailController.text, _passwordController.text);

        final authState = ref.read(authStateProvider);
        if (authState.status == AuthStatus.authenticated) {
          if (!mounted) return;

          // التحقق مما إذا كان البريد الإلكتروني مؤكداً
          final authService = ref.read(authServiceProvider);
          final isVerified = await authService.isEmailVerified();

          if (isVerified) {
            context.go(RouteConstants.home);
          } else {
            context.go(RouteConstants.verifyEmail);
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
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
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_cart,
                      size: 120,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // حقل البريد الإلكتروني
                AppWidgets.AppTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // حقل كلمة المرور
                AppWidgets.AppTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                  enabled: !isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),

                const SizedBox(height: 16),

                // تذكرني ونسيت كلمة المرور
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                          },
                          child: const Text('تذكرني'),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(RouteConstants.forgotPassword),
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // زر تسجيل الدخول
                AppWidgets.AppButton(
                  text: 'تسجيل الدخول',
                  onPressed: _login,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 16),

                // رابط إنشاء حساب جديد
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ليس لديك حساب؟'),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(RouteConstants.register),
                      child: const Text('إنشاء حساب جديد'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // أو تسجيل الدخول باستخدام
                if (!isLoading) ...[
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('أو تسجيل الدخول باستخدام'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // أزرار تسجيل الدخول بواسطة وسائل التواصل الاجتماعي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialLoginButton(
                        icon: Icons.g_mobiledata,
                        color: Colors.red,
                        onPressed: () {
                          // تنفيذ تسجيل الدخول بواسطة Google
                        },
                      ),
                      const SizedBox(width: 16),
                      _socialLoginButton(
                        icon: Icons.facebook,
                        color: Colors.blue,
                        onPressed: () {
                          // تنفيذ تسجيل الدخول بواسطة Facebook
                        },
                      ),
                      const SizedBox(width: 16),
                      _socialLoginButton(
                        icon: Icons.apple,
                        color: Colors.black,
                        onPressed: () {
                          // تنفيذ تسجيل الدخول بواسطة Apple
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}

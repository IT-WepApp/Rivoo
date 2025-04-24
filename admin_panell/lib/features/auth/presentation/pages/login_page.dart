import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../admin_router.dart';
import '../../../../core/auth/auth_provider.dart';

/// صفحة تسجيل الدخول للمسؤول
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// تسجيل الدخول
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // التحقق من حالة المصادقة
      final authState = ref.read(authStateProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (mounted) {
          // التنقل إلى الصفحة الرئيسية للمسؤول
          context.go(AdminRoutes.adminHome);
        }
      } else if (authState.status == AuthStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage ?? 'حدث خطأ أثناء تسجيل الدخول'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الدخول: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    // الاستماع لحالة المصادقة
    ref.listen(authStateProvider, (previous, current) {
      if (current.status == AuthStatus.authenticated) {
        // التنقل إلى الصفحة الرئيسية للمسؤول
        context.go(AdminRoutes.adminHome);
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء رأس الصفحة
  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.admin_panel_settings,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'لوحة تحكم المسؤول',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'قم بتسجيل الدخول للوصول إلى لوحة التحكم',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// بناء نموذج تسجيل الدخول
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // حقل البريد الإلكتروني
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              hintText: 'أدخل البريد الإلكتروني',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // حقل كلمة المرور
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              hintText: 'أدخل كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // زر تسجيل الدخول
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),
          // نسيت كلمة المرور
          TextButton(
            onPressed: () {
              // يمكن إضافة منطق استعادة كلمة المرور هنا
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'),
                ),
              );
            },
            child: const Text('نسيت كلمة المرور؟'),
          ),
        ],
      ),
    );
  }
}

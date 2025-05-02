import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';import 'package:shared_libs/utils/validators.dart';import '../../application/auth_service.dart';
import '../../../../theme/app_widgets.dart';
import '../../../../core/constants/route_constants.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.sendPasswordResetEmail(_emailController.text);

        if (!mounted) return;

        setState(() {
          _isSuccess = true;
          _isSubmitting = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('فشل إرسال رابط إعادة تعيين كلمة المرور: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(
            Icons.lock_reset,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 32),
          Text(
            'نسيت كلمة المرور؟',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppWidgets.AppTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.validateEmail,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 32),
          AppWidgets.AppButton(
            text: 'إرسال رابط إعادة التعيين',
            onPressed: _resetPassword,
            isLoading: _isSubmitting,
            icon: const Icon(Icons.send),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed:
                _isSubmitting ? null : () => context.go(RouteConstants.login),
            child: const Text('العودة إلى تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 32),
        Text(
          'تم إرسال رابط إعادة التعيين',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى ${_emailController.text}',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'يرجى التحقق من بريدك الإلكتروني واتباع التعليمات لإعادة تعيين كلمة المرور',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          text: 'العودة إلى تسجيل الدخول',
          onPressed: () => context.go(RouteConstants.login),
          icon: Icons.login,
        ),
      ],
    );
  }
}

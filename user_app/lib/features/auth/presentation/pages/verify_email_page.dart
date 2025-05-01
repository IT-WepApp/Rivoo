import 'package:flutter/material.dart';
import 'package:shared_libs/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;
  int _resendCounter = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCounter = 60;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCounter--;
        });

        if (_resendCounter > 0) {
          _startResendTimer();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isCheckingVerification = true;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.checkEmailVerification();

      final authState = ref.read(authStateProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد البريد الإلكتروني بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        context.go(RouteConstants.home);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'لم يتم تأكيد البريد الإلكتروني بعد، يرجى التحقق من بريدك الإلكتروني'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    setState(() {
      _isResendingEmail = true;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'تم إرسال رابط التأكيد مرة أخرى، يرجى التحقق من بريدك الإلكتروني'),
          backgroundColor: Colors.green,
        ),
      );

      _startResendTimer();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال رابط التأكيد: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final email = user?.email ?? 'بريدك الإلكتروني';

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد البريد الإلكتروني'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_read,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 32),
              Text(
                'تأكيد البريد الإلكتروني',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'لقد أرسلنا رابط تأكيد إلى $email',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى التحقق من بريدك الإلكتروني والنقر على الرابط لتأكيد حسابك',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'لقد قمت بتأكيد بريدي الإلكتروني',
                onPressed: _checkEmailVerification,
                isLoading: _isCheckingVerification,
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 16),
              AppButton(
                text: _canResend
                    ? 'إعادة إرسال رابط التأكيد'
                    : 'إعادة الإرسال بعد $_resendCounter ثانية',
                onPressed: _canResend ? _resendVerificationEmail : null,
                isLoading: _isResendingEmail,
                isOutlined: true,
                icon: Icons.refresh,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  ref.read(authStateProvider.notifier).signOut();
                  context.go(RouteConstants.login);
                },
                child: const Text('العودة إلى تسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:user_app/l10n/app_localizations.dart';
import 'package:user_app/features/payment/domain/entities/payment_method.dart';

/// شاشة نتيجة الدفع
class PaymentResultScreen extends StatelessWidget {
  final bool success;
  final String orderId;
  final String message;
  final VoidCallback? onContinue;

  const PaymentResultScreen({
    Key? key,
    required this.success,
    required this.orderId,
    required this.message,
    this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(success ? 'تم الدفع بنجاح' : 'فشل الدفع'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: success
                      ? colorScheme.primary.withValues(alpha: 26) // 0.1 * 255 = 26
                      : colorScheme.error.withValues(alpha: 26), // 0.1 * 255 = 26
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: success ? colorScheme.primary : colorScheme.error,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                success ? 'تم الدفع بنجاح!' : 'فشل الدفع',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: success ? colorScheme.primary : colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'رقم الطلب: $orderId',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: onContinue ?? () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? colorScheme.primary : colorScheme.surface,
                  foregroundColor: success ? colorScheme.onPrimary : colorScheme.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: success
                        ? BorderSide.none
                        : BorderSide(color: colorScheme.primary),
                  ),
                ),
                child: Text(
                  success ? 'العودة للرئيسية' : 'حاول مرة أخرى',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: success ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

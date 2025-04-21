import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/features/payment/data/payment_model.dart';

/// بطاقة طريقة الدفع
/// تعرض طريقة دفع واحدة مع إمكانية اختيارها
class PaymentMethodCard extends StatelessWidget {
  /// طريقة الدفع
  final PaymentMethod method;

  /// هل الطريقة مختارة
  final bool isSelected;

  /// دالة تنفذ عند النقر على البطاقة
  final VoidCallback onTap;

  /// إنشاء بطاقة طريقة الدفع
  const PaymentMethodCard({
    Key? key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(context),
              const SizedBox(height: 12),
              Text(
                method.getName(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة طريقة الدفع
  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // استخدام أيقونات مخصصة لكل طريقة دفع
    IconData iconData;
    switch (method) {
      case PaymentMethod.creditCard:
        iconData = Icons.credit_card;
        break;
      case PaymentMethod.paypal:
        iconData = Icons.account_balance_wallet;
        break;
      case PaymentMethod.applePay:
        iconData = Icons.apple;
        break;
      case PaymentMethod.googlePay:
        iconData = Icons.g_mobiledata;
        break;
      case PaymentMethod.cashOnDelivery:
        iconData = Icons.money;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: isSelected ? colorScheme.primary : null,
        size: 32,
      ),
    );
  }
}

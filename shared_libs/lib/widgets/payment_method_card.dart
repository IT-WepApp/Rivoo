import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/payment_model.dart';

/// بطاقة طريقة الدفع
///
/// مكون يعرض طريقة دفع مع إمكانية اختيارها
class PaymentMethodCard extends StatelessWidget {
  /// طريقة الدفع
  final PaymentMethod method;
  
  /// هل هذه الطريقة مختارة؟
  final bool isSelected;
  
  /// دالة يتم استدعاؤها عند النقر على البطاقة
  final VoidCallback? onTap;
  
  /// إنشاء بطاقة طريقة دفع
  const PaymentMethodCard({
    Key? key,
    required this.method,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildPaymentMethodIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodName(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (method.description != null && method.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        method.description!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة طريقة الدفع
  Widget _buildPaymentMethodIcon() {
    IconData icon;
    Color color;
    
    switch (method.type) {
      case PaymentMethodType.creditCard:
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentMethodType.debitCard:
        icon = Icons.credit_card;
        color = Colors.green;
        break;
      case PaymentMethodType.paypal:
        icon = Icons.paypal;
        color = Colors.indigo;
        break;
      case PaymentMethodType.applePay:
        icon = Icons.apple;
        color = Colors.black;
        break;
      case PaymentMethodType.googlePay:
        icon = Icons.g_mobiledata;
        color = Colors.deepOrange;
        break;
      case PaymentMethodType.bankTransfer:
        icon = Icons.account_balance;
        color = Colors.teal;
        break;
      case PaymentMethodType.cashOnDelivery:
        icon = Icons.money;
        color = Colors.green.shade700;
        break;
      default:
        icon = Icons.payment;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }

  /// الحصول على اسم طريقة الدفع
  String _getPaymentMethodName() {
    if (method.name != null && method.name!.isNotEmpty) {
      return method.name!;
    }
    
    switch (method.type) {
      case PaymentMethodType.creditCard:
        return 'بطاقة ائتمان';
      case PaymentMethodType.debitCard:
        return 'بطاقة خصم';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethodType.cashOnDelivery:
        return 'الدفع عند الاستلام';
      default:
        return 'طريقة دفع أخرى';
    }
  }
}

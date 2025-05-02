import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/payment_model.dart';

/// ملخص معلومات الدفع
///
/// مكون يعرض ملخص معلومات الدفع مثل المبلغ وطريقة الدفع والرسوم
class PaymentSummary extends StatelessWidget {
  /// معلومات الدفع
  final PaymentModel payment;
  
  /// هل يتم عرض تفاصيل إضافية؟
  final bool showDetails;
  
  /// إنشاء ملخص معلومات الدفع
  const PaymentSummary({
    Key? key,
    required this.payment,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodInfo(),
          const Divider(height: 24),
          _buildAmountDetails(),
          if (showDetails && payment.additionalInfo.isNotEmpty) ...[
            const Divider(height: 24),
            _buildAdditionalInfo(),
          ],
        ],
      ),
    );
  }

  /// بناء معلومات طريقة الدفع
  Widget _buildPaymentMethodInfo() {
    return Row(
      children: [
        _buildPaymentMethodIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getPaymentMethodName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (payment.paymentMethod.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  payment.paymentMethod.description!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// بناء أيقونة طريقة الدفع
  Widget _buildPaymentMethodIcon() {
    IconData icon;
    Color color;
    
    switch (payment.paymentMethod.type) {
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  /// بناء تفاصيل المبلغ
  Widget _buildAmountDetails() {
    return Column(
      children: [
        _buildAmountRow('المبلغ الأساسي', payment.subtotal),
        const SizedBox(height: 8),
        if (payment.discount > 0) ...[
          _buildAmountRow('الخصم', -payment.discount, isDiscount: true),
          const SizedBox(height: 8),
        ],
        if (payment.tax > 0) ...[
          _buildAmountRow('الضريبة', payment.tax),
          const SizedBox(height: 8),
        ],
        if (payment.shippingFee > 0) ...[
          _buildAmountRow('رسوم الشحن', payment.shippingFee),
          const SizedBox(height: 8),
        ],
        if (payment.serviceFee > 0) ...[
          _buildAmountRow('رسوم الخدمة', payment.serviceFee),
          const SizedBox(height: 8),
        ],
        const Divider(),
        _buildAmountRow('المبلغ الإجمالي', payment.total, isTotal: true),
      ],
    );
  }

  /// بناء صف مبلغ
  Widget _buildAmountRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${amount.toStringAsFixed(2)} ر.س',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isDiscount ? Colors.green : (isTotal ? AppTheme.primaryColor : null),
          ),
        ),
      ],
    );
  }

  /// بناء معلومات إضافية
  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات إضافية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...payment.additionalInfo.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// الحصول على اسم طريقة الدفع
  String _getPaymentMethodName() {
    if (payment.paymentMethod.name != null && payment.paymentMethod.name!.isNotEmpty) {
      return payment.paymentMethod.name!;
    }
    
    switch (payment.paymentMethod.type) {
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

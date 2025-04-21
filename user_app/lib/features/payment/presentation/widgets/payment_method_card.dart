import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/features/payment/domain/entities/payment_method.dart';

/// بطاقة طريقة الدفع
class PaymentMethodCard extends StatelessWidget {
  /// طريقة الدفع
  final PaymentMethod paymentMethod;
  
  /// هل هي مختارة
  final bool isSelected;
  
  /// دالة تنفذ عند النقر على البطاقة
  final VoidCallback? onTap;
  
  /// دالة تنفذ عند النقر على زر الحذف
  final VoidCallback? onDelete;

  /// إنشاء بطاقة طريقة دفع
  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // أيقونة طريقة الدفع
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _buildPaymentMethodIcon(),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // تفاصيل طريقة الدفع
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نوع طريقة الدفع
                    Text(
                      _getPaymentMethodTypeText(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // تفاصيل إضافية
                    Text(
                      _getPaymentMethodDetails(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // زر الحذف
              if (onDelete != null) ...[
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
              
              // مؤشر الاختيار
              if (isSelected) ...[
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة طريقة الدفع
  Widget _buildPaymentMethodIcon() {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        return Icon(
          Icons.credit_card,
          color: _getCardBrandColor(),
          size: 28,
        );
      case PaymentMethodType.paypal:
        return const Icon(
          Icons.paypal,
          color: Colors.blue,
          size: 28,
        );
      case PaymentMethodType.applePay:
        return const Icon(
          Icons.apple,
          color: Colors.black,
          size: 28,
        );
      case PaymentMethodType.googlePay:
        return const Icon(
          Icons.g_mobiledata,
          color: Colors.green,
          size: 28,
        );
      case PaymentMethodType.cashOnDelivery:
        return const Icon(
          Icons.money,
          color: Colors.green,
          size: 28,
        );
      default:
        return const Icon(
          Icons.payment,
          color: Colors.grey,
          size: 28,
        );
    }
  }

  /// الحصول على لون العلامة التجارية للبطاقة
  Color _getCardBrandColor() {
    if (paymentMethod.type != PaymentMethodType.creditCard) {
      return Colors.grey;
    }
    
    final cardBrand = paymentMethod.cardBrand;
    if (cardBrand == null) {
      return Colors.grey;
    }
    
    switch (cardBrand) {
      case 'visa':
        return Colors.blue;
      case 'mastercard':
        return Colors.orange;
      case 'amex':
        return Colors.indigo;
      case 'discover':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على نص نوع طريقة الدفع
  String _getPaymentMethodTypeText() {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        final cardBrand = paymentMethod.cardBrand;
        if (cardBrand == null) {
          return 'بطاقة ائتمان';
        }
        
        switch (cardBrand) {
          case 'visa':
            return 'فيزا';
          case 'mastercard':
            return 'ماستركارد';
          case 'amex':
            return 'أمريكان إكسبريس';
          case 'discover':
            return 'ديسكفر';
          default:
            return 'بطاقة ائتمان';
        }
      case PaymentMethodType.paypal:
        return 'باي بال';
      case PaymentMethodType.applePay:
        return 'آبل باي';
      case PaymentMethodType.googlePay:
        return 'جوجل باي';
      case PaymentMethodType.cashOnDelivery:
        return 'الدفع عند الاستلام';
      default:
        return 'طريقة دفع';
    }
  }

  /// الحصول على تفاصيل طريقة الدفع
  String _getPaymentMethodDetails() {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        final last4 = paymentMethod.last4;
        final expMonth = paymentMethod.expMonth;
        final expYear = paymentMethod.expYear;
        
        if (last4 != null && expMonth != null && expYear != null) {
          return 'تنتهي بـ $last4 - تنتهي في $expMonth/$expYear';
        } else if (last4 != null) {
          return 'تنتهي بـ $last4';
        } else {
          return 'بطاقة ائتمان';
        }
      case PaymentMethodType.paypal:
        return paymentMethod.email ?? 'حساب باي بال';
      case PaymentMethodType.applePay:
        return 'الدفع باستخدام آبل باي';
      case PaymentMethodType.googlePay:
        return 'الدفع باستخدام جوجل باي';
      case PaymentMethodType.cashOnDelivery:
        return 'الدفع نقدًا عند استلام الطلب';
      default:
        return '';
    }
  }
}

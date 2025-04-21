import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';

/// ملخص الدفع
class PaymentSummary extends StatelessWidget {
  /// المبلغ الإجمالي
  final double subtotal;
  
  /// رسوم الشحن
  final double shippingFee;
  
  /// الضريبة
  final double tax;
  
  /// الخصم
  final double discount;
  
  /// المبلغ الإجمالي النهائي
  final double total;

  /// إنشاء ملخص الدفع
  const PaymentSummary({
    Key? key,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.discount,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الملخص
          const Text(
            'ملخص الطلب',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // المبلغ الإجمالي
          _buildSummaryRow(
            label: 'المبلغ الإجمالي',
            value: subtotal,
          ),
          
          const SizedBox(height: 8),
          
          // رسوم الشحن
          _buildSummaryRow(
            label: 'رسوم الشحن',
            value: shippingFee,
          ),
          
          const SizedBox(height: 8),
          
          // الضريبة
          _buildSummaryRow(
            label: 'الضريبة',
            value: tax,
          ),
          
          // الخصم (إذا كان موجودًا)
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: 'الخصم',
              value: -discount,
              valueColor: Colors.red,
            ),
          ],
          
          const Divider(height: 24),
          
          // المبلغ الإجمالي النهائي
          _buildSummaryRow(
            label: 'المبلغ الإجمالي',
            value: total,
            isBold: true,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  /// بناء صف في ملخص الدفع
  Widget _buildSummaryRow({
    required String label,
    required double value,
    bool isBold = false,
    double fontSize = 16,
    Color? valueColor,
  }) {
    final fontWeight = isBold ? FontWeight.bold : FontWeight.normal;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        Text(
          '\$${value.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: valueColor ?? AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}

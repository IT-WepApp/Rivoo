import 'package:flutter/material.dart';

class PaymentSummary extends StatelessWidget {
  final double amount;
  final String currency;
  final String orderId;
  final double? tax;
  final double? shipping;

  const PaymentSummary({
    Key? key,
    required this.amount,
    required this.currency,
    required this.orderId,
    this.tax,
    this.shipping,
  }) : super(key: key);

  String _formatCurrency(double value) {
    return '$value $currency';
  }

  @override
  Widget build(BuildContext context) {
    // حساب الضريبة إذا كانت غير محددة
    final calculatedTax = tax ?? (amount * 0.05);
    // حساب رسوم الشحن إذا كانت غير محددة
    final calculatedShipping = shipping ?? 10.0;
    // حساب المجموع الكلي
    final total = amount + calculatedTax + calculatedShipping;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('رقم الطلب', orderId),
          const Divider(height: 24),
          _buildSummaryRow('قيمة المنتجات', _formatCurrency(amount)),
          const SizedBox(height: 8),
          _buildSummaryRow('الضريبة', _formatCurrency(calculatedTax)),
          const SizedBox(height: 8),
          _buildSummaryRow('رسوم الشحن', _formatCurrency(calculatedShipping)),
          const Divider(height: 24),
          _buildSummaryRow(
            'المجموع الكلي',
            _formatCurrency(total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// ملخص الدفع
/// يعرض ملخص الطلب والمبلغ المطلوب دفعه
class PaymentSummary extends StatelessWidget {
  /// معرف الطلب
  final String orderId;
  
  /// المبلغ المطلوب دفعه
  final double amount;
  
  /// العملة
  final String currency;
  
  /// بيانات إضافية
  final Map<String, dynamic>? metadata;

  /// إنشاء ملخص الدفع
  const PaymentSummary({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.currency,
    this.metadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // تنسيق المبلغ حسب العملة
    final formattedAmount = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    ).format(amount);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.orderSummary,
              style: theme.textTheme.headlineSmall,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              label: l10n.orderId,
              value: orderId,
            ),
            const SizedBox(height: 12),
            if (metadata != null && metadata!.containsKey('items')) ...[
              Text(
                l10n.items,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...List.generate(
                (metadata!['items'] as List).length,
                (index) => _buildItemRow(
                  context,
                  item: metadata!['items'][index],
                ),
              ),
              const Divider(height: 24),
            ],
            _buildSummaryRow(
              context,
              label: l10n.subtotal,
              value: formattedAmount,
              isTotal: true,
            ),
            if (metadata != null && metadata!.containsKey('tax')) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                label: l10n.tax,
                value: NumberFormat.currency(
                  symbol: _getCurrencySymbol(currency),
                  decimalDigits: 2,
                ).format(metadata!['tax']),
              ),
            ],
            if (metadata != null && metadata!.containsKey('shipping')) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                label: l10n.shipping,
                value: NumberFormat.currency(
                  symbol: _getCurrencySymbol(currency),
                  decimalDigits: 2,
                ).format(metadata!['shipping']),
              ),
            ],
            if (metadata != null && 
                (metadata!.containsKey('tax') || metadata!.containsKey('shipping'))) ...[
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                label: l10n.total,
                value: NumberFormat.currency(
                  symbol: _getCurrencySymbol(currency),
                  decimalDigits: 2,
                ).format(_calculateTotal()),
                isTotal: true,
                isBold: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// بناء صف في ملخص الدفع
  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.titleMedium,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: isBold ? FontWeight.bold : null,
                )
              : theme.textTheme.titleMedium,
        ),
      ],
    );
  }
  
  /// بناء صف عنصر في ملخص الدفع
  Widget _buildItemRow(
    BuildContext context, {
    required Map<String, dynamic> item,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (item.containsKey('quantity'))
            Text(
              '${item['quantity']}x',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['name'] ?? 'Unknown Item',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (item.containsKey('price'))
            Text(
              NumberFormat.currency(
                symbol: _getCurrencySymbol(currency),
                decimalDigits: 2,
              ).format(item['price']),
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
  
  /// الحصول على رمز العملة
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'EGP':
        return 'ج.م';
      default:
        return currencyCode;
    }
  }
  
  /// حساب المبلغ الإجمالي
  double _calculateTotal() {
    double total = amount;
    
    if (metadata != null) {
      if (metadata!.containsKey('tax')) {
        total += metadata!['tax'] as double;
      }
      
      if (metadata!.containsKey('shipping')) {
        total += metadata!['shipping'] as double;
      }
    }
    
    return total;
  }
}

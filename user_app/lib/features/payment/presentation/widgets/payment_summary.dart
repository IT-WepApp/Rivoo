import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// ملخص الدفع
/// يعرض ملخص الطلب ومعلومات المبلغ وبيانات إضافية مثل العناصر، الضريبة، والشحن
class PaymentSummary extends StatelessWidget {
  /// معرف الطلب
  final String orderId;

  /// المبلغ الفرعي (Subtotal)
  final double amount;

  /// العملة (رمز العملة)
  final String currency;

  /// بيانات إضافية قد تتضمن عناصر، ضريبة، شحن، إلخ
  final Map<String, dynamic>? metadata;

  /// إنشاء ملخص الدفع
  const PaymentSummary({
    Key? key,
    required this.orderId,
    required this.amount,
    this.currency = 'USD',
    this.metadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // تنسيق المبلغ
    final currencyFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    final formattedAmount = currencyFormat.format(amount);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.orderSummary, style: theme.textTheme.headlineSmall),
            const Divider(height: 24),
            _buildRow(context, label: l10n.orderId, value: orderId),
            const SizedBox(height: 8),
            if (metadata?['items'] is List) ...[
              Text(l10n.items, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List<Map<String, dynamic>>.from(metadata!['items']).map(
                (item) => _buildItemRow(context, item, currencyFormat),
              ),
              const Divider(height: 24),
            ],
            _buildRow(context,
                label: l10n.subtotal, value: formattedAmount, isBold: true),
            if (metadata?['tax'] != null) ...[
              const SizedBox(height: 8),
              _buildRow(
                context,
                label: l10n.tax,
                value: currencyFormat.format(metadata!['tax']),
              ),
            ],
            if (metadata?['shipping'] != null) ...[
              const SizedBox(height: 8),
              _buildRow(
                context,
                label: l10n.shipping,
                value: currencyFormat.format(metadata!['shipping']),
              ),
            ],
            if (metadata?['tax'] != null || metadata?['shipping'] != null) ...[
              const Divider(height: 24),
              _buildRow(
                context,
                label: l10n.total,
                value: currencyFormat.format(_calculateTotal()),
                isBold: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isBold
              ? theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    Map<String, dynamic> item,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    final name = item['name'] as String? ?? '';
    final qty = item['quantity']?.toString() ?? '1';
    final price = item['price'] != null ? format.format(item['price']) : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$qty x', style: theme.textTheme.bodyMedium),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Text(price, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = amount;
    if (metadata?['tax'] != null) total += metadata!['tax'] as double;
    if (metadata?['shipping'] != null) total += metadata!['shipping'] as double;
    return total;
  }

  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
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
        return code;
    }
  }
}

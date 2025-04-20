import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/presentation/viewmodels/payment_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';

class PaymentSummary extends ConsumerWidget {
  final int amount;
  final String currency;
  final VoidCallback onProceedToPayment;
  final bool showPayButton;

  const PaymentSummary({
    Key? key,
    required this.amount,
    required this.currency,
    required this.onProceedToPayment,
    this.showPayButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final paymentState = ref.watch(paymentViewModelProvider);
    
    return ResponsiveBuilder(
      mobile: _buildMobileSummary(context, theme, localizations, paymentState),
      tablet: _buildTabletSummary(context, theme, localizations, paymentState),
      desktop: _buildDesktopSummary(context, theme, localizations, paymentState),
    );
  }

  Widget _buildMobileSummary(
    BuildContext context, 
    ThemeData theme, 
    AppLocalizations localizations,
    PaymentState paymentState,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.orderSummary,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              localizations.subtotal,
              _formatCurrency(amount * 0.9, currency),
              theme,
            ),
            const Divider(),
            _buildSummaryItem(
              localizations.tax,
              _formatCurrency(amount * 0.1, currency),
              theme,
            ),
            const Divider(),
            _buildSummaryItem(
              localizations.total,
              _formatCurrency(amount, currency),
              theme,
              isTotal: true,
            ),
            const SizedBox(height: 24),
            if (showPayButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paymentState.selectedPaymentMethod != null
                      ? onProceedToPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(localizations.proceedToPayment),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletSummary(
    BuildContext context, 
    ThemeData theme, 
    AppLocalizations localizations,
    PaymentState paymentState,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.orderSummary,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildSummaryItem(
              localizations.subtotal,
              _formatCurrency(amount * 0.9, currency),
              theme,
              fontSize: 16,
            ),
            const Divider(),
            _buildSummaryItem(
              localizations.tax,
              _formatCurrency(amount * 0.1, currency),
              theme,
              fontSize: 16,
            ),
            const Divider(thickness: 1.5),
            _buildSummaryItem(
              localizations.total,
              _formatCurrency(amount, currency),
              theme,
              isTotal: true,
              fontSize: 18,
            ),
            const SizedBox(height: 32),
            if (showPayButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paymentState.selectedPaymentMethod != null
                      ? onProceedToPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    localizations.proceedToPayment,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSummary(
    BuildContext context, 
    ThemeData theme, 
    AppLocalizations localizations,
    PaymentState paymentState,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.orderSummary,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            _buildSummaryItem(
              localizations.subtotal,
              _formatCurrency(amount * 0.9, currency),
              theme,
              fontSize: 18,
            ),
            const Divider(),
            _buildSummaryItem(
              localizations.tax,
              _formatCurrency(amount * 0.1, currency),
              theme,
              fontSize: 18,
            ),
            const Divider(thickness: 2),
            _buildSummaryItem(
              localizations.total,
              _formatCurrency(amount, currency),
              theme,
              isTotal: true,
              fontSize: 22,
            ),
            const SizedBox(height: 40),
            if (showPayButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paymentState.selectedPaymentMethod != null
                      ? onProceedToPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    localizations.proceedToPayment,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label, 
    String value, 
    ThemeData theme, {
    bool isTotal = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    fontSize: fontSize,
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    fontSize: fontSize,
                  ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(num amount, String currency) {
    // تنسيق المبلغ حسب العملة
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${(amount / 100).toStringAsFixed(2)}';
      case 'EUR':
        return '€${(amount / 100).toStringAsFixed(2)}';
      case 'GBP':
        return '£${(amount / 100).toStringAsFixed(2)}';
      case 'SAR':
        return '${(amount / 100).toStringAsFixed(2)} ر.س';
      case 'AED':
        return '${(amount / 100).toStringAsFixed(2)} د.إ';
      case 'EGP':
        return '${(amount / 100).toStringAsFixed(2)} ج.م';
      default:
        return '${(amount / 100).toStringAsFixed(2)} $currency';
    }
  }
}

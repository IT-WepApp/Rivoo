import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/presentation/viewmodels/payment_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';

class PaymentResultScreen extends ConsumerWidget {
  final String orderId;
  final int amount;
  final String currency;

  const PaymentResultScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final paymentState = ref.watch(paymentViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.paymentResult),
        elevation: 0,
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, theme, localizations, paymentState),
        tablet: _buildTabletLayout(context, theme, localizations, paymentState),
        desktop: _buildDesktopLayout(context, theme, localizations, paymentState),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    PaymentState paymentState,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildResultIcon(paymentState, theme, 80),
            const SizedBox(height: 24),
            _buildResultTitle(paymentState, theme, localizations),
            const SizedBox(height: 16),
            _buildResultMessage(paymentState, theme, localizations),
            const SizedBox(height: 32),
            _buildOrderDetails(theme, localizations),
            const SizedBox(height: 32),
            _buildActionButtons(context, theme, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    PaymentState paymentState,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            _buildResultIcon(paymentState, theme, 120),
            const SizedBox(height: 32),
            _buildResultTitle(paymentState, theme, localizations),
            const SizedBox(height: 24),
            _buildResultMessage(paymentState, theme, localizations),
            const SizedBox(height: 48),
            Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _buildOrderDetails(theme, localizations),
            ),
            const SizedBox(height: 48),
            _buildActionButtons(context, theme, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    PaymentState paymentState,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              _buildResultIcon(paymentState, theme, 150),
              const SizedBox(height: 40),
              _buildResultTitle(paymentState, theme, localizations),
              const SizedBox(height: 24),
              _buildResultMessage(paymentState, theme, localizations),
              const SizedBox(height: 64),
              Container(
                width: 600,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildOrderDetails(theme, localizations),
              ),
              const SizedBox(height: 64),
              _buildActionButtons(context, theme, localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon(PaymentState paymentState, ThemeData theme, double size) {
    final isSuccess = paymentState.paymentResult?.success ?? false;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSuccess
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.error.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          size: size * 0.6,
          color: isSuccess ? theme.colorScheme.primary : theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildResultTitle(PaymentState paymentState, ThemeData theme, AppLocalizations localizations) {
    final isSuccess = paymentState.paymentResult?.success ?? false;
    
    return Text(
      isSuccess ? localizations.paymentSuccessful : localizations.paymentFailed,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: isSuccess ? theme.colorScheme.primary : theme.colorScheme.error,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResultMessage(PaymentState paymentState, ThemeData theme, AppLocalizations localizations) {
    final isSuccess = paymentState.paymentResult?.success ?? false;
    final message = isSuccess
        ? localizations.paymentSuccessMessage
        : paymentState.paymentResult?.errorMessage ?? localizations.paymentFailedMessage;
    
    return Text(
      message,
      style: theme.textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOrderDetails(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.orderDetails,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          localizations.orderId,
          orderId,
          theme,
        ),
        const Divider(),
        _buildDetailRow(
          localizations.amount,
          _formatCurrency(amount, currency),
          theme,
        ),
        const Divider(),
        _buildDetailRow(
          localizations.date,
          _formatDate(DateTime.now()),
          theme,
        ),
        const Divider(),
        _buildDetailRow(
          localizations.paymentMethod,
          _getPaymentMethodName(),
          theme,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge,
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(localizations.backToHome),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/orders');
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(localizations.viewOrders),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodName() {
    // في التطبيق الحقيقي، يجب الحصول على اسم طريقة الدفع من حالة الدفع
    return 'Credit Card';
  }
}

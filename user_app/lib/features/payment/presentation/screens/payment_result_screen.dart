import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/payment/data/payment_model.dart';

/// شاشة نتيجة الدفع
/// تعرض نتيجة عملية الدفع (نجاح/فشل)
class PaymentResultScreen extends StatelessWidget {
  /// بيانات الدفع
  final PaymentModel payment;

  /// إنشاء شاشة نتيجة الدفع
  const PaymentResultScreen({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentResult),
        elevation: 0,
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, l10n),
        tablet: _buildTabletLayout(context, l10n),
        desktop: _buildDesktopLayout(context, l10n),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildResultIcon(context),
          const SizedBox(height: 24),
          _buildResultTitle(context, l10n),
          const SizedBox(height: 16),
          _buildResultMessage(context, l10n),
          const SizedBox(height: 32),
          _buildPaymentDetails(context, l10n),
          const SizedBox(height: 32),
          _buildActionButtons(context, l10n),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildResultIcon(context),
          const SizedBox(height: 32),
          _buildResultTitle(context, l10n),
          const SizedBox(height: 24),
          _buildResultMessage(context, l10n),
          const SizedBox(height: 40),
          _buildPaymentDetails(context, l10n),
          const SizedBox(height: 40),
          _buildActionButtons(context, l10n),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildResultIcon(context),
              const SizedBox(height: 40),
              _buildResultTitle(context, l10n),
              const SizedBox(height: 24),
              _buildResultMessage(context, l10n),
              const SizedBox(height: 48),
              _buildPaymentDetails(context, l10n),
              const SizedBox(height: 48),
              _buildActionButtons(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة نتيجة الدفع
  Widget _buildResultIcon(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final success = _isSuccessful();
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: success ? colorScheme.primary.withOpacity(0.1) : colorScheme.error.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        success ? Icons.check_circle : Icons.error,
        color: success ? colorScheme.primary : colorScheme.error,
        size: 80,
      ),
    );
  }

  /// بناء عنوان النتيجة
  Widget _buildResultTitle(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final color = _isSuccessful() ? theme.colorScheme.primary : theme.colorScheme.error;
    return Text(
      _isSuccessful() ? l10n.paymentSuccessful : l10n.paymentFailed,
      style: theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  /// بناء رسالة النتيجة
  Widget _buildResultMessage(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final message = _isSuccessful()
        ? payment.method == PaymentMethod.cashOnDelivery
            ? l10n.cashOnDeliveryMessage
            : l10n.paymentSuccessMessage
        : payment.errorMessage ?? l10n.paymentFailedMessage;
    return Text(
      message,
      style: theme.textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  /// بناء تفاصيل الدفع
  Widget _buildPaymentDetails(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.paymentDetails, style: theme.textTheme.titleLarge),
            const Divider(height: 24),
            _buildDetailRow(context, label: l10n.orderId, value: payment.orderId),
            const SizedBox(height: 12),
            _buildDetailRow(context, label: l10n.paymentMethod, value: payment.method.getName()),
            const SizedBox(height: 12),
            _buildDetailRow(context, label: l10n.amount, value: '${payment.amount} ${payment.currency}'),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              label: l10n.status,
              value: payment.status.getName(),
              valueColor: _getStatusColor(context),
            ),
            if (payment.transactionId != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(context, label: l10n.transactionId, value: payment.transactionId!),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(context, label: l10n.date, value: _formatDate(payment.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: valueColor, fontWeight: valueColor != null ? FontWeight.bold : null)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), minimumSize: const Size(200, 50)),
          child: Text(l10n.backToHome, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/orders'),
          child: Text(l10n.viewOrders),
        ),
      ],
    );
  }

  bool _isSuccessful() =>
      payment.status == PaymentStatus.completed ||
      (payment.status == PaymentStatus.pending && payment.method == PaymentMethod.cashOnDelivery);

  Color _getStatusColor(BuildContext context) {
    switch (payment.status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ' +
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
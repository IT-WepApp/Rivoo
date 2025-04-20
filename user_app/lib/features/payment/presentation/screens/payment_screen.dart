import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/payment/data/payment_model.dart';
import 'package:user_app/features/payment/application/payment_service.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_method_card.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_summary.dart';
import 'package:user_app/features/payment/presentation/screens/payment_result_screen.dart';

/// شاشة الدفع الرئيسية
/// تعرض ملخص الطلب وطرق الدفع المتاحة وتعالج الدفع عبر Stripe وخدمات أخرى
class PaymentScreen extends ConsumerStatefulWidget {
  /// معرف الطلب
  final String orderId;
  /// المبلغ المطلوبدفعه
  final double amount;
  /// العملة (مثلاً USD)
  final String currency;
  /// بيانات إضافية (اختياري)
  final Map<String, dynamic>? metadata;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    this.currency = 'USD',
    this.metadata,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  /// طريقة الدفع المختارة
  PaymentMethod? _selectedMethod;
  /// حالة معالجة الدفع
  bool _isProcessing = false;
  /// متحكمات نموذج بطاقة الائتمان
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تهيئة خدمات الدفع
    Future.microtask(() => ref.read(paymentServiceProvider).initializeStripe());
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payment),
        elevation: 0,
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobile(context, l10n),
        tablet: _buildTablet(context, l10n),
        desktop: _buildDesktop(context, l10n),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummary(
            orderId: widget.orderId,
            amount: widget.amount,
            currency: widget.currency,
          ),
          const SizedBox(height: 24),
          _buildPaymentMethods(context, l10n),
          if (_selectedMethod == PaymentMethod.creditCard) ...[
            const SizedBox(height: 24),
            _buildCreditCardForm(context, l10n),
          ],
          const SizedBox(height: 24),
          Center(child: _buildPayButton(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildTablet(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummary(
            orderId: widget.orderId,
            amount: widget.amount,
            currency: widget.currency,
          ),
          const SizedBox(height: 32),
          _buildPaymentMethods(context, l10n),
          if (_selectedMethod == PaymentMethod.creditCard) ...[
            const SizedBox(height: 32),
            _buildCreditCardForm(context, l10n),
          ],
          const SizedBox(height: 32),
          Center(child: _buildPayButton(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaymentSummary(
                      orderId: widget.orderId,
                      amount: widget.amount,
                      currency: widget.currency,
                    ),
                    const SizedBox(height: 32),
                    _buildPaymentMethods(context, l10n),
                    if (_selectedMethod == PaymentMethod.creditCard) ...[
                      const SizedBox(height: 32),
                      _buildCreditCardForm(context, l10n),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Center(child: _buildPayButton(context, l10n)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectPaymentMethod, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: PaymentMethod.values.map((method) {
            return PaymentMethodCard(
              method: method,
              isSelected: _selectedMethod == method,
              onTap: () => setState(() => _selectedMethod = method),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreditCardForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cardDetails, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(labelText: l10n.cardNumber, border: const OutlineInputBorder()),
          keyboardType: TextInputType.number,
          maxLength: 19,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _expiryMonthController,
              decoration: InputDecoration(labelText: l10n.expiryMonth, border: const OutlineInputBorder()),
              keyboardType: TextInputType.number,
              maxLength: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _expiryYearController,
              decoration: InputDecoration(labelText: l10n.expiryYear, border: const OutlineInputBorder()),
              keyboardType: TextInputType.number,
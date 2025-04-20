import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/presentation/viewmodels/payment_view_model.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_method_card.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_summary.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int amount;
  final String currency;
  final String orderId;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.currency,
    required this.orderId,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    // تهيئة نموذج العرض عند بدء الشاشة
    Future.microtask(() {
      ref.read(paymentViewModelProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final paymentState = ref.watch(paymentViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.payment),
        elevation: 0,
      ),
      body: paymentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentState.isFailure
              ? _buildErrorView(paymentState.failure?.message ?? localizations.somethingWentWrong)
              : ResponsiveBuilder(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectPaymentMethod,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodsList(paymentState),
            const SizedBox(height: 24),
            PaymentSummary(
              amount: widget.amount,
              currency: widget.currency,
              onProceedToPayment: () => _processPayment(paymentState),
            ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectPaymentMethod,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildPaymentMethodsList(paymentState),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: PaymentSummary(
                    amount: widget.amount,
                    currency: widget.currency,
                    onProceedToPayment: () => _processPayment(paymentState),
                  ),
                ),
              ],
            ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectPaymentMethod,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPaymentMethodsList(paymentState),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: PaymentSummary(
                    amount: widget.amount,
                    currency: widget.currency,
                    onProceedToPayment: () => _processPayment(paymentState),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(PaymentState paymentState) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // دمج طرق الدفع المتاحة والمحفوظة
    final allPaymentMethods = [
      ...paymentState.savedPaymentMethods,
      ...paymentState.availablePaymentMethods.where(
        (method) => !paymentState.savedPaymentMethods.any((saved) => saved.type == method.type),
      ),
    ];
    
    if (allPaymentMethods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.credit_card_off,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noPaymentMethodsAvailable,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allPaymentMethods.length,
      itemBuilder: (context, index) {
        final paymentMethod = allPaymentMethods[index];
        final isSelected = paymentState.selectedPaymentMethod?.id == paymentMethod.id;
        final isSaved = paymentState.savedPaymentMethods.contains(paymentMethod);
        
        return PaymentMethodCard(
          paymentMethod: paymentMethod,
          isSelected: isSelected,
          onTap: () {
            ref.read(paymentViewModelProvider.notifier).selectPaymentMethod(paymentMethod);
          },
          onDelete: isSaved
              ? () {
                  ref.read(paymentViewModelProvider.notifier).deletePaymentMethod(paymentMethod.id);
                }
              : null,
          onSetDefault: isSaved && !paymentMethod.isDefault
              ? () {
                  ref.read(paymentViewModelProvider.notifier).setDefaultPaymentMethod(paymentMethod.id);
                }
              : null,
        );
      },
    );
  }

  Widget _buildErrorView(String errorMessage) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(paymentViewModelProvider.notifier).initialize();
              },
              child: Text(localizations.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(PaymentState paymentState) {
    if (paymentState.selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectPaymentMethod),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    // معالجة الدفع
    ref.read(paymentViewModelProvider.notifier).processPayment(
      amount: widget.amount,
      currency: widget.currency,
      paymentMethodId: paymentState.selectedPaymentMethod!.id,
    );
    
    // الانتقال إلى شاشة نتيجة الدفع
    Navigator.of(context).pushNamed(
      '/payment/result',
      arguments: {
        'orderId': widget.orderId,
        'amount': widget.amount,
        'currency': widget.currency,
      },
    );
  }
}

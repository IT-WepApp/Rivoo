import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/payment/application/payment_service.dart';
import 'package:user_app/features/payment/data/payment_model.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_method_card.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_summary.dart';
import 'package:user_app/features/payment/presentation/screens/payment_result_screen.dart';

/// شاشة الدفع الرئيسية
/// تعرض طرق الدفع المتاحة وملخص الطلب
class PaymentScreen extends ConsumerStatefulWidget {
  /// مسار الشاشة للتوجيه
  static const String routeName = '/payment';

  /// معرف الطلب
  final String orderId;
  
  /// المبلغ المطلوب دفعه
  final double amount;
  
  /// العملة
  final String currency;
  
  /// بيانات إضافية
  final Map<String, dynamic>? metadata;

  /// إنشاء شاشة الدفع
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
  
  /// حالة تحميل الدفع
  bool _isProcessing = false;
  
  /// بيانات بطاقة الائتمان
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // تهيئة Stripe
    _initStripe();
  }
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
  
  /// تهيئة Stripe
  Future<void> _initStripe() async {
    try {
      await ref.read(paymentServiceProvider).initializeStripe();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing payment: ${e.toString()}')),
        );
      }
    }
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
        mobile: _buildMobileLayout(context, l10n),
        tablet: _buildTabletLayout(context, l10n),
        desktop: _buildDesktopLayout(context, l10n),
      ),
    );
  }
  
  /// بناء تخطيط الهاتف المحمول
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
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
          const SizedBox(height: 24),
          if (_selectedMethod == PaymentMethod.creditCard)
            _buildCreditCardForm(context, l10n),
          const SizedBox(height: 24),
          _buildPayButton(context, l10n),
        ],
      ),
    );
  }
  
  /// بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n) {
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
          const SizedBox(height: 32),
          if (_selectedMethod == PaymentMethod.creditCard)
            _buildCreditCardForm(context, l10n),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 300,
              child: _buildPayButton(context, l10n),
            ),
          ),
        ],
      ),
    );
  }
  
  /// بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
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
                    _buildPaymentMethods(context, l10n),
                    const SizedBox(height: 32),
                    if (_selectedMethod == PaymentMethod.creditCard)
                      _buildCreditCardForm(context, l10n),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    PaymentSummary(
                      orderId: widget.orderId,
                      amount: widget.amount,
                      currency: widget.currency,
                    ),
                    const SizedBox(height: 32),
                    _buildPayButton(context, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// بناء قسم طرق الدفع
  Widget _buildPaymentMethods(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectPaymentMethod,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            PaymentMethodCard(
              method: PaymentMethod.creditCard,
              isSelected: _selectedMethod == PaymentMethod.creditCard,
              onTap: () => setState(() => _selectedMethod = PaymentMethod.creditCard),
            ),
            PaymentMethodCard(
              method: PaymentMethod.paypal,
              isSelected: _selectedMethod == PaymentMethod.paypal,
              onTap: () => setState(() => _selectedMethod = PaymentMethod.paypal),
            ),
            PaymentMethodCard(
              method: PaymentMethod.applePay,
              isSelected: _selectedMethod == PaymentMethod.applePay,
              onTap: () => setState(() => _selectedMethod = PaymentMethod.applePay),
            ),
            PaymentMethodCard(
              method: PaymentMethod.googlePay,
              isSelected: _selectedMethod == PaymentMethod.googlePay,
              onTap: () => setState(() => _selectedMethod = PaymentMethod.googlePay),
            ),
            PaymentMethodCard(
              method: PaymentMethod.cashOnDelivery,
              isSelected: _selectedMethod == PaymentMethod.cashOnDelivery,
              onTap: () => setState(() => _selectedMethod = PaymentMethod.cashOnDelivery),
            ),
          ],
        ),
      ],
    );
  }
  
  /// بناء نموذج بطاقة الائتمان
  Widget _buildCreditCardForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cardDetails,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: l10n.cardNumber,
            hintText: '4242 4242 4242 4242',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 19,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonthController,
                decoration: InputDecoration(
                  labelText: l10n.expiryMonth,
                  hintText: '12',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _expiryYearController,
                decoration: InputDecoration(
                  labelText: l10n.expiryYear,
                  hintText: '2025',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvcController,
                decoration: InputDecoration(
                  labelText: l10n.cvc,
                  hintText: '123',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// بناء زر الدفع
  Widget _buildPayButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _selectedMethod == null || _isProcessing ? null : _processPayment,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _isProcessing
          ? const CircularProgressIndicator()
          : Text(
              l10n.payNow,
              style: const TextStyle(fontSize: 18),
            ),
    );
  }
  
  /// معالجة الدفع
  Future<void> _processPayment() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectPaymentMethod)),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final userId = 'current_user_id'; // يجب استبداله بمعرف المستخدم الفعلي
      final paymentService = ref.read(paymentServiceProvider);
      
      // إنشاء دفعة جديدة
      final payment = await paymentService.createPayment(
        userId: userId,
        orderId: widget.orderId,
        amount: widget.amount,
        currency: widget.currency,
        method: _selectedMethod!,
      );
      
      // معالجة الدفع حسب الطريقة المختارة
      PaymentModel result;
      
      switch (_selectedMethod) {
        case PaymentMethod.creditCard:
          if (_validateCreditCardForm()) {
            result = await paymentService.processStripePayment(
              payment: payment,
              cardNumber: _cardNumberController.text,
              expMonth: _expiryMonthController.text,
              expYear: _expiryYearController.text,
              cvc: _cvcController.text,
            );
          } else {
            setState(() => _isProcessing = false);
            return;
          }
          break;
          
        case PaymentMethod.paypal:
          result = await paymentService.processPayPalPayment(payment: payment);
          break;
          
        case PaymentMethod.applePay:
          result = await paymentService.processApplePayPayment(payment: payment);
          break;
          
        case PaymentMethod.googlePay:
          result = await paymentService.processGooglePayPayment(payment: payment);
          break;
          
        case PaymentMethod.cashOnDelivery:
          result = await paymentService.processCashOnDeliveryPayment(payment: payment);
          break;
          
        default:
          throw Exception('Unsupported payment method');
      }
      
      if (mounted) {
        // الانتقال إلى شاشة نتيجة الدفع
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentResultScreen(payment: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing payment: ${e.toString()}')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
  
  /// التحقق من صحة نموذج بطاقة الائتمان
  bool _validateCreditCardForm() {
    if (_cardNumberController.text.isEmpty ||
        _expiryMonthController.text.isEmpty ||
        _expiryYearController.text.isEmpty ||
        _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseCompleteAllFields)),
      );
      return false;
    }
    
    final expiryMonth = int.tryParse(_expiryMonthController.text);
    if (expiryMonth == null || expiryMonth < 1 || expiryMonth > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidExpiryMonth)),
      );
      return false;
    }
    
    final expiryYear = int.tryParse(_expiryYearController.text);
    final currentYear = DateTime.now().year;
    if (expiryYear == null || expiryYear < currentYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidExpiryYear)),
      );
      return false;
    }
    
    return true;
  }
}

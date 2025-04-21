import 'package:flutter/material.dart';
import 'package:user_app/l10n/app_localizations.dart';
import 'package:user_app/features/payment/domain/entities/payment_method.dart';

/// شاشة الدفع
class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailure;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.orderId,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'cc_visa',
      name: 'فيزا',
      icon: 'assets/icons/visa.png',
      isDefault: true,
      type: PaymentMethodType.creditCard,
      details: {
        'cardNumber': '**** **** **** 1234',
        'expiryDate': '12/25',
        'cardHolderName': 'محمد أحمد',
      },
    ),
    PaymentMethod(
      id: 'cc_mastercard',
      name: 'ماستركارد',
      icon: 'assets/icons/mastercard.png',
      type: PaymentMethodType.creditCard,
      details: {
        'cardNumber': '**** **** **** 5678',
        'expiryDate': '10/24',
        'cardHolderName': 'محمد أحمد',
      },
    ),
    PaymentMethod(
      id: 'apple_pay',
      name: 'Apple Pay',
      icon: 'assets/icons/apple_pay.png',
      type: PaymentMethodType.applePay,
    ),
    PaymentMethod(
      id: 'cod',
      name: 'الدفع عند الاستلام',
      icon: 'assets/icons/cash.png',
      type: PaymentMethodType.cashOnDelivery,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // تحديد طريقة الدفع الافتراضية
    _selectedPaymentMethod = _paymentMethods.firstWhere(
      (method) => method.isDefault,
      orElse: () => _paymentMethods.first,
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار طريقة دفع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // محاكاة عملية الدفع
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // محاكاة نجاح الدفع (يمكن تغييرها لمحاكاة الفشل)
      final bool paymentSuccess = true;

      if (paymentSuccess) {
        if (widget.onPaymentSuccess != null) {
          widget.onPaymentSuccess!();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentResultScreen(
                success: true,
                orderId: widget.orderId,
                message: 'تم الدفع بنجاح وسيتم شحن طلبك قريبًا.',
              ),
            ),
          );
        }
      } else {
        if (widget.onPaymentFailure != null) {
          widget.onPaymentFailure!();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentResultScreen(
                success: false,
                orderId: widget.orderId,
                message: 'فشلت عملية الدفع. الرجاء المحاولة مرة أخرى أو اختيار طريقة دفع أخرى.',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري معالجة الدفع...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر طريقة الدفع',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      final isSelected = _selectedPaymentMethod?.id == method.id;
                      
                      return PaymentMethodCard(
                        paymentMethod: method,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  PaymentSummary(
                    totalAmount: widget.totalAmount,
                    orderId: widget.orderId,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إتمام الدفع',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// استيراد الواجهات المطلوبة
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تنفيذ مؤقت
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.payment, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (paymentMethod.details != null && 
                        paymentMethod.details!.containsKey('cardNumber'))
                      Text(
                        paymentMethod.details!['cardNumber'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSummary extends StatelessWidget {
  final double totalAmount;
  final String orderId;

  const PaymentSummary({
    Key? key,
    required this.totalAmount,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تنفيذ مؤقت
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الدفع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رقم الطلب:'),
                Text(orderId),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المبلغ الإجمالي:'),
                Text(
                  '$totalAmount ريال',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// استيراد شاشة نتيجة الدفع
class PaymentResultScreen extends StatelessWidget {
  final bool success;
  final String orderId;
  final String message;

  const PaymentResultScreen({
    Key? key,
    required this.success,
    required this.orderId,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تنفيذ مؤقت - سيتم استبداله بالاستيراد الفعلي
    return Scaffold(
      appBar: AppBar(
        title: Text(success ? 'تم الدفع بنجاح' : 'فشل الدفع'),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String orderId;
  final double amount;
  final String currency;
  final String? errorMessage;

  const PaymentResultScreen({
    Key? key,
    required this.isSuccess,
    required this.orderId,
    required this.amount,
    required this.currency,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSuccess ? 'تم الدفع بنجاح' : 'فشل في الدفع'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة النجاح أو الفشل
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              
              // عنوان النتيجة
              Text(
                isSuccess ? 'تمت عملية الدفع بنجاح!' : 'فشل في إتمام عملية الدفع',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // تفاصيل الطلب
              if (isSuccess) ...[
                Text(
                  'رقم الطلب: $orderId',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'المبلغ: $amount $currency',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                const Text(
                  'شكراً لك! سيتم تجهيز طلبك في أقرب وقت.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // رسالة الخطأ
                Text(
                  errorMessage ?? 'حدث خطأ أثناء معالجة الدفع. يرجى المحاولة مرة أخرى.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 48),
              
              // زر العودة أو إعادة المحاولة
              ElevatedButton(
                onPressed: () {
                  if (isSuccess) {
                    // العودة إلى الصفحة الرئيسية أو صفحة الطلبات
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    // العودة إلى صفحة الدفع
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isSuccess ? 'العودة للرئيسية' : 'إعادة المحاولة',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

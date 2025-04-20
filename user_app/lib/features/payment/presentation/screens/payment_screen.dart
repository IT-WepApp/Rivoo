import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/payment/application/payment_service.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_method_card.dart';
import 'package:user_app/features/payment/presentation/widgets/payment_summary.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String currency;
  final String orderId;

  const PaymentScreen({
    Key? key,
    required this.amount,
    this.currency = 'USD',
    required this.orderId,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // تهيئة خدمة الدفع
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentServiceProvider).initStripe();
    });
  }

  // معالجة الدفع
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // استخدام واجهة Stripe الجاهزة للدفع
      await ref.read(paymentServiceProvider).processPaymentWithUI(
            widget.amount,
            widget.currency,
          );

      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت عملية الدفع بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        // العودة إلى الشاشة السابقة مع إرجاع نتيجة نجاح
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في عملية الدفع: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // استخدام الدفع الوهمي (للاختبار)
  Future<void> _processMockPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 2));

      // إنشاء دفع وهمي
      await ref.read(paymentServiceProvider).mockPayment(
            widget.amount,
            widget.currency,
          );

      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت عملية الدفع بنجاح! (وضع المحاكاة)'),
            backgroundColor: Colors.green,
          ),
        );

        // العودة إلى الشاشة السابقة مع إرجاع نتيجة نجاح
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في عملية الدفع: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ملخص الدفع
              PaymentSummary(
                amount: widget.amount,
                currency: widget.currency,
                orderId: widget.orderId,
              ),
              
              const SizedBox(height: 24),
              
              // عنوان طرق الدفع
              const Text(
                'اختر طريقة الدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // بطاقات طرق الدفع
              PaymentMethodCard(
                title: 'الدفع ببطاقة الائتمان',
                subtitle: 'Visa, Mastercard, American Express',
                icon: Icons.credit_card,
                onTap: _processPayment,
              ),
              
              const SizedBox(height: 12),
              
              PaymentMethodCard(
                title: 'Apple Pay',
                subtitle: 'الدفع السريع باستخدام Apple Pay',
                icon: Icons.apple,
                onTap: _processPayment,
              ),
              
              const SizedBox(height: 12),
              
              PaymentMethodCard(
                title: 'الدفع عند الاستلام',
                subtitle: 'الدفع نقداً عند استلام الطلب',
                icon: Icons.attach_money,
                onTap: _processMockPayment,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isProcessing
          ? Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

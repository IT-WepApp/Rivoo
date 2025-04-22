import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/payment_model.dart';
import '../widgets/payment_summary.dart';

/// شاشة نتيجة عملية الدفع
///
/// تعرض هذه الشاشة نتيجة عملية الدفع (نجاح أو فشل)
/// وتوفر خيارات للمستخدم مثل العودة للتسوق أو عرض تفاصيل الطلب
class PaymentResultScreen extends ConsumerWidget {
  /// معرف الطلب
  final String orderId;
  
  /// حالة الدفع
  final PaymentStatus status;
  
  /// رسالة إضافية (اختيارية)
  final String? message;
  
  /// معلومات الدفع
  final PaymentModel? paymentInfo;

  /// إنشاء شاشة نتيجة الدفع
  const PaymentResultScreen({
    Key? key,
    required this.orderId,
    required this.status,
    this.message,
    this.paymentInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الدفع'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildStatusIcon(),
                      const SizedBox(height: 24),
                      _buildStatusTitle(),
                      const SizedBox(height: 16),
                      _buildStatusMessage(),
                      const SizedBox(height: 24),
                      _buildOrderInfo(),
                      const SizedBox(height: 24),
                      if (paymentInfo != null) ...[
                        PaymentSummary(payment: paymentInfo!),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة الحالة (نجاح أو فشل)
  Widget _buildStatusIcon() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: status == PaymentStatus.success
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Icon(
        status == PaymentStatus.success ? Icons.check_circle : Icons.error,
        size: 70,
        color: status == PaymentStatus.success ? Colors.green : Colors.red,
      ),
    );
  }

  /// بناء عنوان الحالة
  Widget _buildStatusTitle() {
    return Text(
      status == PaymentStatus.success
          ? 'تمت عملية الدفع بنجاح'
          : 'فشلت عملية الدفع',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// بناء رسالة الحالة
  Widget _buildStatusMessage() {
    String displayMessage = message ?? '';
    
    if (displayMessage.isEmpty) {
      displayMessage = status == PaymentStatus.success
          ? 'تم استلام طلبك وسيتم معالجته في أقرب وقت ممكن.'
          : 'حدث خطأ أثناء معالجة الدفع. يرجى المحاولة مرة أخرى أو استخدام طريقة دفع أخرى.';
    }
    
    return Text(
      displayMessage,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// بناء معلومات الطلب
  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'رقم الطلب:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تاريخ الطلب:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateTime.now().toString().substring(0, 16),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'حالة الدفع:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == PaymentStatus.success
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == PaymentStatus.success ? 'مدفوع' : 'فشل الدفع',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: status == PaymentStatus.success
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء أزرار الإجراءات
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (status == PaymentStatus.success)
          AppButton(
            text: 'عرض تفاصيل الطلب',
            onPressed: () {
              // التنقل إلى صفحة تفاصيل الطلب
              Navigator.pop(context, {'action': 'view_order', 'orderId': orderId});
            },
          )
        else
          AppButton(
            text: 'إعادة المحاولة',
            onPressed: () {
              // العودة إلى صفحة الدفع
              Navigator.pop(context, {'action': 'retry'});
            },
          ),
        const SizedBox(height: 16),
        AppButton(
          text: 'العودة للتسوق',
          onPressed: () {
            // العودة إلى الصفحة الرئيسية
            Navigator.pop(context, {'action': 'home'});
          },
          backgroundColor: Colors.white,
          textColor: AppTheme.primaryColor,
          borderColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}

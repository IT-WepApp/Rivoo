import 'package:flutter/material.dart';
import 'package:user_app/l10n/app_localizations.dart';
import 'package:shared_libs/models/order.dart';

/// صفحة تتبع الطلب
class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  bool _isLoading = true;
  Order? _order;
  List<TrackingStep> _trackingSteps = [];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    // محاكاة تحميل بيانات الطلب
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _order = Order(
          id: widget.orderId,
          userId: 'user123',
          items: [
            OrderItem(
              id: 'item1',
              productId: 'prod1',
              productName: 'هاتف ذكي',
              productImage: 'https://example.com/phone.jpg',
              price: 1200,
              quantity: 1,
              totalPrice: 1200,
            ),
          ],
          shippingAddress: 'شارع الملك فهد، الرياض، المملكة العربية السعودية',
          paymentMethod: 'بطاقة ائتمان',
          totalAmount: 1250,
          status: 'قيد التوصيل',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        
        _trackingSteps = [
          TrackingStep(
            title: 'تم استلام الطلب',
            description: 'تم استلام طلبك وهو قيد المعالجة',
            date: DateTime.now().subtract(const Duration(days: 2)),
            isCompleted: true,
          ),
          TrackingStep(
            title: 'تم تأكيد الطلب',
            description: 'تم تأكيد طلبك وتجهيزه للشحن',
            date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
            isCompleted: true,
          ),
          TrackingStep(
            title: 'قيد الشحن',
            description: 'تم شحن طلبك وهو في الطريق إليك',
            date: DateTime.now().subtract(const Duration(hours: 6)),
            isCompleted: true,
          ),
          TrackingStep(
            title: 'قيد التوصيل',
            description: 'طلبك مع مندوب التوصيل وسيصل إليك قريبًا',
            date: DateTime.now(),
            isCompleted: true,
          ),
          TrackingStep(
            title: 'تم التسليم',
            description: 'تم تسليم طلبك بنجاح',
            date: null,
            isCompleted: false,
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(
                  child: Text(
                    'لا يمكن العثور على الطلب',
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderInfoCard(theme),
                      const SizedBox(height: 24),
                      Text(
                        'مسار التتبع',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTrackingTimeline(theme),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رقم الطلب: ${_order!.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(theme).withValues(alpha: 26), // 0.1 * 255 = 26
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _order!.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(theme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'تاريخ الطلب: ${_formatDate(_order!.createdAt)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'طريقة الدفع: ${_order!.paymentMethod}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'المبلغ الإجمالي: ${_order!.totalAmount} ريال',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عنوان التوصيل:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _order!.shippingAddress,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _trackingSteps.length,
      itemBuilder: (context, index) {
        final step = _trackingSteps[index];
        final isLast = index == _trackingSteps.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                    border: Border.all(
                      color: step.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: step.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: step.isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: step.isCompleted
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 153), // 0.6 * 255 = 153
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 153), // 0.6 * 255 = 153
                    ),
                  ),
                  if (step.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatDateTime(step.date!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 128), // 0.5 * 255 = 128
                        ),
                      ),
                    ),
                  if (!isLast) const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (_order!.status) {
      case 'قيد المعالجة':
        return Colors.blue;
      case 'قيد التوصيل':
        return Colors.orange;
      case 'تم التسليم':
        return Colors.green;
      case 'ملغي':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// خطوة في مسار تتبع الطلب
class TrackingStep {
  final String title;
  final String description;
  final DateTime? date;
  final bool isCompleted;

  TrackingStep({
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
  });
}

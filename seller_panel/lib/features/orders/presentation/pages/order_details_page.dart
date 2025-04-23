import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../../../shared_libs/lib/theme/app_colors.dart';

/// صفحة تفاصيل الطلب للبائع
class OrderDetailsPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  Map<String, dynamic>? _orderData;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      final orderData = await orderService.getOrderDetails(widget.orderId);

      setState(() {
        _orderData = orderData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل تفاصيل الطلب: $e';
      });
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(widget.orderId, newStatus);

      // تحديث البيانات المحلية
      setState(() {
        if (_orderData != null) {
          _orderData!['status'] = newStatus;
        }
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث حالة الطلب إلى "$newStatus" بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث حالة الطلب: $e';
      });
    }
  }

  Future<void> _cancelOrder() async {
    if (mounted) {
      final confirmed = await AppWidgets.showConfirmDialog(
        context: context,
        title: 'إلغاء الطلب',
        message:
            'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.',
        confirmText: 'إلغاء الطلب',
        cancelText: 'تراجع',
        isDangerous: true,
      );

      if (!confirmed) {
        return;
      }
    } else {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(widget.orderId, 'ملغي');

      // تحديث البيانات المحلية
      setState(() {
        if (_orderData != null) {
          _orderData!['status'] = 'ملغي';
        }
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الطلب بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل إلغاء الطلب: $e';
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديد':
        return AppColors.info;
      case 'قيد التحضير':
        return AppColors.warning;
      case 'جاهز للتسليم':
        return AppColors.secondary;
      case 'قيد التوصيل':
        return AppColors.orderDelivering;
      case 'تم التسليم':
        return AppColors.success;
      case 'ملغي':
        return AppColors.error;
      default:
        return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'تفاصيل الطلب ${_orderData != null ? '#${_orderData!['orderNumber']}' : ''}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrderDetails,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل تفاصيل الطلب...')
          : _isSubmitting
              ? AppWidgets.loadingIndicator(message: 'جاري تنفيذ العملية...')
              : _errorMessage.isNotEmpty && _orderData == null
                  ? AppWidgets.errorMessage(
                      message: _errorMessage,
                      onRetry: _loadOrderDetails,
                    )
                  : _orderData == null
                      ? AppWidgets.errorMessage(
                          message: 'لم يتم العثور على الطلب',
                          onRetry: _loadOrderDetails,
                        )
                      : _buildOrderDetails(theme),
    );
  }

  Widget _buildOrderDetails(ThemeData theme) {
    final order = _orderData!;
    final orderNumber = order['orderNumber'] as String? ?? 'بدون رقم';
    final customerName = order['customerName'] as String? ?? 'عميل';
    final customerPhone = order['customerPhone'] as String? ?? '';
    final orderDate = order['orderDate'] as DateTime? ?? DateTime.now();
    final totalAmount = order['totalAmount'] as num? ?? 0;
    final status = order['status'] as String? ?? 'جديد';
    final items = order['items'] as List<dynamic>? ?? [];
    final shippingAddress =
        order['shippingAddress'] as Map<String, dynamic>? ?? {};
    final paymentMethod =
        order['paymentMethod'] as String? ?? 'الدفع عند الاستلام';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقة معلومات الطلب
        AppWidgets.appCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان البطاقة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'معلومات الطلب',
                    style: theme.textTheme.titleLarge,
                  ),

                  // حالة الطلب
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(status),
                      ),
                    ),
                    child: Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // معلومات الطلب
              _buildInfoRow(theme, 'رقم الطلب', '#$orderNumber'),
              const SizedBox(height: 8),
              _buildInfoRow(theme, 'تاريخ الطلب',
                  '${orderDate.day}/${orderDate.month}/${orderDate.year} - ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}'),
              const SizedBox(height: 8),
              _buildInfoRow(theme, 'طريقة الدفع', paymentMethod),
              const SizedBox(height: 8),
              _buildInfoRow(theme, 'المبلغ الإجمالي',
                  '${totalAmount.toStringAsFixed(2)} ر.س'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // بطاقة معلومات العميل
        AppWidgets.appCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات العميل',
                style: theme.textTheme.titleLarge,
              ),
              const Divider(height: 24),

              // معلومات العميل
              _buildInfoRow(theme, 'الاسم', customerName),
              if (customerPhone.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(theme, 'رقم الهاتف', customerPhone),
              ],

              // عنوان الشحن
              if (shippingAddress.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'عنوان الشحن',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildAddressCard(theme, shippingAddress),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // بطاقة عناصر الطلب
        AppWidgets.appCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عناصر الطلب',
                style: theme.textTheme.titleLarge,
              ),
              const Divider(height: 24),

              // قائمة العناصر
              if (items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('لا توجد عناصر في هذا الطلب'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = items[index] as Map<String, dynamic>;
                    final productName =
                        item['productName'] as String? ?? 'منتج';
                    final quantity = item['quantity'] as int? ?? 1;
                    final price = item['price'] as num? ?? 0;
                    final totalPrice = item['totalPrice'] as num? ?? 0;
                    final imageUrl = item['imageUrl'] as String? ?? '';

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صورة المنتج
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.background,
                                  child: const Icon(Icons.image_not_supported,
                                      color: AppColors.textSecondary),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image,
                                color: AppColors.textSecondary),
                          ),
                        const SizedBox(width: 16),

                        // معلومات المنتج
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'السعر: ${price.toStringAsFixed(2)} ر.س',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الكمية: $quantity',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        // السعر الإجمالي
                        Text(
                          '${totalPrice.toStringAsFixed(2)} ر.س',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),

              // ملخص الأسعار
              const Divider(height: 32),
              _buildPriceSummary(theme, order),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // رسالة الخطأ
        if (_errorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: AppColors.error),
            ),
          ),

        // أزرار التحكم
        _buildActionButtons(theme, status),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(ThemeData theme, Map<String, dynamic> address) {
    final street = address['street'] as String? ?? '';
    final city = address['city'] as String? ?? '';
    final state = address['state'] as String? ?? '';
    final postalCode = address['postalCode'] as String? ?? '';
    final country = address['country'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (street.isNotEmpty)
            Text(street, style: theme.textTheme.bodyMedium),
          if (city.isNotEmpty || state.isNotEmpty)
            Text(
              [city, state].where((s) => s.isNotEmpty).join(', '),
              style: theme.textTheme.bodyMedium,
            ),
          if (postalCode.isNotEmpty || country.isNotEmpty)
            Text(
              [postalCode, country].where((s) => s.isNotEmpty).join(', '),
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(ThemeData theme, Map<String, dynamic> order) {
    final subtotal = order['subtotal'] as num? ?? 0;
    final shippingFee = order['shippingFee'] as num? ?? 0;
    final tax = order['tax'] as num? ?? 0;
    final discount = order['discount'] as num? ?? 0;
    final totalAmount = order['totalAmount'] as num? ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المجموع الفرعي:',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${subtotal.toStringAsFixed(2)} ر.س',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (shippingFee > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رسوم الشحن:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${shippingFee.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (tax > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الضريبة:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${tax.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (discount > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخصم:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '- ${discount.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المجموع:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${totalAmount.toStringAsFixed(2)} ر.س',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, String status) {
    // لا نعرض أزرار التحكم للطلبات المكتملة أو الملغاة
    if (status == 'تم التسليم' || status == 'ملغي') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // زر تحديث الحالة
        if (status != 'تم التسليم' && status != 'ملغي') ...[
          AppWidgets.appButton(
            text: _getNextStatusButtonText(status),
            onPressed: () => _updateOrderStatus(_getNextStatus(status)),
            backgroundColor: AppColors.primary,
            textColor: AppColors.onPrimary,
            icon: Icons.update,
          ),
          const SizedBox(height: 12),
        ],

        // زر إلغاء الطلب
        if (status != 'تم التسليم' && status != 'ملغي')
          AppWidgets.appButton(
            text: 'إلغاء الطلب',
            onPressed: _cancelOrder,
            backgroundColor: AppColors.error,
            textColor: AppColors.onError,
            icon: Icons.cancel,
          ),
      ],
    );
  }

  String _getNextStatusButtonText(String currentStatus) {
    switch (currentStatus) {
      case 'جديد':
        return 'بدء تحضير الطلب';
      case 'قيد التحضير':
        return 'تحديد الطلب كجاهز للتسليم';
      case 'جاهز للتسليم':
        return 'تحديد الطلب كقيد التوصيل';
      case 'قيد التوصيل':
        return 'تأكيد تسليم الطلب';
      default:
        return 'تحديث حالة الطلب';
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'جديد':
        return 'قيد التحضير';
      case 'قيد التحضير':
        return 'جاهز للتسليم';
      case 'جاهز للتسليم':
        return 'قيد التوصيل';
      case 'قيد التوصيل':
        return 'تم التسليم';
      default:
        return currentStatus;
    }
  }
}

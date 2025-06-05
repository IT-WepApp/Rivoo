import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart';
import 'package:shared_libs/services/services.dart';
import 'package:shared_libs/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:user_app/features/cart/providers/cart_notifier.dart';
import 'package:go_router/go_router.dart';

// مزود يجلب تفاصيل طلب محدد
final orderDetailsProvider =
    FutureProvider.autoDispose.family<OrderModel?, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderDetails(orderId);
});

class OrderDetailsPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderDetailsAsyncValue = ref.watch(orderDetailsProvider(orderId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: orderDetailsAsyncValue.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('لم يتم العثور على الطلب.'));
          }

          // تنسيق التاريخ
          final DateTime orderDate = order.createdAt.toDate();
          final formattedDate =
              DateFormat('yyyy-MM-dd HH:mm').format(orderDate);
          final products = order.products;
          final totalPrice = order.total;
          final status = order.status;
          final isDelivered = status.toLowerCase() == 'delivered';
          final isCancelled = status.toLowerCase() == 'cancelled';
          final isOutForDelivery = status.toLowerCase() == 'out_for_delivery' ||
              status.toLowerCase() == 'out for delivery';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // بطاقة معلومات الطلب
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('رقم الطلب: ${order.id.substring(0, 8)}',
                              style: theme.textTheme.titleMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text('تاريخ الطلب: $formattedDate'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('عنوان التوصيل: ${order.address}'),
                          ),
                        ],
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.note, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('ملاحظات: ${order.notes}'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // بطاقة المنتجات
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المنتجات المطلوبة',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      // التحقق من وجود منتجات
                      if (products.isEmpty)
                        const Text('لا توجد تفاصيل منتجات متاحة.')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: product.imageUrl != null &&
                                        product.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) =>
                                              const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.fastfood,
                                        color: Colors.grey),
                              ),
                              title: Text(product.name),
                              subtitle: Text('الكمية: ${product.quantity}'),
                              trailing: Text(
                                '${(product.price * product.quantity).toStringAsFixed(2)} ريال',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // بطاقة ملخص السعر
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المجموع الفرعي:'),
                          Text(
                              '${(totalPrice - 15.0 - (totalPrice * 0.15)).toStringAsFixed(2)} ريال'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('رسوم التوصيل:'),
                          Text('15.00 ريال'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الضريبة (15%):'),
                          Text(
                              '${(totalPrice * 0.15).toStringAsFixed(2)} ريال'),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المجموع الكلي:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} ريال',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // أزرار الإجراءات
              Row(
                children: [
                  if (isOutForDelivery)
                    Expanded(
                      child: AppButton(
                        text: 'تتبع الطلب',
                        icon: Icons.location_on,
                        onPressed: () {
                          context.goNamed('order-tracking',
                              pathParameters: {'orderId': order.id});
                        },
                      ),
                    ),
                  if (isDelivered)
                    Expanded(
                      child: AppButton(
                        text: 'إعادة الطلب',
                        icon: Icons.replay,
                        onPressed: () {
                          _reorderItems(context, ref, order);
                        },
                      ),
                    ),
                  if (!isDelivered && !isCancelled && !isOutForDelivery)
                    Expanded(
                      child: AppButton(
                        text: 'إلغاء الطلب',
                        icon: Icons.cancel,
                        backgroundColor: Colors.red,
                        onPressed: () {
                          _showCancelDialog(context);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isDelivered)
                AppButton(
                  text: 'تقييم المنتجات والمندوب',
                  icon: Icons.star,
                  backgroundColor: Colors.amber,
                  onPressed: () {
                    _showRatingDialog(context, order);
                  },
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('حدث خطأ أثناء تحميل تفاصيل الطلب: $error'),
              const SizedBox(height: 16),
              AppButton(
                text: 'إعادة المحاولة',
                onPressed: () => ref.refresh(orderDetailsProvider(orderId)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reorderItems(BuildContext context, WidgetRef ref, OrderModel order) {
    // إضافة منتجات الطلب إلى سلة التسوق
    final cartNotifier = ref.read(cartProvider.notifier);

    // مسح السلة الحالية قبل إضافة المنتجات الجديدة
    cartNotifier.clearCart();

    // إضافة كل منتج من الطلب السابق إلى السلة
    for (final product in order.products) {
      // تحويل OrderProductItem إلى Product
      final productToAdd = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        description: '',
        imageUrl: product.imageUrl,
        categoryId: '',
        storeId: '',
      );

      // إضافة المنتج إلى السلة بنفس الكمية
      cartNotifier.addItem(productToAdd, quantity: product.quantity);
    }

    // عرض رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة منتجات الطلب السابق إلى السلة'),
        duration: Duration(seconds: 2),
      ),
    );

    // الانتقال إلى صفحة السلة
    context.go('/cart');
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // تنفيذ إلغاء الطلب (سيتم تنفيذه لاحقاً)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب الإلغاء، سيتم مراجعته قريباً'),
                ),
              );
            },
            child: const Text('تأكيد الإلغاء',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تقييم الطلب'),
        content: const Text('سيتم تنفيذ هذه الميزة في المرحلة القادمة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة للحصول على لون الحالة
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
      case 'accepted':
        return Colors.blue;
      case 'shipped':
      case 'out_for_delivery':
      case 'out for delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'accepted':
        return 'تم قبول الطلب';
      case 'shipped':
        return 'تم الشحن';
      case 'out_for_delivery':
      case 'out for delivery':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

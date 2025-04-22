import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/lib/widgets/shared_widgets.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/features/orders/application/orders_notifier.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';

class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(userOrdersProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () {
              ref.invalidate(userOrdersProvider);
            },
          ),
        ],
      ),
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            final userId = ref.watch(userIdProvider);
            if (userId == null) {
              return const Center(
                  child: Text('يرجى تسجيل الدخول لعرض طلباتك.'));
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text("لم تقم بإجراء أي طلبات بعد.",
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'تصفح المنتجات',
                      onPressed: () => context.go('/home'),
                      icon: Icons.shopping_cart,
                    ),
                  ],
                ),
              );
            }
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userOrdersProvider);
              await Future.delayed(const Duration(
                  milliseconds: 500)); // لإظهار الأنيميشن بشكل طبيعي
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final DateTime orderDate = order.createdAt.toDate();
                final formattedDate =
                    DateFormat('yyyy-MM-dd HH:mm').format(orderDate);
                final totalPrice = order.total;
                final status = order.status;
                final isDelivered = status.toLowerCase() == 'delivered';
                final isCancelled = status.toLowerCase() == 'cancelled';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    child: InkWell(
                      onTap: () {
                        context.goNamed('order-details',
                            pathParameters: {'orderId': order.id});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'طلب #${order.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
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
                                const Icon(Icons.shopping_bag, size: 16),
                                const SizedBox(width: 8),
                                Text('عدد المنتجات: ${order.products.length}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                    'المجموع: ${totalPrice.toStringAsFixed(2)} ريال'),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.info_outline),
                                    label: const Text('التفاصيل'),
                                    onPressed: () {
                                      context.goNamed('order-details',
                                          pathParameters: {
                                            'orderId': order.id
                                          });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!isCancelled && !isDelivered)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.location_on),
                                      label: const Text('تتبع'),
                                      onPressed: () {
                                        context.goNamed('order-tracking',
                                            pathParameters: {
                                              'orderId': order.id
                                            });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        foregroundColor: Colors.purple,
                                      ),
                                    ),
                                  ),
                                if (isDelivered)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.replay),
                                      label: const Text('إعادة الطلب'),
                                      onPressed: () {
                                        _reorderItems(context, ref, order);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        backgroundColor: primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('حدث خطأ أثناء تحميل الطلبات: $error'),
                const SizedBox(height: 16),
                AppButton(
                  text: 'إعادة المحاولة',
                  onPressed: () => ref.invalidate(userOrdersProvider),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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

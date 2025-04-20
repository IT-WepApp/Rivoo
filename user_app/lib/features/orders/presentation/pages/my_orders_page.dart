import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:shared_widgets/shared_widgets.dart'; 
import 'package:intl/intl.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:user_app/features/orders/application/orders_notifier.dart'; 
import 'package:user_app/features/auth/application/auth_notifier.dart'; 
// Still needed for OrderModel in ordersAsyncValue

class MyOrdersPage extends ConsumerWidget { 
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final ordersAsyncValue = ref.watch(userOrdersProvider);
    final primaryColor = Theme.of(context).colorScheme.primary; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: primaryColor, 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
              return const Center(child: Text('Please log in to view your orders.'));
            } else {
              return const Center(child: Text("You haven't placed any orders yet.")); 
            }
          }
          return RefreshIndicator( 
            onRefresh: () async {
              ref.invalidate(userOrdersProvider);
              await Future.delayed(const Duration(milliseconds: 500)); // لإظهار الأنيميشن بشكل طبيعي
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final DateTime orderDate = order.createdAt.toDate(); 
                final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(orderDate);
                final totalPrice = order.total;
                final status = order.status;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      context.goNamed('order-details', pathParameters: {'orderId': order.id});
                    },
                    child: AppCard(
                      child: ListTile(
                        leading: Icon(Icons.receipt_long, color: primaryColor, size: 40),
                        title: Text('Order Date: $formattedDate'),
                        subtitle: Text(
                          'Total: \$${totalPrice.toStringAsFixed(2)}\nStatus: $status',
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        isThreeLine: true,
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
                Text('Error loading orders: $error'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userOrdersProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing':
      case 'accepted': return Colors.blue;
      case 'shipped':
      case 'out_for_delivery': 
      case 'out for delivery': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

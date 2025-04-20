import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:shared_models/shared_models.dart'; // Updated import
import 'package:shared_services/shared_services.dart'; // Updated import
import 'package:shared_widgets/shared_widgets.dart'; // Updated import
import 'package:intl/intl.dart'; // Keep for date formatting

// Define a provider that fetches details for a specific order ID
final orderDetailsProvider = FutureProvider.autoDispose.family<OrderModel?, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderDetails(orderId);
});

class OrderDetailsPage extends ConsumerWidget { // Changed to ConsumerWidget
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderDetailsAsyncValue = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'), // Updated title
        backgroundColor: AppColors.primary, // Use shared color
      ),
      body: orderDetailsAsyncValue.when(
        data: (order) {
           if (order == null) {
            return const Center(child: Text('Order not found.'));
          }

          // Assuming createdAt is Timestamp
          final DateTime orderDate = order.createdAt.toDate();
          final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(orderDate);
          // OrderModel now has List<OrderProductItem>
          final products = order.products;
          final totalPrice = order.total;
          final status = order.status;

          return ListView( // Use ListView for potentially long content
            padding: const EdgeInsets.all(16.0),
            children: [
              // Order Information Card
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.id}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Placed on: $formattedDate'),
                      const SizedBox(height: 8),
                      Text('Status: $status', style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                      const SizedBox(height: 8),
                      Text('Delivery Address: ${order.address}'), // Use address from OrderModel
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Products Card
              AppCard(
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Items Ordered', style: Theme.of(context).textTheme.titleLarge),
                       const SizedBox(height: 10),
                       // Check if products list is null or empty
                       if (products.isEmpty)
                          const Text('No product details available.')
                       else
                         ListView.builder(
                          shrinkWrap: true, // Important inside ListView
                          physics: const NeverScrollableScrollPhysics(), // Disable scrolling of inner list
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index]; // This is OrderProductItem
                            return ListTile(
                              // Use product data directly (no imageUrl in OrderProductItem by default)
                              leading: const Icon(Icons.fastfood), // Placeholder
                              title: Text(product.name),
                              subtitle: Text('Qty: ${product.quantity}'),
                              trailing: Text('\$${(product.price * product.quantity).toStringAsFixed(2)}'),
                            );
                          },
                        ),
                     ],
                   ),
                 )
              ),
               const SizedBox(height: 16),
              // Total Price Card
              AppCard(
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('Total Price:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('\$${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                   ),
                 )
              ),
              // Add Order Tracking Button/Info if applicable
              // const SizedBox(height: 16),
              // AppButton(text: 'Track Order', onPressed: () { /* Navigate to tracking */ }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading order details: $error')),
      ),
    );
  }

  // Helper to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
      case 'accepted':
        return Colors.blue;
      case 'shipped':
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
}

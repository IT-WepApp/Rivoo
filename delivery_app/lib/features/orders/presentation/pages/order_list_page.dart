import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'package:shared_libs/models/models.dart';
import '../../providers/orders_notifier.dart'; // Import your OrdersNotifier

// This widget displays the list of currently assigned orders for the delivery person
class OrderListPage extends ConsumerWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    // Listen for errors
    ref.listen<AsyncValue<List<OrderModel>>>(ordersProvider, (previous, next) {
      if (next is AsyncError && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Deliveries'),
      ),
      body: ordersState.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
                child: Text('No deliveries assigned right now.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(ordersProvider.notifier).fetchAssignedOrders(),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderListItem(
                  order: order,
                  onTap: () {
                    // Navigate to map/details view
                    context.go('/deliveryMap/${order.id}');
                  },
                );
              },
            ),
          );
        },
        error: (error, stackTrace) => Center(
            child: Text(
                'Failed to load deliveries. Pull down to retry. Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// Represents a single order item in the list
class OrderListItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderListItem({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text('Order ID: ${order.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ID: ${order.userId}'),
            Text('Date: ${formatter.format(order.createdAt)}'),
          ],
        ),
        trailing: Chip(
          label: Text(order.status),
          backgroundColor: _getStatusColor(order.status, theme),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          labelStyle: TextStyle(
              fontSize: 12, color: theme.colorScheme.onSecondaryContainer),
          visualDensity: VisualDensity.compact,
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.blue.shade100;
      case 'shipped': // Or 'out_for_delivery'?
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}

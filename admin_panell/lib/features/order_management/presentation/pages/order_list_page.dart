import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_libs/models/models.dart'; // Added import
import 'package:shared_libs/services/services.dart'; // Assuming UserService is here

import '../../providers/order_management_notifier.dart';

// Provider to fetch user name using the correct UserService method
final userNameProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  // Made async
  // Assuming you have a userServiceProvider defined elsewhere
  final userService = ref.watch(userServiceProvider);
  // Use the correct method 'getUser' which returns UserModel?
  final userModel = await userService.getUser(userId);
  // Return the name from the model, or null/userId if not found
  return userModel?.name; // Assuming UserModel has a 'name' field
});

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  String _filterStatus = '';
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _orderStatuses = [
    '',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderManagementState = ref.watch(orderManagementProvider);

    ref.listen<AsyncValue<List<OrderModel>>>(orderManagementProvider,
        (previous, next) {
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
        title: const Text('Order Management'),
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: orderManagementState.when(
              data: (orders) => _buildOrderList(orders, ref),
              error: (error, stackTrace) => Center(
                  child: Text(
                      'Failed to load orders. Pull down to retry. Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          DropdownButton<String>(
            hint: const Text("Status Filter"),
            value: _filterStatus.isEmpty ? null : _filterStatus,
            onChanged: (String? newValue) {
              setState(() {
                _filterStatus = newValue ?? '';
              });
            },
            items: _orderStatuses.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.isEmpty ? 'All Statuses' : value),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by ID, Customer ID...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, WidgetRef ref) {
    final filteredOrders = orders.where((order) {
      final statusMatch = _filterStatus.isEmpty ||
          order.status.toLowerCase() == _filterStatus.toLowerCase();
      final searchMatch = _searchText.isEmpty ||
          (order.id.toLowerCase().contains(_searchText)) ||
          (order.userId.toLowerCase().contains(_searchText));
      return statusMatch && searchMatch;
    }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('No orders match the criteria.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderManagementProvider.notifier).fetchOrders(),
      child: ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return OrderListItem(
            order: order,
            availableStatuses:
                _orderStatuses.where((s) => s.isNotEmpty).toList(),
            onStatusChanged: (newStatus) async {
              bool confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Status Change'),
                      content: Text(
                          'Change order ${order.id} status to $newStatus?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirm')),
                      ],
                    ),
                  ) ??
                  false;

              if (confirm) {
                await ref
                    .read(orderManagementProvider.notifier)
                    .updateOrderStatus(order.id, newStatus);
              }
            },
          );
        },
      ),
    );
  }
}

class OrderListItem extends ConsumerWidget {
  final OrderModel order;
  final List<String> availableStatuses;
  final Future<void> Function(String) onStatusChanged;

  const OrderListItem({
    super.key,
    required this.order,
    required this.availableStatuses,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch the user name provider
    final customerNameAsync = ref.watch(userNameProvider(order.userId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
                'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}'),
            const SizedBox(height: 4),
            // Display customer name fetched asynchronously
            customerNameAsync.when(
              // Use the fetched name, or fallback to user ID if name is null or fetch failed
              data: (name) => Text('Customer: ${name ?? order.userId}'),
              loading: () => const Text('Customer: Loading...'),
              error: (err, stack) =>
                  Text('Customer: Error (${order.userId})'), // Show ID on error
            ),
            const SizedBox(height: 4),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(order.status),
                  backgroundColor: _getStatusColor(order.status),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                DropdownButton<String>(
                  value: order.status,
                  underline: Container(),
                  items: availableStatuses
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != order.status) {
                      onStatusChanged(newValue);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'processing':
        return Colors.blue.shade100;
      case 'shipped':
        return Colors.purple.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}

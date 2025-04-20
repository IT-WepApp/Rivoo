import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../application/orders_notifier.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  String _selectedStatusFilter = 'All';
  String _searchText = '';
  final _searchController = TextEditingController();

  final List<String> _statusOptions = ['All', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(sellerOrdersProvider);

    ref.listen<AsyncValue<List<OrderModel>>>(sellerOrdersProvider, (previous, next) {
      if (next is AsyncError && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: Column(
        children: [
          _buildFilterAndSearchBar(),
          Expanded(
            child: ordersState.when(
              data: (orders) => _buildOrderList(orders, ref),
              error: (error, stackTrace) => Center(child: Text('Failed to load orders: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _selectedStatusFilter,
            onChanged: (String? newValue) {
              setState(() {
                _selectedStatusFilter = newValue ?? 'All';
              });
            },
            items: _statusOptions.map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
            }).toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      final statusMatch = _selectedStatusFilter == 'All' || order.status.toLowerCase() == _selectedStatusFilter;
      final searchMatch = _searchText.isEmpty || order.id.toLowerCase().contains(_searchText);
      return statusMatch && searchMatch;
    }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('No orders match the criteria.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sellerOrdersProvider.notifier).fetchOrders(),
      child: ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final availableStatuses = _getAvailableStatusUpdates(order.status);

          return ListTile(
            title: Text('Order ID: ${order.id}'),
            subtitle: Text('Status: ${order.status} | Total: \$${order.total.toStringAsFixed(2)}'),
            trailing: availableStatuses.isNotEmpty
                ? DropdownButton<String>(
                    hint: const Text('Update'),
                    items: availableStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _showStatusUpdateDialog(order.id, newStatus);
                      }
                    },
                  )
                : null,
          );
        },
      ),
    );
  }

  List<String> _getAvailableStatusUpdates(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ['processing', 'cancelled'];
      case 'processing':
        return ['shipped', 'cancelled'];
      default:
        return [];
    }
  }

  void _showStatusUpdateDialog(String orderId, String newStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Change status to "$newStatus"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(sellerOrdersProvider.notifier).updateOrderStatus(orderId, newStatus);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart';
import 'package:intl/intl.dart';
import '../../application/order_history_notifier.dart';

// ✅ تعريف مؤقت لـ currentDeliveryPersonIdProvider (انقل هذا لاحقًا لمكان مناسب)
final currentDeliveryPersonIdProvider = Provider<String?>((ref) {
  return 'demo_delivery_id'; // ← استبدل هذا بـ القيمة الفعلية من auth إذا وجدت
});

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  String? _sortBy = 'createdAt';
  String? _sortOrder = 'desc';
  String? _filterStatus = 'delivered';

  final List<String?> _statusOptions = [
    null,
    'delivered',
    'cancelled',
    'pending',
    'processing',
    'accepted'
  ];
  final List<String?> _sortOptions = ['createdAt', 'total'];
  final List<String?> _sortOrderOptions = ['asc', 'desc'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchHistory();
      }
    });
  }

  void _fetchHistory() {
    final deliveryPersonId = ref.read(currentDeliveryPersonIdProvider);

    if (deliveryPersonId != null && deliveryPersonId.isNotEmpty) {
      ref.read(orderHistoryNotifierProvider.notifier).loadOrderHistory(
            deliveryPersonId,
            sortBy: _sortBy,
            sortOrder: _sortOrder,
            filterByStatus: _filterStatus,
          );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error: Delivery person ID not found. Please log in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(orderHistoryNotifierProvider);
    final theme = Theme.of(context);

    ref.listen<OrderHistoryState>(orderHistoryNotifierProvider,
        (previous, next) {
      if (next.error != null && next.error != previous?.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${next.error!}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Column(
        children: [
          _buildFilterAndSortControls(),
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyState.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading history. Pull down to retry.\nError details: ${historyState.error}',
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : historyState.orders.isEmpty
                        ? const Center(
                            child: Text('No historical orders found.'))
                        : RefreshIndicator(
                            onRefresh: () async => _fetchHistory(),
                            child: ListView.builder(
                              itemCount: historyState.orders.length,
                              itemBuilder: (context, index) {
                                final OrderModel order =
                                    historyState.orders[index];
                                return OrderHistoryItem(order: order);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: [
          DropdownButton<String?>(
            value: _filterStatus,
            hint: const Text("Filter Status"),
            items: _statusOptions.map((status) {
              return DropdownMenuItem<String?>(
                value: status,
                child: Text(status == null
                    ? 'All Statuses'
                    : status[0].toUpperCase() + status.substring(1)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() => _filterStatus = newValue);
              _fetchHistory();
            },
          ),
          DropdownButton<String?>(
            value: _sortBy,
            hint: const Text("Sort By"),
            items: _sortOptions.map((field) {
              return DropdownMenuItem<String?>(
                value: field,
                child: Text(field == 'createdAt'
                    ? 'Date'
                    : field == 'total'
                        ? 'Amount'
                        : field ?? 'Default'),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() => _sortBy = newValue);
              _fetchHistory();
            },
          ),
          DropdownButton<String?>(
            value: _sortOrder,
            hint: const Text("Sort Order"),
            items: _sortOrderOptions.map((order) {
              return DropdownMenuItem<String?>(
                value: order,
                child: Text(order == 'asc' ? 'Ascending' : 'Descending'),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() => _sortOrder = newValue);
              _fetchHistory();
            },
          ),
        ],
      ),
    );
  }
}

class OrderHistoryItem extends StatelessWidget {
  final OrderModel order;

  const OrderHistoryItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text('Order ID: ${order.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ID: ${order.userId}'),
            Text('Date: ${formatter.format(order.createdAt.toDate())}'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            Text(
                'Status: ${order.status[0].toUpperCase()}${order.status.substring(1)}'),
          ],
        ),
        trailing: Icon(Icons.history, color: theme.colorScheme.secondary),
      ),
    );
  }
}

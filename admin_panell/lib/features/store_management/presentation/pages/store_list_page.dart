import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// استورد نموذج المتجر
import 'package:shared_models/shared_models.dart' show StoreModel;
// موفر الـ notifier
import '../../application/store_management_notifier.dart';

class StoreListPage extends ConsumerStatefulWidget {
  const StoreListPage({super.key});

  @override
  ConsumerState<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends ConsumerState<StoreListPage> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';
  final _searchController = TextEditingController();

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeListState = ref.watch(storeManagementProvider);

    ref.listen<AsyncValue<List<StoreModel>>>(
      storeManagementProvider,
      (prev, next) {
        if (next is AsyncError && next != prev) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${next.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Store Management')),
      body: Column(
        children: [
          _buildFilterAndSearchBar(),
          Expanded(
            child: storeListState.when(
              data: (stores) => _buildStoreList(stores),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Failed to load stores. Pull down to retry.\nError: $err',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _selectedStatusFilter,
            onChanged: (newValue) {
              setState(() {
                _selectedStatusFilter = newValue!;
              });
            },
            items: _statusOptions
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by store name or owner',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList(List<StoreModel> stores) {
    final filtered = stores.where((store) {
      final name = store.name.toLowerCase();
      final owner = store.owner.toLowerCase();
      final status = store.status.toLowerCase();

      final matchesStatus = _selectedStatusFilter == 'All' ||
          status == _selectedStatusFilter.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          owner.contains(_searchQuery);

      return matchesStatus && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No stores match the criteria.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(storeManagementProvider.notifier).fetchStores(),
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final store = filtered[i];
          // store.id هنا نؤكد أنه non-null لأننا نتحقق قبل النداء
          final id = store.id;
          return StoreListItem(
            store: store,
            onApprove: () => _confirmAction(context, 'approve', id),
            onReject: () => _confirmAction(context, 'reject', id),
            onDelete: () => _confirmAction(context, 'delete', id),
          );
        },
      ),
    );
  }

  void _confirmAction(BuildContext ctx, String action, String id) {
    String title, content;
    VoidCallback onConfirm;
    Color color;

    switch (action) {
      case 'approve':
        title = 'Confirm Approval';
        content = 'Approve this store?';
        onConfirm =
            () => ref.read(storeManagementProvider.notifier).approveStore(id);
        color = Colors.green;
        break;
      case 'reject':
        title = 'Confirm Rejection';
        content = 'Reject this store?';
        onConfirm =
            () => ref.read(storeManagementProvider.notifier).rejectStore(id);
        color = Colors.orange;
        break;
      case 'delete':
        title = 'Confirm Deletion';
        content = 'Delete this store permanently?';
        onConfirm =
            () => ref.read(storeManagementProvider.notifier).deleteStore(id);
        color = Colors.red;
        break;
      default:
        return;
    }

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class StoreListItem extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  const StoreListItem({
    super.key,
    required this.store,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // نوحّد النوع إلى non-nullable String مع قيمة افتراضية
    final name = store.name;
    final owner = store.owner;
    final status = store.status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Owner: $owner', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('Status: $status', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.toLowerCase() == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.green),
                    tooltip: 'Approve',
                    onPressed: onApprove,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.cancel_outlined, color: Colors.orange),
                    tooltip: 'Reject',
                    onPressed: onReject,
                  ),
                ],
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

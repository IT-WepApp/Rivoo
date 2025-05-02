import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/widgets/app_widgets.dart' show AppWidgets;
import 'package:shared_libs/services/order_service_provider.dart' show orderServiceProvider;
import 'package:shared_libs/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_libs/services/services.dart';
import 'package:shared_libs/models/models.dart';

final currentSellerIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final sellerDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  final sellerId = ref.watch(currentSellerIdProvider);

  if (sellerId == null) {
    throw Exception('Seller not logged in');
  }

  final recentOrders = await orderService.getOrdersBySeller(sellerId);

  return {
    'recentOrders': recentOrders.take(5).toList(),
    'totalPendingOrders':
        recentOrders.where((o) => o.status == 'pending').length,
  };
});

class SellerHomePage extends ConsumerWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(sellerDashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(sellerDashboardProvider),
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: dashboardDataAsync.when(
        data: (data) => _buildDashboardContent(context, data, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          developer.log('Error loading dashboard',
              error: error, stackTrace: stack, name: 'SellerHomePage');
          return Center(child: Text('Error loading dashboard data: $error'));
        },
      ),
      drawer: _buildAppDrawer(context, theme),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, Map<String, dynamic> data, ThemeData theme) {
    final List<OrderModel> recentOrders = data['recentOrders'] ?? [];
    final int pendingOrders = data['totalPendingOrders'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.center,
          children: [
            _buildStatCard(theme, 'Pending Orders', pendingOrders.toString(),
                Icons.pending_actions, Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        Text('Quick Actions', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12.0,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Product'),
              onPressed: () => context.go('/addProduct'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('View All Orders'),
              onPressed: () => context.go('/sellerOrders'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Manage Products'),
              onPressed: () => context.go('/sellerProducts'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Recent Orders', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        recentOrders.isEmpty
            ? const Text('No recent orders found.')
            : Column(
                children: recentOrders
                    .map((order) => AppWidgets.appCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('Order #${order.id}'),
                            subtitle: Text(
                                'Status: ${order.status} | Total: \$${order.total.toStringAsFixed(2)}'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () =>
                                context.go('/sellerOrderDetails/${order.id}'),
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildStatCard(
      ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Text(
              'Seller Menu',
              style:
                  TextStyle(color: theme.colorScheme.onPrimary, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: theme.colorScheme.primary),
            title: const Text('Dashboard'),
            onTap: () => context.go('/sellerHome'),
          ),
          ListTile(
            leading: Icon(Icons.inventory_2, color: theme.colorScheme.primary),
            title: const Text('Products'),
            onTap: () => context.go('/sellerProducts'),
          ),
          ListTile(
            leading: Icon(Icons.list_alt, color: theme.colorScheme.primary),
            title: const Text('Orders'),
            onTap: () => context.go('/sellerOrders'),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
    );
  }
}

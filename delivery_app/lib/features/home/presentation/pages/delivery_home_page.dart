import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_libs/models/models.dart';
import 'package:shared_libs/services/services.dart';
import 'package:delivery_app/features/auth/providers/auth_notifier.dart';
import 'package:shared_libs/services/order_service_provider.dart';


// Provider لاسم العميل
final customerNameProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  final userModel = await userService.getUser(userId);
  return userModel?.name;
});

// Provider لرقم المندوب الحالي
final currentDeliveryPersonIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

// Provider للحصول على الطلبات المخصصة
final assignedOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  final deliveryPersonId = ref.watch(currentDeliveryPersonIdProvider);

  if (deliveryPersonId == null) return [];

  final allOrders = await orderService.getAllOrders();
  return allOrders
      .where((o) =>
          o.deliveryPersonId == deliveryPersonId &&
          (o.status == 'processing' || o.status == 'shipped'))
      .toList();
});

class DeliveryHomePage extends ConsumerWidget {
  const DeliveryHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedOrdersAsync = ref.watch(assignedOrdersProvider);
    final theme = Theme.of(context);

    // استماع للأخطاء
    ref.listen<AsyncValue<List<OrderModel>>>(assignedOrdersProvider,
        (prev, next) {
      if (next is AsyncError && next != prev) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Orders"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // إعادة تحميل سريع بدون انتظار
              ref.invalidate(assignedOrdersProvider);
            },
          ),
        ],
      ),
      body: assignedOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
                child: Text('No orders currently assigned to you.'));
          }
          return RefreshIndicator(
            onRefresh: () {
              // ننظف الكاش ونرجع Future<void> فارغ
              ref.invalidate(assignedOrdersProvider);
              return Future.value();
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: _OrderListItem(order: order),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child:
              Text('Failed to load orders. Pull down to retry.\nError: $err'),
        ),
      ),
      drawer: _buildAppDrawer(context, theme, ref),
    );
  }

  Widget _buildAppDrawer(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Text(
              'Menu',
              style:
                  TextStyle(color: theme.colorScheme.onPrimary, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: theme.colorScheme.primary),
            title: const Text('Current Orders'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.primary),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pop(context);
              context.go('/deliveryHistory');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.primary),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/deliveryProfile');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
    );
  }
}

class _OrderListItem extends ConsumerWidget {
  final OrderModel order;
  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerNameAsync = ref.watch(customerNameProvider(order.userId));

    return ListTile(
      title: Text('Order ID: ${order.id}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customerNameAsync.when(
            data: (name) => Text('Customer: ${name ?? order.userId}'),
            loading: () => const Text('Customer: Loading...'),
            error: (e, _) => Text('Customer: Error (${order.userId})'),
          ),
          Text('Status: ${order.status}'),
          Text('To: ${order.deliveryAddress}'),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go('/deliveryMap/${order.id}'),
    );
  }
}

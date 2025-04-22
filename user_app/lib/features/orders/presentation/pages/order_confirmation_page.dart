import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Needed for CartItemModel
import 'package:shared_libs/lib/services/shared_services.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/application/cart_notifier.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';

class OrderConfirmationPage extends ConsumerStatefulWidget {
  const OrderConfirmationPage({super.key});

  @override
  ConsumerState<OrderConfirmationPage> createState() =>
      _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends ConsumerState<OrderConfirmationPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalPrice = cartNotifier.totalPrice;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final userId = ref.watch(userIdProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    Future<void> placeOrderAction() async {
      final currentUserId = ref.read(userIdProvider);
      if (currentUserId == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to place an order.')),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final orderService = ref.read(orderServiceProvider);
        await orderService.placeOrder(currentUserId, cartItems, totalPrice);
        ref.read(cartProvider.notifier).clearCart();

        if (!mounted) return;

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        router.go('/my-orders');
      } catch (e) {
        debugPrint('Error placing order: $e');
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to place order: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text("Your cart is empty. Cannot place order."))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading:
                              item.imageUrl != null && item.imageUrl!.isNotEmpty
                                  ? Image.network(item.imageUrl!,
                                      width: 50, height: 50, fit: BoxFit.cover)
                                  : const Icon(Icons.shopping_cart),
                          title: Text(item.name),
                          subtitle: Text('Qty: ${item.quantity}'),
                          trailing: Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (cartItems.isEmpty || userId == null)
                    ? const Text(
                        "You must be logged in and have items in cart.")
                    : AppButton(
                        text: 'Place Order Now',
                        onPressed: () {
                          placeOrderAction();
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

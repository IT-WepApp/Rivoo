import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/cart/application/cart_notifier.dart';
import 'package:shared_models/shared_models.dart'; // Use main export
import 'package:shared_widgets/shared_widgets.dart'; // Use main export
import 'package:intl/intl.dart'; // For currency formatting
import 'package:go_router/go_router.dart'; // For navigation

class ShoppingCartPage extends ConsumerWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$'); // Adjust locale/symbol

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
         backgroundColor: theme.colorScheme.primaryContainer,
         foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: cartItems.isEmpty
          ? const Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                   SizedBox(height: 8),
                   Text('Add items to get started!'),
                 ],
               ),
             )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, theme, item, cartNotifier, currencyFormatter);
                    },
                  ),
                ),
                 // --- Cart Summary & Checkout ---
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                     color: theme.cardColor,
                     boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0,-2))]
                  ),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text('Subtotal (${cartNotifier.totalItems} items):', style: theme.textTheme.titleMedium),
                             Text(
                                currencyFormatter.format(cartNotifier.totalPrice),
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                          ],
                       ),
                        // Add shipping/tax info if applicable here
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Proceed to Checkout',
                          onPressed: () {
                              // Navigate to checkout page (create if needed)
                               context.go('/checkout'); // Example route
                          },
                           // Disable button if cart is empty (though the view wouldn't show if empty)
                           // onPressed: cartItems.isEmpty ? null : () => context.go('/checkout'), 
                        ),
                     ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, ThemeData theme, CartItemModel item, CartNotifier cartNotifier, NumberFormat formatter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
         elevation: 1,
         child: Padding(
           padding: const EdgeInsets.all(8.0),
           child: Row(
             children: [
               // Item Image
                Container(
                 width: 70, height: 70, 
                 margin: const EdgeInsets.only(right: 12),
                 color: Colors.grey.shade200,
                 child: item.imageUrl != null && item.imageUrl!.isNotEmpty 
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                           errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image, color: Colors.grey),
                         )
                      : const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
                // Item Details
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(item.name, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                     Text(formatter.format(item.price), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                   ],
                 ),
               ),
                // Quantity Controls & Remove
               Column(
                  children: [
                    Row(
                       children: [
                         IconButton(
                           icon: const Icon(Icons.remove_circle_outline, size: 20), 
                           visualDensity: VisualDensity.compact,
                           padding: EdgeInsets.zero,
                           onPressed: () => cartNotifier.decrementQuantity(item.id),
                         ),
                          Text(item.quantity.toString(), style: theme.textTheme.titleMedium),
                         IconButton(
                           icon: const Icon(Icons.add_circle_outline, size: 20), 
                           visualDensity: VisualDensity.compact,
                           padding: EdgeInsets.zero,
                           onPressed: () => cartNotifier.incrementQuantity(item.id),
                         ),
                       ],
                    ),
                     Text(formatter.format(item.price * item.quantity), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
               ),
                IconButton(
                 icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 22),
                 tooltip: 'Remove Item',
                 visualDensity: VisualDensity.compact,
                 padding: const EdgeInsets.only(left: 8),
                 onPressed: () => cartNotifier.removeItem(item.id),
               ),
             ],
           ),
         ),
      ),
    );
  }
}

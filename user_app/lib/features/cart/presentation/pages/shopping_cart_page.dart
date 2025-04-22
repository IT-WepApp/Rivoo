import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/cart/application/cart_notifier.dart';
import 'package:shared_libs/lib/models/shared_models.dart'; // Use main export
import 'package:shared_libs/lib/widgets/shared_widgets.dart'; // Use main export
import 'package:intl/intl.dart'; // For currency formatting
import 'package:go_router/go_router.dart'; // For navigation

class ShoppingCartPage extends ConsumerWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
        locale: 'ar_SA', symbol: 'ريال'); // تعديل العملة للريال السعودي

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('سلة التسوق فارغة',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('أضف منتجات للبدء!'),
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
                      return _buildCartItem(context, theme, item, cartNotifier,
                          currencyFormatter);
                    },
                  ),
                ),
                // --- Cart Summary & Checkout ---
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, -2))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المجموع (${cartNotifier.totalItems} منتج):',
                              style: theme.textTheme.titleMedium),
                          Text(
                            currencyFormatter.format(cartNotifier.totalPrice),
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('رسوم التوصيل:',
                              style: TextStyle(fontSize: 14)),
                          Text(
                            currencyFormatter.format(15.0),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الضريبة (15%):',
                              style: TextStyle(fontSize: 14)),
                          Text(
                            currencyFormatter
                                .format(cartNotifier.totalPrice * 0.15),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الإجمالي:',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormatter.format(cartNotifier.totalPrice +
                                15.0 +
                                (cartNotifier.totalPrice * 0.15)),
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'المتابعة للدفع',
                        icon: Icons.shopping_cart_checkout,
                        onPressed: () {
                          // التنقل إلى صفحة الدفع
                          context.goNamed('checkout');
                        },
                        // تعطيل الزر إذا كانت السلة فارغة
                        // onPressed: cartItems.isEmpty ? null : () => context.goNamed('checkout'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, ThemeData theme,
      CartItemModel item, CartNotifier cartNotifier, NumberFormat formatter) {
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
                width: 70,
                height: 70,
                margin: const EdgeInsets.only(right: 12),
                color: Colors.grey.shade200,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(formatter.format(item.price),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary)),
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
                        onPressed: () =>
                            cartNotifier.decrementQuantity(item.id),
                      ),
                      Text(item.quantity.toString(),
                          style: theme.textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            cartNotifier.incrementQuantity(item.id),
                      ),
                    ],
                  ),
                  Text(formatter.format(item.price * item.quantity),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: theme.colorScheme.error, size: 22),
                tooltip: 'إزالة المنتج',
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

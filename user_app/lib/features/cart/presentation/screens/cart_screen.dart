import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/cart/domain/cart_item.dart';
import 'package:user_app/features/cart/presentation/widgets/cart_item_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // قائمة مؤقتة لعناصر السلة للعرض
    final cartItems = [
      CartItem(
        id: '1',
        productId: 'product-1',
        name: 'Product 1',
        price: 150.0,
        quantity: 2,
        imageUrl: 'https://via.placeholder.com/100',
      ),
      CartItem(
        id: '2',
        productId: 'product-2',
        name: 'Product 2',
        price: 200.0,
        quantity: 1,
        imageUrl: 'https://via.placeholder.com/100',
      ),
      CartItem(
        id: '3',
        productId: 'product-3',
        name: 'Product 3',
        price: 300.0,
        quantity: 3,
        imageUrl: 'https://via.placeholder.com/100',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cart),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // عرض حوار تأكيد حذف جميع العناصر
              _showClearCartDialog(context, l10n);
            },
          ),
        ],
      ),
      body: ResponsiveBuilder(
        // تنفيذ واجهة الهاتف
        mobileBuilder: (context) => _buildMobileLayout(context, l10n, cartItems),
        
        // تنفيذ واجهة الجهاز اللوحي
        smallTabletBuilder: (context) => _buildTabletLayout(context, l10n, cartItems),
        
        // تنفيذ واجهة سطح المكتب
        desktopBuilder: (context) => _buildDesktopLayout(context, l10n, cartItems),
      ),
      bottomNavigationBar: ResponsiveBuilder(
        mobileBuilder: (context) => _buildBottomBar(context, l10n, cartItems),
        smallTabletBuilder: (context) => _buildBottomBar(context, l10n, cartItems),
        desktopBuilder: (context) => const SizedBox.shrink(), // لا نعرض شريط التنقل السفلي في وضع سطح المكتب
      ),
    );
  }

  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(
    BuildContext context, 
    AppLocalizations l10n,
    List<CartItem> cartItems,
  ) {
    return cartItems.isEmpty
        ? _buildEmptyCart(context, l10n)
        : _buildCartItemsList(context, l10n, cartItems);
  }

  // بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(
    BuildContext context, 
    AppLocalizations l10n,
    List<CartItem> cartItems,
  ) {
    if (cartItems.isEmpty) {
      return _buildEmptyCart(context, l10n);
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قائمة عناصر السلة
          Expanded(
            flex: 3,
            child: _buildCartItemsList(context, l10n, cartItems),
          ),
          
          const SizedBox(width: 16),
          
          // ملخص السلة
          Expanded(
            flex: 2,
            child: _buildCartSummary(context, l10n, cartItems),
          ),
        ],
      ),
    );
  }

  // بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(
    BuildContext context, 
    AppLocalizations l10n,
    List<CartItem> cartItems,
  ) {
    if (cartItems.isEmpty) {
      return _buildEmptyCart(context, l10n);
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قائمة عناصر السلة
          Expanded(
            flex: 7,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.itemsInOrder,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${cartItems.length} ${l10n.items}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Expanded(
                      child: _buildCartItemsList(context, l10n, cartItems, isScrollable: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // ملخص السلة
          Expanded(
            flex: 3,
            child: _buildCartSummary(context, l10n, cartItems),
          ),
        ],
      ),
    );
  }

  // بناء قائمة عناصر السلة
  Widget _buildCartItemsList(
    BuildContext context, 
    AppLocalizations l10n,
    List<CartItem> cartItems, {
    bool isScrollable = false,
  }) {
    final listView = ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: cartItems.length,
      shrinkWrap: !isScrollable,
      physics: isScrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return CartItemCard(
          item: item,
          onQuantityChanged: (quantity) {
            // تحديث الكمية
          },
          onRemove: () {
            // إزالة العنصر
          },
        );
      },
    );
    
    return isScrollable
        ? listView
        : SingleChildScrollView(child: listView);
  }

  // بناء ملخص السلة
  Widget _buildCartSummary(
    BuildContext context, 
    AppLocalizations l10n,
    List<CartItem> cartItems,
  ) {
    // حساب المجموع الفرعي
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    
    // حساب الضريبة (15%)
    final tax = subtotal * 0.15;
    
    // حساب رسوم الشحن
    const shipping = 30.0;
    
    // حساب المجموع الكلي
    final total = subtotal + tax + shipping;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.orderSummary,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // المجموع الفرعي
            _buildSummaryRow(
              context,
              label: l10n.subtotal,
              value: '${l10n.currencySymbol} ${subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            
            // الضريبة
            _buildSummaryRow(
              context,
              label: l10n.tax,
              value: '${l10n.currencySymbol} ${tax.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            
            // الشحن
            _buildSummaryRow(
              context,
              label: l10n.shipping,
              value: '${l10n.currencySymbol} ${shipping.toStringAsFixed(2)}',
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            
            // المجموع الكلي
            _buildSummaryRow(
              context,
              label: l10n.total,
              value: '${l10n.currencySymbol} ${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            
            const SizedBox(height: 24),
            
            // حقل الكوبون
            TextField(
              decoration: InputDecoration(
                hintText: l10n.enterCouponCode,
                suffixIcon: TextButton(
                  onPressed: () {},
                  child: Text(l10n.apply),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // زر الدفع
            SizedBox(
              width: double.infinity,
              child: ResponsiveButton(
                text: l10n.checkout,
                icon: Icons.shopping_bag,
                onPressed: () {
                  // الانتقال إلى صفحة الدفع
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء صف في ملخص السلة
  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
              : Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }

  // بناء شريط التنقل السفلي
  Widget _buildBottomBar(
    BuildContext context, 
    AppLocalizations l10n,
    List<CartItem> cartItems,
  ) {
    if (cartItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // حساب المجموع الكلي
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.15;
    const shipping = 30.0;
    final total = subtotal + tax + shipping;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // المجموع الكلي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.total,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${l10n.currencySymbol} ${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          
          // زر الدفع
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // الانتقال إلى صفحة الدفع
              },
              icon: const Icon(Icons.shopping_bag),
              label: Text(l10n.checkout),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء حالة السلة الفارغة
  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: context.responsiveIconSize(100),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.emptyCart,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'لم تقم بإضافة أي منتجات إلى سلة التسوق بعد.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ResponsiveButton(
              text: l10n.continueShopping,
              icon: Icons.shopping_bag,
              onPressed: () {
                // العودة إلى صفحة المنتجات
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // عرض حوار تأكيد حذف جميع العناصر
  void _showClearCartDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAll),
        content: Text('هل أنت متأكد من رغبتك في حذف جميع العناصر من سلة التسوق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // حذف جميع العناصر
              Navigator.pop(context);
            },
            child: Text(
              l10n.clearAll,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// نموذج عنصر السلة (يجب نقله إلى ملف منفصل)
class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String? color;
  final String? size;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.color,
    this.size,
  });
}

// بطاقة عنصر السلة (يجب نقلها إلى ملف منفصل)
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            
            // معلومات المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.color != null || item.size != null)
                    Text(
                      [
                        if (item.color != null) 'اللون: ${item.color}',
                        if (item.size != null) 'الحجم: ${item.size}',
                      ].join(' | '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${l10n.currencySymbol} ${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      // محدد الكمية
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (item.quantity > 1) {
                                  onQuantityChanged(item.quantity - 1);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.remove, size: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '${item.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                onQuantityChanged(item.quantity + 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.total}: ${l10n.currencySymbol} ${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(l10n.remove),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

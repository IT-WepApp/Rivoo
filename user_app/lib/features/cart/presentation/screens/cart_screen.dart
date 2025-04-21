import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/features/cart/domain/entities/cart_item.dart';
import 'package:user_app/flutter_gen/gen_l10n/app_localizations.dart';

/// شاشة سلة التسوق
class CartScreen extends StatefulWidget {
  /// إنشاء شاشة سلة التسوق
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  List<CartItem> _cartItems = [];
  double _subtotal = 0.0;
  double _shippingFee = 10.0;
  double _tax = 0.0;
  double _discount = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  /// تحميل عناصر سلة التسوق
  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // استدعاء واجهة برمجة التطبيقات للحصول على عناصر سلة التسوق
      await Future.delayed(const Duration(seconds: 1));
      
      // بيانات وهمية للعرض
      setState(() {
        // _cartItems = ...
        _calculateTotals();
      });
    } catch (e) {
      // معالجة الخطأ
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// حساب المبالغ الإجمالية
  void _calculateTotals() {
    _subtotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    _tax = _subtotal * 0.05;
    _total = _subtotal + _shippingFee + _tax - _discount;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(localizations.cart),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showClearCartConfirmation,
              tooltip: localizations.clearCart,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? _buildEmptyCart(localizations)
              : _buildCartContent(localizations),
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : _buildCheckoutBar(localizations),
    );
  }

  /// بناء محتوى السلة الفارغة
  Widget _buildEmptyCart(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.emptyCart,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.emptyCartMessage,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // التنقل إلى شاشة المنتجات
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(localizations.startShopping),
          ),
        ],
      ),
    );
  }

  /// بناء محتوى السلة
  Widget _buildCartContent(AppLocalizations localizations) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = _cartItems[index];
              return Dismissible(
                key: Key(cartItem.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _removeCartItem(cartItem.id);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صورة المنتج
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cartItem.product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // تفاصيل المنتج
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اسم المنتج
                              Text(
                                cartItem.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // الخيارات (إن وجدت)
                              if (cartItem.options != null && cartItem.options!.isNotEmpty)
                                Text(
                                  cartItem.options!.entries
                                      .map((e) => '${e.key}: ${e.value}')
                                      .join(', '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              
                              const SizedBox(height: 8),
                              
                              // السعر والكمية
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // السعر
                                  Text(
                                    '\$${cartItem.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  
                                  // التحكم بالكمية
                                  Row(
                                    children: [
                                      // زر تقليل الكمية
                                      _buildQuantityButton(
                                        icon: Icons.remove,
                                        onPressed: cartItem.quantity > 1
                                            ? () => _updateCartItemQuantity(
                                                cartItem.id, cartItem.quantity - 1)
                                            : null,
                                      ),
                                      
                                      // الكمية
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      
                                      // زر زيادة الكمية
                                      _buildQuantityButton(
                                        icon: Icons.add,
                                        onPressed: () => _updateCartItemQuantity(
                                            cartItem.id, cartItem.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // ملخص السلة
        _buildCartSummary(localizations),
      ],
    );
  }

  /// بناء زر التحكم بالكمية
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: onPressed == null ? Colors.grey[300]! : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null ? Colors.grey[400] : Colors.grey[700],
        ),
      ),
    );
  }

  /// بناء ملخص السلة
  Widget _buildCartSummary(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الملخص
          Text(
            localizations.orderSummary,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // المبلغ الإجمالي
          _buildSummaryRow(
            label: localizations.subtotal,
            value: _subtotal,
          ),
          
          const SizedBox(height: 8),
          
          // رسوم الشحن
          _buildSummaryRow(
            label: localizations.shippingFee,
            value: _shippingFee,
          ),
          
          const SizedBox(height: 8),
          
          // الضريبة
          _buildSummaryRow(
            label: localizations.tax,
            value: _tax,
          ),
          
          // الخصم (إذا كان موجودًا)
          if (_discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: localizations.discount,
              value: -_discount,
              valueColor: Colors.red,
            ),
          ],
          
          const Divider(height: 24),
          
          // المبلغ الإجمالي النهائي
          _buildSummaryRow(
            label: localizations.total,
            value: _total,
            isBold: true,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  /// بناء صف في ملخص السلة
  Widget _buildSummaryRow({
    required String label,
    required double value,
    bool isBold = false,
    double fontSize = 14,
    Color? valueColor,
  }) {
    final fontWeight = isBold ? FontWeight.bold : FontWeight.normal;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        Text(
          '\$${value.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: valueColor ?? AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  /// بناء شريط الدفع
  Widget _buildCheckoutBar(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // المبلغ الإجمالي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.total,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // زر الدفع
          ElevatedButton(
            onPressed: _proceedToCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(localizations.checkout),
          ),
        ],
      ),
    );
  }

  /// تحديث كمية عنصر في سلة التسوق
  void _updateCartItemQuantity(String cartItemId, int newQuantity) {
    // تنفيذ تحديث الكمية
  }

  /// إزالة عنصر من سلة التسوق
  void _removeCartItem(String cartItemId) {
    // تنفيذ إزالة العنصر
  }

  /// عرض تأكيد تفريغ السلة
  void _showClearCartConfirmation() {
    // عرض مربع حوار التأكيد
  }

  /// الانتقال إلى الدفع
  void _proceedToCheckout() {
    // الانتقال إلى شاشة الدفع
  }
}

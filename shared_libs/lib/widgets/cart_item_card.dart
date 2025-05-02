import 'package:flutter/material.dart';
import 'package:shared_libs/theme/app_theme.dart'; // Updated import
import 'package:shared_libs/entities/cart_item_entity.dart'; // Updated import
import 'package:user_app/features/products/domain/user_product.dart'; // Updated import

/// بطاقة عنصر سلة التسوق
class CartItemCard extends StatelessWidget {
  /// عنصر سلة التسوق (باستخدام النموذج الموحد)
  final UserCartItem cartItem;

  /// دالة تنفذ عند تغيير الكمية
  final Function(int)? onQuantityChanged;

  /// دالة تنفذ عند إزالة العنصر
  final VoidCallback? onRemove;

  /// دالة تنفذ عند النقر على العنصر
  final VoidCallback? onTap;

  /// إنشاء بطاقة عنصر سلة التسوق
  const CartItemCard({
    Key? key,
    required this.cartItem,
    this.onQuantityChanged,
    this.onRemove,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام UserProduct من UserCartItem
    final UserProduct product = cartItem.product;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    product.imageUrl, // Use imageUrl from ProductEntity
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
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
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // السعر
                    Row(
                      children: [
                        // Check isDiscounted from UserProduct
                        if (product.isDiscounted) ...[
                          Text(
                            // Use actualPrice from UserProduct
                            '\$${product.actualPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // التحكم في الكمية
                    Row(
                      children: [
                        // زر تقليل الكمية
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: InkWell(
                            onTap: onQuantityChanged != null && cartItem.quantity > 1
                                ? () => onQuantityChanged!(cartItem.quantity - 1)
                                : null,
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: onQuantityChanged != null && cartItem.quantity > 1
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),

                        // عرض الكمية
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: InkWell(
                            onTap: onQuantityChanged != null
                                ? () => onQuantityChanged!(cartItem.quantity + 1)
                                : null,
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: onQuantityChanged != null
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // السعر الإجمالي (يأتي الآن من UserCartItem المحسوب)
                        Text(
                          '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // زر الإزالة
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onRemove,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


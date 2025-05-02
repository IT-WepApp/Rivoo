import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/features/product_details/presentation/widgets/rating_stars.dart';
// Updated import to use ProductDetails
import 'package:user_app/features/product_details/domain/entities/product_details.dart'; 
import 'package:user_app/features/products/domain/product_status.dart';

/// بطاقة عرض المنتج
class ProductCard extends StatelessWidget {
  /// بيانات المنتج (Using ProductDetails now)
  final ProductDetails product;
  
  /// دالة تنفذ عند النقر على البطاقة
  final VoidCallback? onTap;
  
  /// إظهار شارة الخصم
  final bool showDiscountBadge;
  
  /// إظهار زر الإضافة إلى السلة
  final bool showAddToCartButton;
  
  /// دالة تنفذ عند النقر على زر الإضافة إلى السلة
  final VoidCallback? onAddToCart;
  
  /// دالة تنفذ عند النقر على زر المفضلة
  final VoidCallback? onFavoriteToggle;
  
  /// حالة المفضلة
  final bool isFavorite;

  /// إنشاء بطاقة عرض المنتج
  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.showDiscountBadge = true,
    this.showAddToCartButton = true,
    this.onAddToCart,
    this.onFavoriteToggle,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl, // From ProductEntity
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // شارة الخصم (Using isOnSale getter from ProductDetails)
                if (showDiscountBadge && product.isOnSale) ...[
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        // Using discountPercentage getter from ProductDetails
                        '-${product.discountPercentage!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                
                // زر المفضلة
                if (onFavoriteToggle != null) ...[
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onFavoriteToggle,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: const EdgeInsets.all(8),
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
                
                // شارة الحالة
                if (product.status != ProductStatus.available) ...[
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.status == ProductStatus.comingSoon
                            ? Colors.blue
                            : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.status == ProductStatus.comingSoon
                            ? 'قريبًا'
                            : 'نفذت الكمية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            // تفاصيل المنتج
            Padding(
              padding: const EdgeInsets.all(12),
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
                  
                  // التقييم
                  Row(
                    children: [
                      RatingStars(
                        rating: product.rating,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})', // Use reviewCount from ProductDetails
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // السعر (Using isOnSale and actualPrice getters from ProductDetails)
                  Row(
                    children: [
                      if (product.isOnSale) ...[
                        Text(
                          '\$${product.actualPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // زر الإضافة إلى السلة (Using isAvailable getter from ProductDetails)
            if (showAddToCartButton) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.isAvailable ? onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: const Text('إضافة إلى السلة'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/products/domain/product.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_stars.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_summary.dart';
import 'package:user_app/features/ratings/presentation/widgets/review_card.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          // تنفيذ واجهة الهاتف
          mobileBuilder: (context) => _buildMobileLayout(context, l10n),
          
          // تنفيذ واجهة الجهاز اللوحي
          smallTabletBuilder: (context) => _buildTabletLayout(context, l10n),
          
          // تنفيذ واجهة سطح المكتب
          desktopBuilder: (context) => _buildDesktopLayout(context, l10n),
        ),
      ),
      bottomNavigationBar: ResponsiveBuilder(
        mobileBuilder: (context) => _buildBottomBar(context, l10n),
        smallTabletBuilder: (context) => _buildBottomBar(context, l10n),
        desktopBuilder: (context) => const SizedBox.shrink(), // لا نعرض شريط التنقل السفلي في وضع سطح المكتب
      ),
    );
  }

  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context, l10n),
          _buildProductImages(context),
          _buildProductInfo(context, l10n),
          _buildProductDescription(context, l10n),
          _buildProductReviews(context, l10n),
          _buildRelatedProducts(context, l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context, l10n),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildProductImages(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(context, l10n),
                      _buildProductDescription(context, l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildProductReviews(context, l10n),
          _buildRelatedProducts(context, l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _buildAppBar(context, l10n),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صور المنتج
                      Expanded(
                        flex: 4,
                        child: _buildProductImages(context),
                      ),
                      const SizedBox(width: 32),
                      // معلومات المنتج
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductInfo(context, l10n),
                            _buildProductDescription(context, l10n),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // بطاقة الشراء
                      Expanded(
                        flex: 3,
                        child: _buildPurchaseCard(context, l10n),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // التقييمات
                  _buildProductReviews(context, l10n),
                  const SizedBox(height: 48),
                  // المنتجات ذات الصلة
                  _buildRelatedProducts(context, l10n),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // بناء شريط التطبيق
  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            l10n.productDetails,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء صور المنتج
  Widget _buildProductImages(BuildContext context) {
    return Container(
      height: context.responsiveHeight(300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // صورة المنتج الرئيسية
          Center(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.contain,
              height: context.responsiveHeight(250),
            ),
          ),
          
          // مؤشرات الصور المصغرة
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // زر التكبير
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء معلومات المنتج
  Widget _buildProductInfo(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم المنتج
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          // التقييم
          Row(
            children: [
              RatingStars(rating: product.rating),
              const SizedBox(width: 8),
              Text(
                '(${product.reviewCount} ${l10n.reviews})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // السعر
          Row(
            children: [
              Text(
                '${l10n.currencySymbol} ${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              if (product.discountPrice != null)
                Text(
                  '${l10n.currencySymbol} ${product.discountPrice!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.inStock ? l10n.inStock : l10n.outOfStock,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // خيارات المنتج
          if (context.isPhone || context.isSmallTablet) ...[
            _buildProductOptions(context, l10n),
            const SizedBox(height: 16),
            _buildQuantitySelector(context, l10n),
            const SizedBox(height: 16),
            _buildAddToCartButton(context, l10n),
          ],
        ],
      ),
    );
  }

  // بناء وصف المنتج
  Widget _buildProductDescription(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.description,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // المواصفات
          ExpansionTile(
            title: Text(
              l10n.specifications,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSpecificationRow(context, 'Brand', 'RivooSy'),
                    _buildSpecificationRow(context, 'Model', 'RS-2023'),
                    _buildSpecificationRow(context, 'Weight', '250g'),
                    _buildSpecificationRow(context, 'Dimensions', '10 x 5 x 2 cm'),
                    _buildSpecificationRow(context, 'Material', 'Aluminum'),
                    _buildSpecificationRow(context, 'Warranty', '1 Year'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء صف المواصفات
  Widget _buildSpecificationRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء خيارات المنتج
  Widget _buildProductOptions(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اللون
        Text(
          l10n.color,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildColorOption(context, Colors.red, isSelected: true),
            _buildColorOption(context, Colors.blue),
            _buildColorOption(context, Colors.green),
            _buildColorOption(context, Colors.black),
            _buildColorOption(context, Colors.white),
          ],
        ),
        const SizedBox(height: 16),
        
        // الحجم
        Text(
          l10n.size,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSizeOption(context, 'S'),
            _buildSizeOption(context, 'M', isSelected: true),
            _buildSizeOption(context, 'L'),
            _buildSizeOption(context, 'XL'),
            _buildSizeOption(context, 'XXL'),
          ],
        ),
      ],
    );
  }

  // بناء خيار اللون
  Widget _buildColorOption(BuildContext context, Color color, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  // بناء خيار الحجم
  Widget _buildSizeOption(BuildContext context, String size, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            size,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  // بناء محدد الكمية
  Widget _buildQuantitySelector(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Text(
          l10n.quantity,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {},
                iconSize: 16,
              ),
              const SizedBox(
                width: 40,
                child: Center(
                  child: Text('1'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
                iconSize: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // بناء زر الإضافة إلى السلة
  Widget _buildAddToCartButton(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart),
            label: Text(l10n.addToCart),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // بناء بطاقة الشراء (للعرض في وضع سطح المكتب)
  Widget _buildPurchaseCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 4,
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
            const SizedBox(height: 16),
            _buildProductOptions(context, l10n),
            const SizedBox(height: 16),
            _buildQuantitySelector(context, l10n),
            const Divider(height: 32),
            _buildPriceSummary(context, l10n),
            const SizedBox(height: 16),
            _buildAddToCartButton(context, l10n),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: Text(l10n.addToWishlist),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء ملخص السعر
  Widget _buildPriceSummary(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.price,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${l10n.currencySymbol} ${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.tax,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${l10n.currencySymbol} ${(product.price * 0.15).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const Divider(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.total,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${l10n.currencySymbol} ${(product.price * 1.15).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // بناء تقييمات المنتج
  Widget _buildProductReviews(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.reviews,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(l10n.viewAllReviews),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // ملخص التقييمات
          RatingSummary(
            rating: product.rating,
            reviewCount: product.reviewCount,
          ),
          const SizedBox(height: 16),
          
          // زر إضافة تقييم
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.rate_review),
            label: Text(l10n.writeReview),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // قائمة التقييمات
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ReviewCard(
                userName: 'User ${index + 1}',
                rating: 4.0 + (index % 2) * 0.5,
                date: DateTime.now().subtract(Duration(days: index * 5)),
                comment: 'This is a great product! I really like it and would recommend it to others.',
                isVerifiedPurchase: index % 2 == 0,
              );
            },
          ),
        ],
      ),
    );
  }

  // بناء المنتجات ذات الصلة
  Widget _buildRelatedProducts(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.relatedProducts,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // قائمة المنتجات ذات الصلة
          SizedBox(
            height: context.responsiveHeight(220),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: context.responsiveWidthRatio(0.4) * context.screenWidth,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة المنتج
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          'https://via.placeholder.com/150',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // معلومات المنتج
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Related Product ${index + 1}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.currencySymbol} ${(50.0 + index * 10).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStars(rating: 4.0 + (index % 2) * 0.5, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '(${30 + index * 5})',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // بناء شريط التنقل السفلي
  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n) {
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
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: Text(l10n.addToWishlist),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart),
              label: Text(l10n.addToCart),
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
}

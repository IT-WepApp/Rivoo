import 'package:flutter/material.dart';
import 'package:shared_libs/theme/app_theme.dart'; // Updated import
// Updated import to use ProductDetails
import 'package:user_app/features/product_details/domain/entities/product_details.dart'; 
import 'package:shared_libs/entities/rating_entity.dart'; // Assuming RatingEntity is in shared_libs
import 'package:user_app/features/product_details/presentation/widgets/rating_stars.dart';
import 'package:user_app/features/product_details/presentation/widgets/interactive_rating_stars.dart';
import 'package:user_app/features/products/domain/product_status.dart'; // Keep this for status enum

/// شاشة تفاصيل المنتج
class ProductDetailsScreen extends StatefulWidget {
  /// معرف المنتج
  final String productId;

  /// إنشاء شاشة تفاصيل المنتج
  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Use ProductDetails type
  late ProductDetails _product;
  // Assuming RatingEntity is the unified type
  late List<RatingEntity> _ratings; 
  bool _isLoading = true;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  /// تحميل تفاصيل المنتج
  Future<void> _loadProductDetails() async {
    // في الواقع، سيتم استدعاء واجهة برمجة التطبيقات لجلب تفاصيل المنتج
    // هذا مجرد تنفيذ وهمي لأغراض العرض
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      // بيانات وهمية للمنتج (Using ProductDetails)
      _product = ProductDetails(
        id: widget.productId,
        name: 'سماعات لاسلكية فاخرة',
        description: 'سماعات لاسلكية عالية الجودة مع إلغاء الضوضاء النشط وعمر بطارية يصل إلى 30 ساعة. تتميز بتصميم مريح وصوت نقي وواضح.',
        price: 299.99,
        discountPrice: 249.99,
        imageUrl: 'https://via.placeholder.com/300/CCCCCC/FFFFFF?text=Product1',
        additionalImages: [
          'https://via.placeholder.com/300/CCCCCC/FFFFFF?text=Product1',
          'https://via.placeholder.com/300/92c952/FFFFFF?text=Product2',
          'https://via.placeholder.com/300/771796/FFFFFF?text=Product3',
        ],
        categoryId: 'electronics-headphones',
        status: ProductStatus.available,
        rating: 4.5,
        reviewCount: 128,
        quantity: 50,
        inStock: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        tags: ['wireless', 'noise-cancelling', 'audio'],
        isFeatured: true,
      );
      
      // بيانات وهمية للتقييمات (Using RatingEntity)
      _ratings = [
        RatingEntity(
          id: '1',
          productId: widget.productId,
          userId: 'user1',
          rating: 5.0,
          // Assuming RatingEntity might not have a title, adjust if needed
          // title: 'ممتاز!', 
          comment: 'جودة صوت رائعة وعمر بطارية طويل.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        RatingEntity(
          id: '2',
          productId: widget.productId,
          userId: 'user2',
          rating: 4.0,
          // title: 'جيد جدًا', 
          comment: 'سماعات رائعة، لكن السعر مرتفع قليلاً.',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // إضافة إلى المفضلة
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // مشاركة المنتج
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صور المنتج
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: _product.additionalImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    _product.additionalImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // مؤشرات الصور
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _product.additionalImages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedImageIndex == index
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج والتقييم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _product.name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Row(
                        children: [
                          RatingStars(
                            rating: _product.rating,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_product.reviewCount})',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // السعر (Using isOnSale and actualPrice getters)
                  Row(
                    children: [
                      if (_product.isOnSale) ...[
                        Text(
                          '\$${_product.actualPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            // Using discountPercentage getter
                            
'-${_product.discountPercentage!.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          '\$${_product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // الحالة (Using isAvailable getter)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _product.isAvailable
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _product.isAvailable ? 'متوفر' : 'غير متوفر',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الكمية المتوفرة: ${_product.quantity}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // الكمية
                  Row(
                    children: [
                      Text(
                        'الكمية:',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        // Check against product quantity
                        onPressed: _quantity < _product.quantity 
                            ? () {
                                setState(() {
                                  _quantity++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // الوصف
                  Text(
                    'الوصف',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // التقييمات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التقييمات (${_ratings.length})',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      TextButton(
                        onPressed: () {
                          // عرض جميع التقييمات
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  
                  // قائمة التقييمات (Using RatingEntity)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ratings.length,
                    itemBuilder: (context, index) {
                      final rating = _ratings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Assuming RatingEntity might not have a title
                                  // Text(
                                  //   rating.title,
                                  //   style: const TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  // Placeholder for user name if available
                                  Text(
                                    'User ${rating.userId.substring(0,4)}...',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  RatingStars(
                                    rating: rating.rating,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(rating.comment ?? ''), // Use comment from RatingEntity
                              const SizedBox(height: 4),
                              Text(
                                '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // إضافة تقييم
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أضف تقييمك',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          const SizedBox(height: 8),
                          InteractiveRatingStars(
                            initialRating: 0,
                            onRatingChanged: (rating) {
                              // Handle rating change
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'اكتب تعليقك هنا...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (comment) {
                              // Handle comment change
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // إرسال التقييم
                            },
                            child: const Text('إرسال التقييم'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _product.isAvailable
              ? () {
                  // إضافة إلى السلة
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('إضافة إلى السلة'),
        ),
      ),
    );
  }
}


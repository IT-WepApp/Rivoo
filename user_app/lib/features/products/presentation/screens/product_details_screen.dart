import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/ratings/ratings.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام مزود متوسط تقييم المنتج
    final averageRatingAsync = ref.watch(productRatingProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج والمعلومات الأساسية
            // ...

            // قسم التقييمات
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'التقييمات والمراجعات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // الانتقال إلى صفحة جميع المراجعات
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductReviewsScreen(
                                productId: productId,
                                productName:
                                    'اسم المنتج', // استبدل بالاسم الفعلي
                              ),
                            ),
                          );
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // عرض متوسط التقييم
                  averageRatingAsync.when(
                    data: (averageRating) {
                      return Row(
                        children: [
                          RatingStars(
                            rating: averageRating,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('غير متوفر'),
                  ),

                  const SizedBox(height: 16),

                  // زر إضافة تقييم
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.star_outline),
                      label: const Text('إضافة تقييم'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReviewScreen(
                              targetId: productId,
                              targetType: 'product',
                              targetName: 'اسم المنتج', // استبدل بالاسم الفعلي
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // باقي محتوى الصفحة
            // ...
          ],
        ),
      ),
    );
  }
}

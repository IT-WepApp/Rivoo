import 'package:flutter/material.dart';
import 'package:user_app/package/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/features/products/presentation/widgets/product_card.dart';
import 'package:user_app/features/categories/presentation/widgets/category_card.dart';
import '../widgets/banner_slider.dart';
import '../widgets/section_title.dart';

/// شاشة الصفحة الرئيسية
class HomeScreen extends StatefulWidget {
  /// إنشاء شاشة الصفحة الرئيسية
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // التنقل إلى شاشة البحث
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // التنقل إلى شاشة الإشعارات
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // تحديث البيانات
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: [
            // شريط البانر
            const BannerSlider(),
            
            // قسم الفئات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SectionTitle(
                title: localizations.categories,
                onSeeAllPressed: () {
                  // التنقل إلى شاشة جميع الفئات
                },
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: 10, // عدد الفئات
                itemBuilder: (context, index) {
                  return CategoryCard(
                    id: 'category_$index',
                    name: 'فئة ${index + 1}',
                    imageUrl: 'https://picsum.photos/200?random=$index',
                    onTap: () {
                      // التنقل إلى شاشة المنتجات في هذه الفئة
                    },
                  );
                },
              ),
            ),
            
            // قسم المنتجات المميزة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SectionTitle(
                title: localizations.featuredProducts,
                onSeeAllPressed: () {
                  // التنقل إلى شاشة جميع المنتجات المميزة
                },
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4, // عدد المنتجات المميزة
              itemBuilder: (context, index) {
                return ProductCard(
                  id: 'product_$index',
                  name: 'منتج ${index + 1}',
                  price: '${(index + 1) * 100}',
                  imageUrl: 'https://picsum.photos/300/400?random=${index + 10}',
                  discountPercentage: index % 2 == 0 ? 10 : null,
                  rating: 4.5,
                  onTap: () {
                    // التنقل إلى شاشة تفاصيل المنتج
                  },
                  onAddToCart: () {
                    // إضافة المنتج إلى سلة التسوق
                  },
                  onAddToFavorites: () {
                    // إضافة المنتج إلى المفضلة
                  },
                );
              },
            ),
            
            // قسم المنتجات الجديدة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SectionTitle(
                title: localizations.newArrivals,
                onSeeAllPressed: () {
                  // التنقل إلى شاشة جميع المنتجات الجديدة
                },
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4, // عدد المنتجات الجديدة
              itemBuilder: (context, index) {
                return ProductCard(
                  id: 'new_product_$index',
                  name: 'منتج جديد ${index + 1}',
                  price: '${(index + 1) * 150}',
                  imageUrl: 'https://picsum.photos/300/400?random=${index + 20}',
                  isNew: true,
                  rating: 4.0,
                  onTap: () {
                    // التنقل إلى شاشة تفاصيل المنتج
                  },
                  onAddToCart: () {
                    // إضافة المنتج إلى سلة التسوق
                  },
                  onAddToFavorites: () {
                    // إضافة المنتج إلى المفضلة
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

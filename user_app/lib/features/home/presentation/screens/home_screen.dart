import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/products/domain/product.dart';
import 'package:user_app/features/products/presentation/widgets/product_card.dart';
import 'package:user_app/features/categories/presentation/widgets/category_card.dart';
import 'package:user_app/features/home/presentation/widgets/banner_slider.dart';
import 'package:user_app/features/home/presentation/widgets/section_title.dart';
import 'package:user_app/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    );
  }
  
  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context, l10n),
          _buildSearchBar(context, l10n),
          _buildBannerSlider(context),
          _buildCategoriesSection(context, l10n, isMobile: true),
          _buildPopularProductsSection(context, l10n, isMobile: true),
          _buildNewArrivalsSection(context, l10n, isMobile: true),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _buildSearchBar(context, l10n)),
              ],
            ),
          ),
          _buildBannerSlider(context),
          _buildCategoriesSection(context, l10n, isMobile: false),
          _buildPopularProductsSection(context, l10n, isMobile: false),
          _buildNewArrivalsSection(context, l10n, isMobile: false),
        ],
      ),
    );
  }
  
  // بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // القائمة الجانبية
        Container(
          width: 250,
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'RivooSy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSidebarItem(
                context,
                icon: Icons.home,
                title: l10n.home,
                isSelected: true,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.category,
                title: l10n.categories,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.shopping_cart,
                title: l10n.cart,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.list_alt,
                title: l10n.orders,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.favorite,
                title: l10n.wishlist,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.person,
                title: l10n.profile,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.settings,
                title: l10n.settings,
                onTap: () {},
              ),
              const Spacer(),
              _buildSidebarItem(
                context,
                icon: Icons.help,
                title: l10n.help,
                onTap: () {},
              ),
              _buildSidebarItem(
                context,
                icon: Icons.logout,
                title: l10n.logout,
                onTap: () {},
              ),
            ],
          ),
        ),
        
        // المحتوى الرئيسي
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildSearchBar(context, l10n)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Text('U'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBannerSlider(context),
                  _buildCategoriesSection(context, l10n, isMobile: false),
                  _buildPopularProductsSection(context, l10n, isMobile: false),
                  _buildNewArrivalsSection(context, l10n, isMobile: false),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // بناء عنصر القائمة الجانبية
  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: isSelected
              ? Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // بناء شريط التطبيق
  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RivooSy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
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
  
  // بناء شريط البحث
  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }
  
  // بناء شريط البانر
  Widget _buildBannerSlider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: BannerSlider(
        height: context.responsiveHeight(180),
      ),
    );
  }
  
  // بناء قسم التصنيفات
  Widget _buildCategoriesSection(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isMobile,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: l10n.categories,
            onSeeAllPressed: () {},
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: context.responsiveHeight(120),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CategoryCard(
                    name: 'Category ${index + 1}',
                    imageUrl: 'https://via.placeholder.com/100',
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // بناء قسم المنتجات الشائعة
  Widget _buildPopularProductsSection(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isMobile,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: l10n.popular,
            onSeeAllPressed: () {},
          ),
          const SizedBox(height: 16),
          ResponsiveBuilder(
            mobileBuilder: (context) => _buildProductGrid(context, 2),
            smallTabletBuilder: (context) => _buildProductGrid(context, 3),
            largeTabletBuilder: (context) => _buildProductGrid(context, 4),
            desktopBuilder: (context) => _buildProductGrid(context, 5),
          ),
        ],
      ),
    );
  }
  
  // بناء قسم المنتجات الجديدة
  Widget _buildNewArrivalsSection(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isMobile,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: l10n.newArrivals,
            onSeeAllPressed: () {},
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: context.responsiveHeight(260),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: context.responsiveWidthRatio(0.6) * context.screenWidth,
                    child: ProductCard(
                      product: Product(
                        id: 'product-$index',
                        name: 'Product ${index + 1}',
                        description: 'Product description',
                        price: (index + 1) * 10.0,
                        imageUrl: 'https://via.placeholder.com/150',
                        rating: 4.5,
                        reviewCount: 120,
                      ),
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // بناء شبكة المنتجات
  Widget _buildProductGrid(BuildContext context, int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return ProductCard(
            product: Product(
              id: 'popular-$index',
              name: 'Popular Product ${index + 1}',
              description: 'Product description',
              price: (index + 1) * 15.0,
              imageUrl: 'https://via.placeholder.com/150',
              rating: 4.5,
              reviewCount: 120,
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}

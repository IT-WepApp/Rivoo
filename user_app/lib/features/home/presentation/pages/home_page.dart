import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/products/providers/product_notifier.dart';
import 'package:shared_libs/widgets/widgets .dart';
import 'package:shared_libs/models/models.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/features/cart/providers/cart_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _searchText = '';
  String? _selectedCategory;
  final _searchController = TextEditingController();

  final List<String> _placeholderCategories = [
    'All',
    'Electronics',
    'Clothing',
    'Home',
    'Books'
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to update search text state
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(allProductsProvider);

    ref.listen<AsyncValue<List<Product>>>(allProductsProvider,
        (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading products: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    label: 'Search',
                    hintText: 'Search products...',
                    prefixIcon: Icons.search,
                    // Removed onChanged, using controller listener instead
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: const Text('Category'),
                  items: _placeholderCategories
                      .map((cat) => DropdownMenuItem(
                          value: cat == 'All' ? null : cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: productsAsyncValue.when(
              data: (products) {
                final filteredProducts = products.where((p) {
                  final categoryMatch = _selectedCategory == null ||
                      (p.categoryId.toLowerCase() ==
                          _selectedCategory!.toLowerCase());
                  final searchMatch = _searchText.isEmpty ||
                      p.name.toLowerCase().contains(_searchText);
                  return categoryMatch && searchMatch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                      child: Text('No products found matching your criteria.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(allProductsProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(product: product);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading products: $error'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () => ref.refresh(allProductsProvider),
                        child: const Text('Retry'))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartNotifier = ref.read(cartProvider.notifier);

    return AppCard(
      child: InkWell(
        onTap: () {
          context.go('/home/store/${product.sellerId}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.grey)),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    // Use ElevatedButton.icon if icon is needed
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart,
                          size: 16), // Standard icon usage
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8), // Adjust padding for size
                          textStyle: theme.textTheme
                              .labelSmall // Apply text style if needed
                          ),
                      onPressed: () {
                        cartNotifier.addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${product.name} added to cart.'),
                              duration: const Duration(seconds: 1)),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

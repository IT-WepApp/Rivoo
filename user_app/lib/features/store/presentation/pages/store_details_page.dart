import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart';
import 'package:shared_libs/services/services.dart';
import 'package:shared_libs/widgets/widgets .dart';
import '../../../cart/providers/cart_notifier.dart';
import '../../../products/providers/product_notifier.dart';
import 'package:user_app/features/auth/providers/auth_notifier.dart';

class StoreDetailsPage extends ConsumerWidget {
  final String storeId;

  const StoreDetailsPage({super.key, required this.storeId});

  static final storeDetailsProvider =
      FutureProvider.autoDispose.family<StoreModel?, String>((ref, storeId) {
    final storeService = ref.watch(storeServiceProvider);
    return storeService.getStoreDetails(storeId);
  });

  Future<void> _addToCart(
      WidgetRef ref, BuildContext context, Product product) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.addItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${product.name} added to cart!'),
          duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeDetailsAsync = ref.watch(storeDetailsProvider(storeId));
    final productsAsync = ref.watch(productsByStoreProvider(storeId));
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
        body: storeDetailsAsync.when(
      data: (storeData) {
        if (storeData == null) {
          return const Center(child: Text('Store not found.'));
        }
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text(storeData.name),
              backgroundColor: primaryColor,
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: storeData.imageUrl != null &&
                        storeData.imageUrl!.isNotEmpty
                    ? Image.network(
                        storeData.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child:
                                    Icon(Icons.storefront, color: Colors.grey)),
                      )
                    : Container(color: secondaryColor),
              ),
            ),
            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No products available in this store yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final product = products[index];
                        // Removed unused priceString
                        // final priceString = product.price.toStringAsFixed(2);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: AppCard(
                            child: ListTile(
                              leading: product.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        product.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                    Icons.image_not_supported,
                                                    size: 60),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Icon(Icons.shopping_bag)),
                              title: Text(product.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              subtitle: Text(
                                  'Price: \$${product.price.toStringAsFixed(2)}'), // Use directly
                              trailing: AppButton(
                                onPressed: () =>
                                    _addToCart(ref, context, product),
                                text: 'Add',
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error loading products: $err'))),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading store details: $err')),
    ));
  }
}

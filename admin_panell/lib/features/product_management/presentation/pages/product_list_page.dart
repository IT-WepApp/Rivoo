import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // Added import
import '../../application/product_management_notifier.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  String _searchText = '';
  final _searchController = TextEditingController();

  // Example filter options - Consider fetching categories dynamically
  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected'
  ]; // Assuming these statuses are used
  final List<String> _categoryOptions = [
    'All',
    'Electronics',
    'Clothing',
    'Food'
  ]; // Placeholder - fetch dynamically if possible

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider which now returns AsyncValue<List<Product>>
    final productsState = ref.watch(productManagementProvider);

    // Listen for errors
    ref.listen<AsyncValue<List<Product>>>(productManagementProvider,
        (previous, next) {
      // Changed ProductModel to Product
      if (next is AsyncError && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Product Management')),
      body: Column(
        children: [
          _buildFilterAndSearchBar(context),
          Expanded(
            child: productsState.when(
              data: (products) => _buildProductList(products, ref),
              error: (error, stackTrace) => Center(
                  child: Text(
                      'Failed to load products. Pull down to retry. Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products by name, description...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Status Filter Dropdown
              DropdownButton<String>(
                value: _selectedStatus,
                hint: const Text("Status Filter"),
                items: _statusOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue ?? 'All';
                  });
                },
              ),
              // Category Filter Dropdown (Optional)
              DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text("Category Filter"),
                items: _categoryOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue ?? 'All';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products, WidgetRef ref) {
    // Changed ProductModel to Product
    // Apply filters and search locally
    final filteredProducts = products.where((product) {
      // Check Product model for status field nullability
      // Assuming product.status might exist but isn't modeled yet or is nullable
      final statusMatch = _selectedStatus ==
          'All'; // Implement actual status filtering based on model

      // Check Product model for categoryId field nullability (it's required)
      final categoryMatch = _selectedCategory ==
          'All'; // Implement category filtering based on actual categories

      // name is required, description is required in Product model
      final searchMatch = _searchText.isEmpty ||
          (product.name.toLowerCase().contains(_searchText)) ||
          (product.description
              .toLowerCase()
              .contains(_searchText)); // description is not nullable

      // Combine matches - adjust logic based on actual model fields and desired filtering
      return statusMatch && categoryMatch && searchMatch;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(child: Text('No products match the criteria.'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(productManagementProvider.notifier).fetchProducts(),
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index]; // Type is Product
          return ProductListItem(
            product: product,
            // product.id is not nullable in the Product model
            onApprove: () => ref
                .read(productManagementProvider.notifier)
                .approveProduct(product.id),
            onReject: () => ref
                .read(productManagementProvider.notifier)
                .rejectProduct(product.id),
            onEdit: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Edit action for ${product.name} (TODO)')),
              );
            },
          );
        },
      ),
    );
  }
}

// Changed ProductModel to Product
class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                // imageUrl is not nullable in Product model
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name is not nullable
                  Text(product.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // price is not nullable
                  Text('Price: \$${product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  // categoryId is not nullable - Consider fetching category name based on ID
                  Text('Category ID: ${product.categoryId}'),
                  const SizedBox(height: 6),
                  // Status field needs to be added to Product model if needed for display/filtering
                  Chip(
                    // Check if product.status exists and handle nullability
                    label: const Text(
                        'Status Placeholder'), // Placeholder - Update based on actual status field
                    backgroundColor: Colors.grey.shade200, // Default color
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    labelStyle: const TextStyle(fontSize: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  tooltip: 'Approve',
                  // Check product status before enabling/disabling
                  onPressed:
                      onApprove, // Add logic based on actual status field
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  tooltip: 'Reject',
                  // Check product status before enabling/disabling
                  onPressed: onReject, // Add logic based on actual status field
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // This function needs adjustment based on the actual status field in Product model
}

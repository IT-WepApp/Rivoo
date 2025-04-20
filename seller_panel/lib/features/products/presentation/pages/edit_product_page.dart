import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../application/products_notifier.dart'; // تأكد أن هذا هو المسار الصحيح
import 'package:shared_models/shared_models.dart'; // تأكد أن Product موجود هنا

final initialProductProvider = FutureProvider.autoDispose.family<Product?, String>((ref, productId) async {
  final productListState = ref.watch(sellerProductsProvider);
  final products = productListState.value;
  if (products == null) return null;
  for (final p in products) {
    if (p.id == productId) return p;
  }
  return null;
});


class EditProductPage extends ConsumerStatefulWidget {
  final String productId;
  const EditProductPage({super.key, required this.productId});

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  final List<String> _placeholderCategories = ['Electronics', 'Clothing', 'Home', 'Books'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  void _initializeControllers(Product product) {
    if (!_isInitialized) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _imageUrlController.text = product.imageUrl;
      _selectedCategory = product.categoryId;
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(Product originalProduct) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final updatedProduct = originalProduct.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? originalProduct.price,
      categoryId: _selectedCategory,
      imageUrl: _imageUrlController.text.trim(),
    );

    final success = await ref.read(sellerProductsProvider.notifier).editProduct(updatedProduct);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully.'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update product.'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialProductAsync = ref.watch(initialProductProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: initialProductAsync.when(
        data: (product) {
          if (product == null) return const Center(child: Text('Product not found.'));
          _initializeControllers(product);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Product Name',
                    validator: (v) => v == null || v.isEmpty ? 'Please enter the product name.' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 4,
                    validator: (v) => v == null || v.isEmpty ? 'Please enter the description.' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _priceController,
                          label: 'Price',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter the price.';
                            if (double.tryParse(v) == null) return 'Invalid number.';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          hint: const Text('Category'),
                          items: _placeholderCategories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          validator: (v) => v == null ? 'Please select a category.' : null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _imageUrlController,
                    label: 'Image URL (Optional)',
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && Uri.tryParse(v)?.isAbsolute != true) {
                        return 'Please enter a valid URL.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton(
                          onPressed: () => _submitForm(product),
                          text: 'Save Changes',
                        ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error loading product data: $error')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../application/products_notifier.dart'; // تأكد من أن هذا هو المسار الصحيح
import 'package:shared_models/shared_models.dart'; // تأكد أن Product موجود هنا

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newProduct = Product(
      id: '', // Firebase سيولد ID
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      imageUrl: _imageUrlController.text.trim(),
      categoryId: _selectedCategory ?? '',
      sellerId: '', // سيتم إضافته تلقائيًا في notifier
      hasPromotion: false,
    );

    final success = await ref.read(sellerProductsProvider.notifier).addProduct(newProduct);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully, pending approval.'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add product. Please check logs.'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> placeholderCategories = ['Electronics', 'Clothing', 'Home', 'Books'];

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: (value) => value == null || value.isEmpty ? 'Please enter the product name.' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Please enter the description.' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      label: 'Price',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter the price.';
                        if (double.tryParse(value) == null) return 'Please enter a valid number.';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text('Category'),
                      items: placeholderCategories
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      validator: (value) => value == null ? 'Please select a category.' : null,
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
                validator: (value) {
                  if (value != null && value.isNotEmpty && Uri.tryParse(value)?.isAbsolute != true) {
                    return 'Please enter a valid URL.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      onPressed: _submitForm,
                      text: 'Add Product for Review',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

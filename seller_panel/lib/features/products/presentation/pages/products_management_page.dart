import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/product_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'package:shared_libs/theme/app_colors.dart';

/// صفحة إدارة المنتجات للبائع
class ProductsManagementPage extends ConsumerStatefulWidget {
  const ProductsManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsManagementPage> createState() =>
      _ProductsManagementPageState();
}

class _ProductsManagementPageState extends ConsumerState<ProductsManagementPage> {
  late TextEditingController _searchController; // << إضافة الكنترولر

  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<String> _categories = ['الكل'];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // << تهيئة الكنترولر
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose(); // << التخلص من الكنترولر
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);
      final products = await productService.getSellerProducts();

      final uniqueCategories = <String>{};
      for (final product in products) {
        final category = product['category'] as String? ?? 'أخرى';
        uniqueCategories.add(category);
      }

      setState(() {
        _products = products;
        _categories = ['الكل', ...uniqueCategories.toList()..sort()];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل المنتجات: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    return _products.where((product) {
      final name = product['name'] as String? ?? '';
      final description = product['description'] as String? ?? '';
      final matchesSearch = _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          description.toLowerCase().contains(_searchQuery.toLowerCase());

      final category = product['category'] as String? ?? 'أخرى';
      final matchesCategory =
          _selectedCategory == 'الكل' || category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _toggleProductAvailability(String productId, bool currentValue) async {
    try {
      final productService = ref.read(productServiceProvider);
      await productService.toggleProductAvailability(productId, !currentValue);

      setState(() {
        final index = _products.indexWhere((p) => p['id'] == productId);
        if (index != -1) {
          _products[index]['isAvailable'] = !currentValue;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentValue ? 'تم تفعيل المنتج بنجاح' : 'تم إلغاء تفعيل المنتج بنجاح',
            ),
            backgroundColor: !currentValue ? AppColors.success : AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await AppWidgets.showConfirmDialog(
      context: context,
      title: 'حذف المنتج',
      message: 'هل أنت متأكد من رغبتك في حذف هذا المنتج؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      confirmColor: Colors.red,
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        final productService = ref.read(productServiceProvider);
        await productService.deleteProduct(productId);

        setState(() {
          _products.removeWhere((p) => p['id'] == productId);
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المنتج بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف المنتج: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(theme),
          Expanded(
            child: _isLoading
                ? AppWidgets.loadingIndicator(message: 'جاري تحميل المنتجات...')
                : _errorMessage.isNotEmpty
                    ? AppWidgets.errorMessage(
                        message: _errorMessage,
                        onRetry: _loadProducts,
                      )
                    : _buildProductsList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteConstants.addProduct),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          AppWidgets.searchBar(
            controller: _searchController,
            hintText: 'البحث عن منتج...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
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

  Widget _buildProductsList(ThemeData theme) {
    final products = filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'الكل'
                  ? 'لا توجد منتجات تطابق معايير البحث'
                  : 'لا توجد منتجات حالياً',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            AppWidgets.appButton(
              text: 'إضافة منتج جديد',
              onPressed: () => context.push(RouteConstants.addProduct),
              icon: Icons.add,
              backgroundColor: theme.colorScheme.primary,
              textColor: theme.colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(theme, product);
        },
      ),
    );
  }

  Widget _buildProductItem(ThemeData theme, Map<String, dynamic> product) {
    final id = product['id'] as String? ?? '';
    final name = product['name'] as String? ?? '';
    final price = product['price'] as num? ?? 0;
    final imageUrl = product['imageUrl'] as String? ?? '';
    final category = product['category'] as String? ?? 'أخرى';
    final isAvailable = product['isAvailable'] as bool? ?? true;
    final stockQuantity = product['stockQuantity'] as int? ?? 0;

    return AppWidgets.appCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          if (imageUrl.isNotEmpty)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            )
          else
            Container(
              height: 150,
              width: double.infinity,
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.image,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isAvailable ? AppColors.success : AppColors.error,
                        ),
                      ),
                      child: Text(
                        isAvailable ? 'متاح' : 'غير متاح',
                        style: TextStyle(
                          color: isAvailable ? AppColors.success : AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${price.toStringAsFixed(2)} ر.س',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'المخزون: $stockQuantity',
                      style: TextStyle(
                        color: stockQuantity > 0 ? Colors.black : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: AppWidgets.appButton(
                        text: 'تعديل',
                        onPressed: () => context.push('${RouteConstants.editProduct}/$id'),
                        icon: Icons.edit,
                        backgroundColor: Colors.white,
                        textColor: theme.colorScheme.primary,
                        borderColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppWidgets.appButton(
                        text: isAvailable ? 'إخفاء' : 'إظهار',
                        onPressed: () => _toggleProductAvailability(id, isAvailable),
                        icon: isAvailable ? Icons.visibility_off : Icons.visibility,
                        backgroundColor: Colors.white,
                        textColor: isAvailable ? AppColors.warning : AppColors.success,
                        borderColor: isAvailable ? AppColors.warning : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppWidgets.appButton(
                        text: 'حذف',
                        onPressed: () => _deleteProduct(id),
                        icon: Icons.delete,
                        backgroundColor: Colors.white,
                        textColor: AppColors.error,
                        borderColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

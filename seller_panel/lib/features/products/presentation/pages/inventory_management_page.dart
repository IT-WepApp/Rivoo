import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/product_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/theme/app_colors.dart';

/// صفحة إدارة المخزون والأسعار
class InventoryManagementPage extends ConsumerStatefulWidget {
  const InventoryManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryManagementPage> createState() =>
      _InventoryManagementPageState();
}

class _InventoryManagementPageState
    extends ConsumerState<InventoryManagementPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  List<String> _categories = ['الكل'];

  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);
      final products = await productService.getSellerProducts();

      // استخراج الفئات الفريدة
      final uniqueCategories = <String>{'الكل'};
      for (final product in products) {
        final category = product['category'] as String? ?? 'أخرى';
        uniqueCategories.add(category);
      }

      setState(() {
        _products = products;
        _categories = uniqueCategories.toList()..sort();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل المنتجات: $e';
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_products);

    // تطبيق فلتر البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product['name'] as String? ?? '';
        final description = product['description'] as String? ?? '';
        final searchLower = _searchQuery.toLowerCase();

        return name.toLowerCase().contains(searchLower) ||
            description.toLowerCase().contains(searchLower);
      }).toList();
    }

    // تطبيق فلتر الفئة
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((product) {
        final category = product['category'] as String? ?? 'أخرى';
        return category == _selectedCategory;
      }).toList();
    }

    // تطبيق الترتيب
    filtered.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (_sortBy) {
        case 'name':
          valueA = a['name'] as String? ?? '';
          valueB = b['name'] as String? ?? '';
          break;
        case 'price':
          valueA = a['price'] as num? ?? 0;
          valueB = b['price'] as num? ?? 0;
          break;
        case 'stock':
          valueA = a['stockQuantity'] as int? ?? 0;
          valueB = b['stockQuantity'] as int? ?? 0;
          break;
        default:
          valueA = a['name'] as String? ?? '';
          valueB = b['name'] as String? ?? '';
      }

      if (valueA is String && valueB is String) {
        return _sortAscending
            ? valueA.compareTo(valueB)
            : valueB.compareTo(valueA);
      } else if (valueA is num && valueB is num) {
        return _sortAscending
            ? valueA.compareTo(valueB)
            : valueB.compareTo(valueA);
      }

      return 0;
    });

    setState(() {
      _filteredProducts = filtered;
    });
  }

  Future<void> _updateProductStock(String productId, int newStock) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);
      await productService.updateProduct(
        productId,
        {'stockQuantity': newStock},
      );

      // تحديث القائمة المحلية
      setState(() {
        final productIndex = _products.indexWhere((p) => p['id'] == productId);
        if (productIndex != -1) {
          _products[productIndex]['stockQuantity'] = newStock;
        }

        _applyFilters();
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المخزون بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث المخزون: $e';
      });
    }
  }

  Future<void> _updateProductPrice(String productId, double newPrice) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);

      // الحصول على بيانات المنتج الحالية
      final productIndex = _products.indexWhere((p) => p['id'] == productId);
      if (productIndex == -1) {
        throw Exception('المنتج غير موجود');
      }

      final product = _products[productIndex];
      final hasDiscount = product['hasDiscount'] as bool? ?? false;

      // تحديث السعر والسعر بعد الخصم إذا كان هناك خصم
      final updateData = {'price': newPrice};

      if (hasDiscount) {
        final discountPercentage =
            product['discountPercentage'] as double? ?? 0;
        final discountedPrice = newPrice * (1 - discountPercentage / 100);
        updateData['discountedPrice'] = discountedPrice;
      }

      await productService.updateProduct(productId, updateData);

      // تحديث القائمة المحلية
      setState(() {
        _products[productIndex]['price'] = newPrice;

        if (hasDiscount) {
          final discountPercentage =
              product['discountPercentage'] as double? ?? 0;
          _products[productIndex]['discountedPrice'] =
              newPrice * (1 - discountPercentage / 100);
        }

        _applyFilters();
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث السعر بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث السعر: $e';
      });
    }
  }

  Future<void> _updateProductAvailability(
      String productId, bool isAvailable) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);
      await productService.updateProduct(
        productId,
        {'isAvailable': isAvailable},
      );

      // تحديث القائمة المحلية
      setState(() {
        final productIndex = _products.indexWhere((p) => p['id'] == productId);
        if (productIndex != -1) {
          _products[productIndex]['isAvailable'] = isAvailable;
        }

        _applyFilters();
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAvailable
                ? 'تم تفعيل المنتج بنجاح'
                : 'تم تعطيل المنتج بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث حالة المنتج: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون والأسعار'),
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
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل المنتجات...')
          : _isSubmitting
              ? AppWidgets.loadingIndicator(message: 'جاري تنفيذ العملية...')
              : _errorMessage.isNotEmpty && _products.isEmpty
                  ? AppWidgets.errorMessage(
                      message: _errorMessage,
                      onRetry: _loadProducts,
                    )
                  : Column(
                      children: [
                        // أدوات البحث والفلترة
                        _buildFilterBar(theme),

                        // رسالة الخطأ
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error),
                            ),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),

                        // قائمة المنتجات
                        Expanded(
                          child: _buildProductsList(theme),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط البحث
          TextField(
            decoration: InputDecoration(
              hintText: 'البحث عن منتج...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 16),

          // فلاتر إضافية
          Row(
            children: [
              // فلتر الفئة
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        _applyFilters();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),

              // فلتر الترتيب
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'ترتيب حسب',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'name',
                      child: Text('الاسم'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'price',
                      child: Text('السعر'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'stock',
                      child: Text('المخزون'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                        _applyFilters();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // زر تبديل اتجاه الترتيب
              IconButton(
                icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFilters();
                  });
                },
                tooltip: _sortAscending ? 'ترتيب تصاعدي' : 'ترتيب تنازلي',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ThemeData theme) {
    if (_filteredProducts.isEmpty) {
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
            ElevatedButton.icon(
              onPressed: () => context.push(RouteConstants.addProduct),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final productId = product['id'] as String;
        final name = product['name'] as String? ?? 'منتج بدون اسم';
        final imageUrl = product['imageUrl'] as String? ?? '';
        final price = product['price'] as num? ?? 0;
        final stockQuantity = product['stockQuantity'] as int? ?? 0;
        final isAvailable = product['isAvailable'] as bool? ?? true;
        final hasDiscount = product['hasDiscount'] as bool? ?? false;
        final discountedPrice = product['discountedPrice'] as num? ?? price;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المنتج الأساسية
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة المنتج
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    const SizedBox(width: 16),

                    // معلومات المنتج
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // السعر
                          Row(
                            children: [
                              Text(
                                'السعر: ',
                                style: theme.textTheme.bodyMedium,
                              ),
                              if (hasDiscount)
                                Row(
                                  children: [
                                    Text(
                                      '${price.toStringAsFixed(2)} ر.س',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${discountedPrice.toStringAsFixed(2)} ر.س',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  '${price.toStringAsFixed(2)} ر.س',
                                  style: theme.textTheme.bodyMedium,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // المخزون
                          Row(
                            children: [
                              Text(
                                'المخزون: ',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '$stockQuantity',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: stockQuantity > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // حالة المنتج
                          Row(
                            children: [
                              Text(
                                'الحالة: ',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:
                                        isAvailable ? Colors.green : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  isAvailable ? 'متاح' : 'غير متاح',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        isAvailable ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // تعديل المخزون
                    _buildStockControl(theme, productId, stockQuantity),

                    // تعديل السعر
                    _buildPriceControl(theme, productId, price.toDouble()),

                    // تفعيل/تعطيل المنتج
                    _buildAvailabilityControl(theme, productId, isAvailable),
                  ],
                ),

                const SizedBox(height: 16),

                // زر تعديل المنتج
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .push('${RouteConstants.editProduct}/$productId'),
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل المنتج'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockControl(
      ThemeData theme, String productId, int currentStock) {
    return Column(
      children: [
        Text(
          'المخزون',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر تقليل المخزون
            IconButton(
              onPressed: currentStock > 0
                  ? () => _updateProductStock(productId, currentStock - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
            ),

            // عرض المخزون الحالي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$currentStock',
                style: theme.textTheme.titleMedium,
              ),
            ),

            // زر زيادة المخزون
            IconButton(
              onPressed: () => _updateProductStock(productId, currentStock + 1),
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceControl(
      ThemeData theme, String productId, double currentPrice) {
    final priceController =
        TextEditingController(text: currentPrice.toStringAsFixed(2));

    return Column(
      children: [
        Text(
          'السعر',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              suffixText: 'ر.س',
            ),
            onSubmitted: (value) {
              final newPrice = double.tryParse(value);
              if (newPrice != null && newPrice > 0) {
                _updateProductPrice(productId, newPrice);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityControl(
      ThemeData theme, String productId, bool isAvailable) {
    return Column(
      children: [
        Text(
          'الحالة',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Switch(
          value: isAvailable,
          onChanged: (value) => _updateProductAvailability(productId, value),
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

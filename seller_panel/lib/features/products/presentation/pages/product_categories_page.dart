import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/product_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../../../shared_libs/lib/theme/app_colors.dart';

/// صفحة إدارة فئات المنتجات
class ProductCategoriesPage extends ConsumerStatefulWidget {
  const ProductCategoriesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductCategoriesPage> createState() =>
      _ProductCategoriesPageState();
}

class _ProductCategoriesPageState extends ConsumerState<ProductCategoriesPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<String> _categories = [];
  List<Map<String, dynamic>> _products = [];
  String? _selectedCategory;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);
      final products = await productService.getSellerProducts();

      // استخراج الفئات الفريدة
      final uniqueCategories = <String>{};
      for (final product in products) {
        final category = product['category'] as String? ?? 'أخرى';
        uniqueCategories.add(category);
      }

      setState(() {
        _products = products;
        _categories = uniqueCategories.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      });
    }
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newCategory = _categoryController.text.trim();

    // التحقق من عدم وجود الفئة مسبقاً
    if (_categories.contains(newCategory)) {
      setState(() {
        _errorMessage = 'الفئة موجودة بالفعل';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      // إضافة الفئة إلى القائمة المحلية
      setState(() {
        _categories.add(newCategory);
        _categories.sort();
        _categoryController.clear();
        _isSubmitting = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة الفئة "$newCategory" بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل إضافة الفئة: $e';
      });
    }
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    final newCategoryName = _categoryController.text.trim();
    final oldCategoryName = _selectedCategory!;

    // التحقق من عدم وجود الفئة مسبقاً
    if (newCategoryName != oldCategoryName &&
        _categories.contains(newCategoryName)) {
      setState(() {
        _errorMessage = 'الفئة موجودة بالفعل';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);

      // تحديث الفئة في جميع المنتجات التي تستخدمها
      final productsToUpdate = _products.where((product) {
        final productCategory = product['category'] as String?;
        return productCategory != null && productCategory == oldCategoryName;
      }).toList();

      for (final product in productsToUpdate) {
        await productService.updateProduct(
          product['id'] as String,
          {'category': newCategoryName},
        );
      }

      // تحديث القائمة المحلية
      setState(() {
        _categories.remove(oldCategoryName);
        _categories.add(newCategoryName);
        _categories.sort();

        // تحديث المنتجات في القائمة المحلية
        for (final product in _products) {
          final productCategory = product['category'] as String?;
          if (productCategory != null && productCategory == oldCategoryName) {
            product['category'] = newCategoryName;
          }
        }

        _categoryController.clear();
        _selectedCategory = null;
        _isSubmitting = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'تم تحديث الفئة من "$oldCategoryName" إلى "$newCategoryName" بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث الفئة: $e';
      });
    }
  }

  Future<void> _deleteCategory(String category) async {
    // التحقق من عدم وجود منتجات تستخدم هذه الفئة
    final productsUsingCategory = _products.where((product) {
      final productCategory = product['category'] as String?;
      return productCategory != null && productCategory == category;
    }).toList();

    if (productsUsingCategory.isNotEmpty) {
      if (mounted) {
        final confirmed = await AppWidgets.showConfirmDialog(
          context: context,
          title: 'تحذير',
          message:
              'هناك ${productsUsingCategory.length} منتج يستخدم هذه الفئة. هل تريد تغيير فئة هذه المنتجات إلى "أخرى"؟',
          confirmText: 'نعم، تغيير الفئة',
          cancelText: 'إلغاء',
          isDangerous: true,
        );

        if (!confirmed) {
          return;
        }
      } else {
        return;
      }
    } else {
      if (mounted) {
        final confirmed = await AppWidgets.showConfirmDialog(
          context: context,
          title: 'حذف الفئة',
          message: 'هل أنت متأكد من رغبتك في حذف فئة "$category"؟',
          confirmText: 'حذف',
          cancelText: 'إلغاء',
          isDangerous: true,
        );

        if (!confirmed) {
          return;
        }
      } else {
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);

      // تحديث الفئة في جميع المنتجات التي تستخدمها
      for (final product in productsUsingCategory) {
        await productService.updateProduct(
          product['id'] as String,
          {'category': 'أخرى'},
        );
      }

      // تحديث القائمة المحلية
      setState(() {
        _categories.remove(category);

        // تحديث المنتجات في القائمة المحلية
        for (final product in _products) {
          final productCategory = product['category'] as String?;
          if (productCategory != null && productCategory == category) {
            product['category'] = 'أخرى';
          }
        }

        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الفئة "$category" بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل حذف الفئة: $e';
      });
    }
  }

  void _startEditing(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryController.text = category;
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _selectedCategory = null;
      _categoryController.clear();
      _isEditing = false;
      _errorMessage = '';
    });
  }

  List<String> get filteredCategories {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _categories;
    }

    return _categories
        .where((category) => category.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة فئات المنتجات'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل الفئات...')
          : _isSubmitting
              ? AppWidgets.loadingIndicator(message: 'جاري تنفيذ العملية...')
              : Column(
                  children: [
                    // نموذج إضافة/تعديل الفئة
                    _buildCategoryForm(theme),

                    // قائمة الفئات
                    Expanded(
                      child: _buildCategoriesList(theme),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCategoryForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'تعديل الفئة' : 'إضافة فئة جديدة',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // حقل إدخال اسم الفئة
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'اسم الفئة',
                hintText: 'أدخل اسم الفئة',
                border: const OutlineInputBorder(),
                suffixIcon: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _cancelEditing,
                        tooltip: 'إلغاء التعديل',
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم الفئة';
                }
                return null;
              },
            ),

            // رسالة الخطأ
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),

            const SizedBox(height: 16),

            // زر الإضافة/التعديل
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEditing ? _updateCategory : _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(_isEditing ? 'تحديث الفئة' : 'إضافة الفئة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme) {
    return Column(
      children: [
        // شريط البحث
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث عن فئة...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),

        // قائمة الفئات
        Expanded(
          child: filteredCategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'لا توجد فئات تطابق معايير البحث'
                            : 'لا توجد فئات حالياً',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final productCount = _products.where((product) {
                      final productCategory = product['category'] as String?;
                      return productCategory != null &&
                          productCategory == category;
                    }).length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(category),
                        subtitle: Text('عدد المنتجات: $productCount'),
                        leading: const Icon(Icons.category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _startEditing(category),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.error),
                              onPressed: () => _deleteCategory(category),
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_libs/services/product_service.dart';
import 'package:shared_libs/widgets/app_widgets.dart';
import 'package:shared_libs/theme/app_colors.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/product_firebase_datasource.dart';

/// صفحة إضافة منتج جديد
class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockQuantityController = TextEditingController();

  String _selectedCategory = 'أخرى';
  final List<String> _categories = [
    'أخرى',
    'طعام',
    'مشروبات',
    'إلكترونيات',
    'ملابس',
    'أدوات منزلية'
  ];

  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _hasDiscount = false;
  double _discountPercentage = 0;

  // تعديل: استخدام قائمة من الملفات بدلاً من ملف واحد
  final List<File> _imageFiles = [];
  List<String> _imageUrls = [];
  bool _isUploading = false;
  double _uploadProgress = 0;
  int _currentUploadIndex = 0;

  bool _isSubmitting = false;
  String _errorMessage = '';

  // مستودع المنتجات
  late final ProductRepository _productRepository;
  // إضافة مرجع Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // تهيئة مستودع المنتجات
    _productRepository = ProductRepositoryImpl(ProductFirebaseDataSource());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  // تعديل: اختيار صورة واحدة وإضافتها إلى القائمة
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  // تعديل: اختيار عدة صور دفعة واحدة
  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var pickedFile in pickedFiles) {
          _imageFiles.add(File(pickedFile.path));
        }
      });
    }
  }

  // تعديل: حذف صورة من القائمة
  void _removeImage(int index) {
    if (index >= 0 && index < _imageFiles.length) {
      setState(() {
        _imageFiles.removeAt(index);
      });
    }
  }

  // تعديل: رفع جميع الصور
  Future<List<String>> _uploadImages(String productId) async {
    if (_imageFiles.isEmpty) {
      return [];
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _currentUploadIndex = 0;
    });

    try {
      // استخدام مستودع المنتجات لرفع الصور
      List<String> localPaths = _imageFiles.map((file) => file.path).toList();
      List<String> urls =
          await _productRepository.uploadProductImages(productId, localPaths);

      setState(() {
        _isUploading = false;
        _imageUrls = urls;
      });

      return urls;
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'فشل رفع الصور: $e';
      });
      return [];
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFiles.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إضافة صورة واحدة على الأقل للمنتج';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      // إعداد بيانات المنتج
      final priceText = _priceController.text;
      final stockText = _stockQuantityController.text;

      final double price = double.tryParse(priceText) ?? 0.0;
      final int stockQuantity = int.tryParse(stockText) ?? 0;

      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': price,
        'category': _selectedCategory,
        'stockQuantity': stockQuantity,
        'isAvailable': _isAvailable,
        'isFeatured': _isFeatured,
        'imageUrls': <String>[], // سيتم تحديثها بعد رفع الصور
      };

      // إضافة بيانات الخصم إذا كان مفعلاً
      if (_hasDiscount) {
        productData['hasDiscount'] = true;
        productData['discountPercentage'] = _discountPercentage;
        productData['discountedPrice'] =
            price * (1 - _discountPercentage / 100);
      }

      // إضافة المنتج إلى Firestore
      final productService = ref.read(productServiceProvider);
      final productId = await productService.addProduct(productData);

      // رفع الصور بعد إنشاء المنتج
      final imageUrls = await _uploadImages(productId);

      if (imageUrls.isNotEmpty) {
        // تحديث المنتج بروابط الصور
        await _firestore.collection('products').doc(productId).update({
          'imageUrls': imageUrls,
        });
      }

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المنتج بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // العودة إلى صفحة إدارة المنتجات
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل إضافة المنتج: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isSubmitting
          ? AppWidgets.loadingIndicator(message: 'جاري إضافة المنتج...')
          : _buildForm(theme),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // صور المنتج
          _buildImagesPicker(theme),
          const SizedBox(height: 24),

          // معلومات المنتج الأساسية
          Text(
            'معلومات المنتج',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // اسم المنتج
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اسم المنتج *',
              hintText: 'أدخل اسم المنتج',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال اسم المنتج';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // وصف المنتج
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'وصف المنتج *',
              hintText: 'أدخل وصفاً تفصيلياً للمنتج',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال وصف المنتج';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // فئة المنتج
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'فئة المنتج *',
              border: OutlineInputBorder(),
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
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // السعر والمخزون
          Row(
            children: [
              // سعر المنتج
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر *',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    prefixText: 'ر.س ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال السعر';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'يرجى إدخال سعر صحيح';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),

              // كمية المخزون
              Expanded(
                child: TextFormField(
                  controller: _stockQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'المخزون *',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كمية المخزون';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 0) {
                      return 'يرجى إدخال كمية صحيحة';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // خيارات إضافية
          Text(
            'خيارات إضافية',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // توفر المنتج
          SwitchListTile(
            title: const Text('متاح للبيع'),
            subtitle: const Text('يمكن للعملاء رؤية وشراء هذا المنتج'),
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),

          // منتج مميز
          SwitchListTile(
            title: const Text('منتج مميز'),
            subtitle: const Text('سيظهر هذا المنتج في قسم المنتجات المميزة'),
            value: _isFeatured,
            onChanged: (value) {
              setState(() {
                _isFeatured = value;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),

          // خصم على المنتج
          SwitchListTile(
            title: const Text('تطبيق خصم'),
            subtitle: const Text('تطبيق خصم على سعر المنتج الأصلي'),
            value: _hasDiscount,
            onChanged: (value) {
              setState(() {
                _hasDiscount = value;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),

          // نسبة الخصم
          if (_hasDiscount)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'نسبة الخصم: ${_discountPercentage.toStringAsFixed(0)}%'),
                  Slider(
                    value: _discountPercentage,
                    min: 0,
                    max: 90,
                    divisions: 18,
                    label: '${_discountPercentage.toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() {
                        _discountPercentage = value;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  if (_priceController.text.isNotEmpty)
                    Text(
                      'السعر بعد الخصم: ${((double.tryParse(_priceController.text) ?? 0) * (1 - _discountPercentage / 100)).toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // رسالة الخطأ
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
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

          // زر الإضافة
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('إضافة المنتج'),
          ),
        ],
      ),
    );
  }

  // تعديل: بناء واجهة اختيار الصور المتعددة
  Widget _buildImagesPicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صور المنتج',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'يمكنك إضافة حتى 5 صور للمنتج. الصورة الأولى ستكون الصورة الرئيسية.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // عرض الصور المختارة
        if (_imageFiles.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: index == 0
                              ? theme.colorScheme.primary
                              : AppColors.border,
                          width: index == 0 ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          _imageFiles[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'رئيسية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // أزرار إضافة الصور
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _imageFiles.length < 5 ? _pickImage : null,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('إضافة صورة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _imageFiles.length < 5 ? _pickMultipleImages : null,
                icon: const Icon(Icons.photo_library),
                label: const Text('إضافة عدة صور'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        // مؤشر التقدم أثناء رفع الصور
        if (_isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جاري رفع الصور... (${(_uploadProgress * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

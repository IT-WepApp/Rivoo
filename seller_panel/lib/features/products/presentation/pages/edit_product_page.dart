import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_libs/constants/app_constants.dart';
import 'package:shared_libs/services/product_service_provider.dart';
import 'package:shared_libs/widgets/app_widgets.dart';
import 'package:shared_libs/theme/app_colors.dart';

/// صفحة تعديل منتج موجود
class EditProductPage extends ConsumerStatefulWidget {
  final String productId;

  const EditProductPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
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

  File? _imageFile;
  String _imageUrl = '';
  bool _isUploading = false;
  double _uploadProgress = 0;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  Map<String, dynamic>? _productData;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productService = ref.read(productServiceProvider);
      final productData = await productService.getProduct(widget.productId);

      if (productData == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'لم يتم العثور على المنتج';
        });
        return;
      }

      setState(() {
        _productData = productData;

        // تعبئة البيانات في النموذج
        _nameController.text = productData['name'] as String? ?? '';
        _descriptionController.text =
            productData['description'] as String? ?? '';
        _priceController.text =
            (productData['price'] as num?)?.toString() ?? '0';
        _stockQuantityController.text =
            (productData['stockQuantity'] as int?)?.toString() ?? '0';

        _selectedCategory = productData['category'] as String? ?? 'أخرى';
        _isAvailable = productData['isAvailable'] as bool? ?? true;
        _isFeatured = productData['isFeatured'] as bool? ?? false;

        _hasDiscount = productData['hasDiscount'] as bool? ?? false;
        _discountPercentage = productData['discountPercentage'] as double? ?? 0;

        _imageUrl = productData['imageUrl'] as String? ?? '';

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل بيانات المنتج: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) {
      return _imageUrl; // إرجاع الرابط الحالي إذا لم يتم اختيار صورة جديدة
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final fileName =
          'product_${widget.productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(AppConstants.productImagesPath)
          .child(fileName);

      final uploadTask = storageRef.putFile(_imageFile!);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask;

      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _isUploading = false;
        _imageUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'فشل رفع الصورة: $e';
      });
      return _imageUrl; // إرجاع الرابط الحالي في حالة الفشل
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      // رفع الصورة إذا تم اختيارها
      String imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage();
      }

      // إعداد بيانات المنتج
      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'stockQuantity': int.parse(_stockQuantityController.text),
        'isAvailable': _isAvailable,
        'isFeatured': _isFeatured,
        'imageUrl': imageUrl,
      };

      // إضافة بيانات الخصم إذا كان مفعلاً
      if (_hasDiscount) {
        productData['hasDiscount'] = true;
        productData['discountPercentage'] = _discountPercentage;
        // التأكد من أن price ليس null قبل استخدام عامل الضرب
        final price = productData['price'] as double? ?? 0.0;
        productData['discountedPrice'] = price * (1 - _discountPercentage / 100);
      } else {
        productData['hasDiscount'] = false;
        productData['discountPercentage'] = 0;
        productData['discountedPrice'] = productData['price'] ?? 0.0;
      }

      // تحديث المنتج في Firestore
      final productService = ref.read(productServiceProvider);
      await productService.updateProduct(widget.productId, productData);

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المنتج بنجاح'),
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
        _errorMessage = 'فشل تحديث المنتج: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المنتج'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل بيانات المنتج...')
          : _isSubmitting
              ? AppWidgets.loadingIndicator(message: 'جاري تحديث المنتج...')
              : _errorMessage.isNotEmpty && _productData == null
                  ? AppWidgets.errorMessage(
                      message: _errorMessage,
                      onRetry: _loadProductData,
                    )
                  : _buildForm(theme),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // صورة المنتج
          _buildImagePicker(theme),
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
                      'السعر بعد الخصم: ${(double.tryParse(_priceController.text) ?? 0) * (1 - _discountPercentage / 100)} ر.س',
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

          // زر الحفظ
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('حفظ التغييرات'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة المنتج',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'اختر صورة واضحة للمنتج بحجم مناسب',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // عرض الصورة المختارة أو زر اختيار الصورة
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: _isUploading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'جاري رفع الصورة... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ??
                                                1)
                                        : null,
                                    color: theme.colorScheme.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: theme.colorScheme.error,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'فشل تحميل الصورة',
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'انقر لاختيار صورة',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ),
        const SizedBox(height: 8),
        if (_imageFile != null || _imageUrl.isNotEmpty)
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.edit),
            label: const Text('تغيير الصورة'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

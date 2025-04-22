import 'package:flutter/material.dart';
import 'package:shared_libs/lib/widgets/shared_widgets.dart';

/// صفحة نموذج عنوان الشحن
///
/// تستخدم هذه الصفحة لإضافة أو تعديل عنوان الشحن
class ShippingAddressFormPage extends StatefulWidget {
  /// معرف العنوان (اختياري، يستخدم في حالة التعديل)
  final String? addressId;

  /// عنوان الصفحة
  final String title;

  /// وظيفة تنفذ عند الحفظ
  final Function(Map<String, dynamic> addressData) onSave;

  /// بيانات العنوان الأولية (اختيارية)
  final Map<String, dynamic>? initialData;

  /// إنشاء صفحة نموذج عنوان الشحن
  const ShippingAddressFormPage({
    Key? key,
    this.addressId,
    this.title = 'عنوان الشحن',
    required this.onSave,
    this.initialData,
  }) : super(key: key);

  @override
  State<ShippingAddressFormPage> createState() =>
      _ShippingAddressFormPageState();
}

class _ShippingAddressFormPageState extends State<ShippingAddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  // وحدات التحكم في النص
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;

  // حالة التحميل
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // تهيئة وحدات التحكم في النص مع البيانات الأولية إذا كانت متوفرة
    _nameController =
        TextEditingController(text: widget.initialData?['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.initialData?['phone'] ?? '');
    _addressLine1Controller =
        TextEditingController(text: widget.initialData?['addressLine1'] ?? '');
    _addressLine2Controller =
        TextEditingController(text: widget.initialData?['addressLine2'] ?? '');
    _cityController =
        TextEditingController(text: widget.initialData?['city'] ?? '');
    _stateController =
        TextEditingController(text: widget.initialData?['state'] ?? '');
    _postalCodeController =
        TextEditingController(text: widget.initialData?['postalCode'] ?? '');
  }

  @override
  void dispose() {
    // التخلص من وحدات التحكم في النص
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  // حفظ بيانات النموذج
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // تجميع بيانات العنوان
      final addressData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'addressLine1': _addressLine1Controller.text,
        'addressLine2': _addressLine2Controller.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'postalCode': _postalCodeController.text,
      };

      // إضافة معرف العنوان إذا كان متوفرًا (في حالة التعديل)
      if (widget.addressId != null) {
        addressData['id'] = widget.addressId;
      }

      // استدعاء وظيفة الحفظ
      widget.onSave(addressData);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // اسم المستلم
              AppTextField(
                label: 'اسم المستلم',
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المستلم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // رقم الهاتف
              AppTextField(
                label: 'رقم الهاتف',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // سطر العنوان 1
              AppTextField(
                label: 'العنوان (السطر 1)',
                controller: _addressLine1Controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال العنوان';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // سطر العنوان 2 (اختياري)
              AppTextField(
                label: 'العنوان (السطر 2) - اختياري',
                controller: _addressLine2Controller,
              ),
              const SizedBox(height: 16.0),

              // المدينة
              AppTextField(
                label: 'المدينة',
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المدينة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // المحافظة/الولاية
              AppTextField(
                label: 'المحافظة/الولاية',
                controller: _stateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المحافظة/الولاية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // الرمز البريدي
              AppTextField(
                label: 'الرمز البريدي',
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الرمز البريدي';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // زر الحفظ
              AppButton(
                text: widget.addressId != null
                    ? 'تحديث العنوان'
                    : 'إضافة العنوان',
                onPressed: _saveForm,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:user_app/features/profile/domain/models/shipping_address.dart';
import 'package:user_app/features/profile/application/shipping_address_notifier.dart';

class ShippingAddressFormPage extends ConsumerStatefulWidget {
  final ShippingAddress? address;
  
  const ShippingAddressFormPage({
    super.key,
    this.address,
  });

  @override
  ConsumerState<ShippingAddressFormPage> createState() => _ShippingAddressFormPageState();
}

class _ShippingAddressFormPageState extends ConsumerState<ShippingAddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _additionalInfoController;
  
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    final address = widget.address;
    _nameController = TextEditingController(text: address?.name ?? '');
    _streetController = TextEditingController(text: address?.street ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _postalCodeController = TextEditingController(text: address?.postalCode ?? '');
    _countryController = TextEditingController(text: address?.country ?? 'المملكة العربية السعودية');
    _phoneNumberController = TextEditingController(text: address?.phoneNumber ?? '');
    _additionalInfoController = TextEditingController(text: address?.additionalInfo ?? '');
    
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneNumberController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final addressNotifier = ref.read(shippingAddressProvider.notifier);
        
        final newAddress = ShippingAddress(
          id: widget.address?.id ?? '', // Empty ID for new addresses
          userId: widget.address?.userId ?? '', // Will be set in the notifier
          name: _nameController.text.trim(),
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          isDefault: _isDefault,
          additionalInfo: _additionalInfoController.text.trim().isEmpty 
              ? null 
              : _additionalInfoController.text.trim(),
        );
        
        if (widget.address == null) {
          // Adding new address
          await addressNotifier.addAddress(newAddress);
        } else {
          // Updating existing address
          await addressNotifier.updateAddress(newAddress);
        }
        
        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'إضافة عنوان جديد' : 'تعديل العنوان'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'الاسم الكامل',
                hintText: 'أدخل الاسم الكامل للمستلم',
                validator: (value) => (value?.isEmpty ?? true) 
                    ? 'يرجى إدخال الاسم الكامل' 
                    : null,
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _streetController,
                label: 'الشارع والحي',
                hintText: 'أدخل اسم الشارع والحي',
                validator: (value) => (value?.isEmpty ?? true) 
                    ? 'يرجى إدخال الشارع والحي' 
                    : null,
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _cityController,
                label: 'المدينة',
                hintText: 'أدخل اسم المدينة',
                validator: (value) => (value?.isEmpty ?? true) 
                    ? 'يرجى إدخال المدينة' 
                    : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'المنطقة/المحافظة',
                      hintText: 'أدخل المنطقة',
                      validator: (value) => (value?.isEmpty ?? true) 
                          ? 'يرجى إدخال المنطقة' 
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _postalCodeController,
                      label: 'الرمز البريدي',
                      hintText: 'أدخل الرمز البريدي',
                      keyboardType: TextInputType.number,
                      validator: (value) => (value?.isEmpty ?? true) 
                          ? 'يرجى إدخال الرمز البريدي' 
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _countryController,
                label: 'الدولة',
                hintText: 'أدخل اسم الدولة',
                validator: (value) => (value?.isEmpty ?? true) 
                    ? 'يرجى إدخال الدولة' 
                    : null,
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _phoneNumberController,
                label: 'رقم الهاتف',
                hintText: 'أدخل رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  // Simple phone validation
                  if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                    return 'يرجى إدخال رقم هاتف صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _additionalInfoController,
                label: 'معلومات إضافية (اختياري)',
                hintText: 'أي معلومات إضافية تساعد في الوصول للعنوان',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDefault = !_isDefault;
                        });
                      },
                      child: const Text(
                        'تعيين كعنوان افتراضي',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      onPressed: _saveAddress,
                      text: widget.address == null ? 'إضافة العنوان' : 'حفظ التغييرات',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

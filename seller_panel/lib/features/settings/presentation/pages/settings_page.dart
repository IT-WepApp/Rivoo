import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';

/// صفحة الإعدادات المتقدمة للبائع
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;
  String _language = 'ar';

  // إعدادات المتجر
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeEmailController = TextEditingController();

  // إعدادات الشحن
  bool _isFreeShippingEnabled = false;
  final _minimumOrderForFreeShippingController =
      TextEditingController(text: '100');
  final _shippingFeeController = TextEditingController(text: '15');

  // إعدادات الضرائب
  bool _isTaxIncluded = true;
  final _taxRateController = TextEditingController(text: '15');

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    _storeEmailController.dispose();
    _minimumOrderForFreeShippingController.dispose();
    _shippingFeeController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // هنا يتم تحميل الإعدادات من Firebase
      // في هذا المثال، نستخدم بيانات وهمية

      setState(() {
        _isDarkMode = false;
        _isNotificationsEnabled = true;
        _language = 'ar';

        _storeNameController.text = 'متجر الريفوسي';
        _storeDescriptionController.text =
            'متجر متخصص في بيع المنتجات الغذائية الطازجة';
        _storeAddressController.text = 'الرياض، المملكة العربية السعودية';
        _storePhoneController.text = '0512345678';
        _storeEmailController.text = 'store@rivosy.com';

        _isFreeShippingEnabled = true;
        _minimumOrderForFreeShippingController.text = '100';
        _shippingFeeController.text = '15';

        _isTaxIncluded = true;
        _taxRateController.text = '15';

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل الإعدادات: $e';
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // هنا يتم حفظ الإعدادات في Firebase
      // في هذا المثال، نتظاهر بأن العملية نجحت

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
        _successMessage = 'تم حفظ الإعدادات بنجاح';
      });

      // إخفاء رسالة النجاح بعد 3 ثوانٍ
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = '';
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء حفظ الإعدادات: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل الإعدادات...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رسائل النجاح والخطأ
                  if (_successMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage,
                              style: const TextStyle(color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // إعدادات التطبيق
                  _buildSectionTitle(theme, 'إعدادات التطبيق'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSwitchSetting(
                            theme,
                            'الوضع الداكن',
                            'تفعيل الوضع الداكن للتطبيق',
                            Icons.dark_mode,
                            _isDarkMode,
                            (value) {
                              setState(() {
                                _isDarkMode = value;
                              });
                            },
                          ),
                          const Divider(),
                          _buildSwitchSetting(
                            theme,
                            'الإشعارات',
                            'تفعيل إشعارات الطلبات الجديدة والتحديثات',
                            Icons.notifications,
                            _isNotificationsEnabled,
                            (value) {
                              setState(() {
                                _isNotificationsEnabled = value;
                              });
                            },
                          ),
                          const Divider(),
                          _buildLanguageSetting(theme),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // إعدادات المتجر
                  _buildSectionTitle(theme, 'إعدادات المتجر'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTextFieldSetting(
                            theme,
                            'اسم المتجر',
                            'أدخل اسم المتجر',
                            Icons.store,
                            _storeNameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldSetting(
                            theme,
                            'وصف المتجر',
                            'أدخل وصفاً مختصراً للمتجر',
                            Icons.description,
                            _storeDescriptionController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldSetting(
                            theme,
                            'عنوان المتجر',
                            'أدخل عنوان المتجر',
                            Icons.location_on,
                            _storeAddressController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldSetting(
                            theme,
                            'رقم الهاتف',
                            'أدخل رقم هاتف المتجر',
                            Icons.phone,
                            _storePhoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldSetting(
                            theme,
                            'البريد الإلكتروني',
                            'أدخل البريد الإلكتروني للمتجر',
                            Icons.email,
                            _storeEmailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // إعدادات الشحن
                  _buildSectionTitle(theme, 'إعدادات الشحن'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSwitchSetting(
                            theme,
                            'الشحن المجاني',
                            'تفعيل الشحن المجاني للطلبات التي تتجاوز الحد الأدنى',
                            Icons.local_shipping,
                            _isFreeShippingEnabled,
                            (value) {
                              setState(() {
                                _isFreeShippingEnabled = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_isFreeShippingEnabled)
                            _buildTextFieldSetting(
                              theme,
                              'الحد الأدنى للشحن المجاني',
                              'أدخل الحد الأدنى لقيمة الطلب للحصول على شحن مجاني',
                              Icons.money,
                              _minimumOrderForFreeShippingController,
                              keyboardType: TextInputType.number,
                              suffix: 'ر.س',
                            ),
                          if (_isFreeShippingEnabled)
                            const SizedBox(height: 16),
                          _buildTextFieldSetting(
                            theme,
                            'رسوم الشحن',
                            'أدخل رسوم الشحن الافتراضية',
                            Icons.local_shipping,
                            _shippingFeeController,
                            keyboardType: TextInputType.number,
                            suffix: 'ر.س',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // إعدادات الضرائب
                  _buildSectionTitle(theme, 'إعدادات الضرائب'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSwitchSetting(
                            theme,
                            'تضمين الضريبة',
                            'تضمين الضريبة في أسعار المنتجات',
                            Icons.receipt,
                            _isTaxIncluded,
                            (value) {
                              setState(() {
                                _isTaxIncluded = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldSetting(
                            theme,
                            'نسبة الضريبة',
                            'أدخل نسبة الضريبة المطبقة',
                            Icons.percent,
                            _taxRateController,
                            keyboardType: TextInputType.number,
                            suffix: '%',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'حفظ الإعدادات',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLanguageSetting(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.language, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اللغة',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'اختر لغة التطبيق',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: _language,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _language = value;
              });
            }
          },
          items: const [
            DropdownMenuItem(
              value: 'ar',
              child: Text('العربية'),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text('English'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldSetting(
    ThemeData theme,
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

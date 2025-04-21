import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/flutter_gen/gen_l10n/app_localizations.dart';

/// شاشة الإعدادات
class SettingsScreen extends StatefulWidget {
  /// إنشاء شاشة الإعدادات
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'ar';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          // قسم الحساب
          _buildSectionHeader(localizations.account),
          _buildListTile(
            icon: Icons.person_outline,
            title: localizations.profile,
            onTap: () {
              // التنقل إلى شاشة الملف الشخصي
            },
          ),
          _buildListTile(
            icon: Icons.location_on_outlined,
            title: localizations.addresses,
            onTap: () {
              // التنقل إلى شاشة العناوين
            },
          ),
          _buildListTile(
            icon: Icons.payment_outlined,
            title: localizations.paymentMethods,
            onTap: () {
              // التنقل إلى شاشة طرق الدفع
            },
          ),
          
          const Divider(),
          
          // قسم التطبيق
          _buildSectionHeader(localizations.app),
          _buildListTile(
            icon: Icons.language_outlined,
            title: localizations.language,
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: 'ar',
                  child: Text(localizations.arabic),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(localizations.english),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  // تغيير لغة التطبيق
                }
              },
            ),
            onTap: null,
          ),
          _buildListTile(
            icon: Icons.attach_money,
            title: localizations.currency,
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD (\$)'),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR (€)'),
                ),
                DropdownMenuItem(
                  value: 'GBP',
                  child: Text('GBP (£)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                  // تغيير عملة التطبيق
                }
              },
            ),
            onTap: null,
          ),
          _buildListTile(
            icon: Icons.palette_outlined,
            title: localizations.theme,
            onTap: () {
              // التنقل إلى شاشة السمة
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              );
            },
          ),
          _buildSwitchListTile(
            icon: Icons.notifications_outlined,
            title: localizations.notifications,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // تغيير إعدادات الإشعارات
            },
          ),
          
          const Divider(),
          
          // قسم الدعم
          _buildSectionHeader(localizations.support),
          _buildListTile(
            icon: Icons.help_outline,
            title: localizations.helpCenter,
            onTap: () {
              // التنقل إلى شاشة مركز المساعدة
            },
          ),
          _buildListTile(
            icon: Icons.support_agent_outlined,
            title: localizations.contactUs,
            onTap: () {
              // التنقل إلى شاشة اتصل بنا
            },
          ),
          _buildListTile(
            icon: Icons.info_outline,
            title: localizations.aboutApp,
            onTap: () {
              // التنقل إلى شاشة حول التطبيق
            },
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: localizations.privacyPolicy,
            onTap: () {
              // التنقل إلى شاشة سياسة الخصوصية
            },
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: localizations.termsAndConditions,
            onTap: () {
              // التنقل إلى شاشة الشروط والأحكام
            },
          ),
          
          const Divider(),
          
          // زر تسجيل الخروج
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _showLogoutConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(localizations.logout),
            ),
          ),
          
          // نسخة التطبيق
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${localizations.version} 1.0.0',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// بناء عنصر القائمة
  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// بناء عنصر القائمة مع مفتاح تبديل
  Widget _buildSwitchListTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  /// عرض تأكيد تسجيل الخروج
  void _showLogoutConfirmation() {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout),
        content: Text(localizations.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // تنفيذ تسجيل الخروج
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(localizations.logout),
          ),
        ],
      ),
    );
  }
}

/// شاشة إعدادات السمة
class ThemeSettingsScreen extends StatefulWidget {
  /// إنشاء شاشة إعدادات السمة
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedThemeMode = 'system';
  Color _selectedPrimaryColor = AppTheme.primaryColor;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.theme),
      ),
      body: ListView(
        children: [
          // وضع السمة
          _buildSectionHeader(localizations.themeMode),
          _buildRadioListTile(
            title: localizations.systemDefault,
            subtitle: localizations.systemDefaultDescription,
            value: 'system',
            groupValue: _selectedThemeMode,
            onChanged: (value) {
              setState(() {
                _selectedThemeMode = value!;
              });
              // تغيير وضع السمة
            },
          ),
          _buildRadioListTile(
            title: localizations.lightTheme,
            subtitle: localizations.lightThemeDescription,
            value: 'light',
            groupValue: _selectedThemeMode,
            onChanged: (value) {
              setState(() {
                _selectedThemeMode = value!;
              });
              // تغيير وضع السمة
            },
          ),
          _buildRadioListTile(
            title: localizations.darkTheme,
            subtitle: localizations.darkThemeDescription,
            value: 'dark',
            groupValue: _selectedThemeMode,
            onChanged: (value) {
              setState(() {
                _selectedThemeMode = value!;
              });
              // تغيير وضع السمة
            },
          ),
          
          const Divider(),
          
          // اللون الأساسي
          _buildSectionHeader(localizations.primaryColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildColorOption(AppTheme.primaryColor),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.orange),
                _buildColorOption(Colors.purple),
                _buildColorOption(Colors.red),
                _buildColorOption(Colors.teal),
                _buildColorOption(Colors.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// بناء عنصر القائمة مع زر راديو
  Widget _buildRadioListTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondaryColor,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  /// بناء خيار اللون
  Widget _buildColorOption(Color color) {
    final isSelected = _selectedPrimaryColor.value == color.value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrimaryColor = color;
        });
        // تغيير اللون الأساسي
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

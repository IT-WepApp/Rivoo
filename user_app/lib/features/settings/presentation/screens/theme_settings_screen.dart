import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/core/widgets/app_button.dart';
import 'package:user_app/flutter_gen/gen_l10n/app_localizations.dart';

/// شاشة إعدادات السمة
class ThemeSettingsScreen extends StatefulWidget {
  /// إنشاء شاشة إعدادات السمة
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  ThemeMode _selectedThemeMode = ThemeMode.system;
  bool _useSystemTheme = true;
  bool _useDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  /// تحميل إعدادات السمة
  Future<void> _loadThemeSettings() async {
    // تنفيذ تحميل إعدادات السمة من التخزين المحلي
    setState(() {
      _selectedThemeMode = ThemeMode.system;
      _useSystemTheme = _selectedThemeMode == ThemeMode.system;
      _useDarkTheme = _selectedThemeMode == ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.themeSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // استخدام سمة النظام
          _buildThemeOption(
            title: localizations.systemTheme,
            subtitle: localizations.systemThemeDescription,
            value: _useSystemTheme,
            onChanged: (value) {
              setState(() {
                _useSystemTheme = value;
                if (_useSystemTheme) {
                  _selectedThemeMode = ThemeMode.system;
                  _useDarkTheme = false;
                } else {
                  _selectedThemeMode = _useDarkTheme ? ThemeMode.dark : ThemeMode.light;
                }
              });
              _saveThemeSettings();
            },
          ),
          
          const Divider(),
          
          // استخدام السمة الداكنة
          _buildThemeOption(
            title: localizations.darkTheme,
            subtitle: localizations.darkThemeDescription,
            value: _useDarkTheme,
            enabled: !_useSystemTheme,
            onChanged: (value) {
              setState(() {
                _useDarkTheme = value;
                _selectedThemeMode = _useDarkTheme ? ThemeMode.dark : ThemeMode.light;
              });
              _saveThemeSettings();
            },
          ),
          
          const SizedBox(height: 24),
          
          // معاينة السمة
          _buildThemePreview(context),
          
          const SizedBox(height: 24),
          
          // زر إعادة تعيين الإعدادات
          AppButton(
            text: localizations.resetToDefaults,
            onPressed: _resetThemeSettings,
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  /// بناء خيار السمة
  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  /// بناء معاينة السمة
  Widget _buildThemePreview(BuildContext context) {
    final isDark = _useSystemTheme
        ? Theme.of(context).brightness == Brightness.dark
        : _useDarkTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.preview,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان المعاينة
              Text(
                AppLocalizations.of(context)!.themePreviewTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.lightTextPrimaryColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // وصف المعاينة
              Text(
                AppLocalizations.of(context)!.themePreviewDescription,
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.lightTextSecondaryColor,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // أزرار المعاينة
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
                        foregroundColor: isDark ? AppTheme.darkOnPrimaryColor : AppTheme.lightOnPrimaryColor,
                      ),
                      child: Text(AppLocalizations.of(context)!.primaryButton),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
                        side: BorderSide(
                          color: isDark ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.secondaryButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// حفظ إعدادات السمة
  Future<void> _saveThemeSettings() async {
    // تنفيذ حفظ إعدادات السمة في التخزين المحلي
    // ثم تحديث السمة في التطبيق
    
    // مثال:
    // final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    // themeProvider.setThemeMode(_selectedThemeMode);
  }

  /// إعادة تعيين إعدادات السمة
  Future<void> _resetThemeSettings() async {
    setState(() {
      _selectedThemeMode = ThemeMode.system;
      _useSystemTheme = true;
      _useDarkTheme = false;
    });
    
    await _saveThemeSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsReset),
        ),
      );
    }
  }
}

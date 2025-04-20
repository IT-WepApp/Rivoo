import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/presentation/providers/locale_provider.dart';
import 'package:delivery_app/presentation/providers/theme_provider.dart';
import 'package:delivery_app/features/settings/presentation/widgets/language_toggle_widget.dart';
import 'package:delivery_app/features/settings/presentation/widgets/theme_toggle_widget.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // قسم اللغة
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(
              '${localeNotifier.getCurrentLanguageFlag()} ${localeNotifier.getCurrentLanguageName()}',
            ),
            onTap: () {
              context.push('/settings/language');
            },
          ),
          const Divider(),
          
          // قسم المظهر
          ListTile(
            leading: Icon(themeNotifier.getCurrentThemeModeIcon()),
            title: Text(AppLocalizations.of(context)!.theme),
            subtitle: Text(
              AppLocalizations.of(context)!.systemDefault,
            ),
            onTap: () {
              _showThemeModeDialog(context, ref);
            },
          ),
          const Divider(),
          
          // معلومات التطبيق
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('RivooSy Delivery'),
            subtitle: Text('v1.0.0'),
          ),
          
          // واجهة اختبار اللغة
          const LanguageToggleWidget(),
          
          // واجهة اختبار الوضع الليلي
          const ThemeToggleWidget(),
        ],
      ),
    );
  }
  
  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final currentThemeMode = ref.watch(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(AppLocalizations.of(context)!.lightMode),
                value: ThemeMode.light,
                groupValue: currentThemeMode,
                onChanged: (value) {
                  themeNotifier.changeThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(AppLocalizations.of(context)!.darkMode),
                value: ThemeMode.dark,
                groupValue: currentThemeMode,
                onChanged: (value) {
                  themeNotifier.changeThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(AppLocalizations.of(context)!.systemDefault),
                value: ThemeMode.system,
                groupValue: currentThemeMode,
                onChanged: (value) {
                  themeNotifier.changeThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      },
    );
  }
}

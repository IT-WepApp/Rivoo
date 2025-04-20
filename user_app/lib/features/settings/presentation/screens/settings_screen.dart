import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';
import 'package:user_app/features/settings/presentation/screens/theme_settings_screen.dart';

/// شاشة الإعدادات
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateNotifierProvider);
    final isAuthenticated = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المستخدم
              if (isAuthenticated && authState.userData != null)
                _buildUserInfoCard(context, authState.userData!.displayName ?? l10n.user, theme),
              
              const SizedBox(height: 24),
              
              // قسم المظهر
              _buildSectionHeader(l10n.appearance, Icons.palette, theme),
              const SizedBox(height: 8),
              
              // إعدادات السمة
              _buildSettingCard(
                context,
                l10n.themeSettings,
                l10n.themeSettingsDescription,
                Icons.dark_mode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setTheme(value);
                  },
                ),
              ),
              
              // إعدادات اللغة
              _buildSettingCard(
                context,
                l10n.languageSettings,
                l10n.languageSettingsDescription,
                Icons.language,
                () => context.pushNamed('language-settings'),
              ),
              
              const SizedBox(height: 24),
              
              // قسم الحساب
              _buildSectionHeader(l10n.account, Icons.person, theme),
              const SizedBox(height: 8),
              
              // معلومات الحساب
              if (isAuthenticated)
                _buildSettingCard(
                  context,
                  l10n.accountInfo,
                  l10n.accountInfoDescription,
                  Icons.account_circle,
                  () => context.pushNamed('profile'),
                ),
              
              // تسجيل الدخول / الخروج
              _buildSettingCard(
                context,
                isAuthenticated ? l10n.signOut : l10n.signIn,
                isAuthenticated ? l10n.signOutDescription : l10n.signInDescription,
                isAuthenticated ? Icons.logout : Icons.login,
                () {
                  if (isAuthenticated) {
                    _showSignOutConfirmationDialog(context, ref);
                  } else {
                    context.pushNamed('login');
                  }
                },
                color: isAuthenticated ? Colors.red : null,
              ),
              
              const SizedBox(height: 24),
              
              // قسم التطبيق
              _buildSectionHeader(l10n.application, Icons.apps, theme),
              const SizedBox(height: 8),
              
              // الإشعارات
              _buildSettingCard(
                context,
                l10n.notifications,
                l10n.notificationsDescription,
                Icons.notifications,
                () => context.pushNamed('notifications-settings'),
              ),
              
              // الخصوصية
              _buildSettingCard(
                context,
                l10n.privacy,
                l10n.privacyDescription,
                Icons.privacy_tip,
                () => context.pushNamed('privacy'),
              ),
              
              // عن التطبيق
              _buildSettingCard(
                context,
                l10n.about,
                l10n.aboutDescription,
                Icons.info,
                () => context.pushNamed('about'),
              ),
              
              // الدعم الفني
              _buildSettingCard(
                context,
                l10n.support,
                l10n.supportDescription,
                Icons.support_agent,
                () => context.pushNamed('support'),
              ),
              
              const SizedBox(height: 24),
              
              // معلومات الإصدار
              Center(
                child: Text(
                  '${l10n.version}: 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء بطاقة معلومات المستخدم
  Widget _buildUserInfoCard(BuildContext context, String name, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.viewProfile,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => context.pushNamed('profile'),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// بناء بطاقة الإعداد
  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
    Color? color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          color: color ?? theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// عرض حوار تأكيد تسجيل الخروج
  void _showSignOutConfirmationDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateNotifierProvider.notifier).signOut();
            },
            child: Text(
              l10n.signOut,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

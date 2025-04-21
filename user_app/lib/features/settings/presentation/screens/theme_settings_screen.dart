import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/theme/theme_provider.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';

/// شاشة إعدادات السمة
/// تتيح للمستخدم تغيير وضع السمة (فاتح/داكن/النظام)
class ThemeSettingsScreen extends ConsumerWidget {
  /// مسار الشاشة للتوجيه
  static const String routeName = '/settings/theme';

  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
        elevation: 0,
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, themeMode, themeNotifier, l10n),
        tablet: _buildTabletLayout(context, themeMode, themeNotifier, l10n),
        desktop: _buildDesktopLayout(context, themeMode, themeNotifier, l10n),
      ),
    );
  }

  /// بناء تخطيط الهاتف المحمول
  Widget _buildMobileLayout(
    BuildContext context,
    ThemeMode themeMode,
    ThemeNotifier themeNotifier,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThemeHeader(context, l10n),
          const SizedBox(height: 24),
          _buildThemeOptions(context, themeMode, themeNotifier, l10n),
        ],
      ),
    );
  }

  /// بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(
    BuildContext context,
    ThemeMode themeMode,
    ThemeNotifier themeNotifier,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThemeHeader(context, l10n),
          const SizedBox(height: 32),
          _buildThemeOptions(context, themeMode, themeNotifier, l10n),
        ],
      ),
    );
  }

  /// بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeMode themeMode,
    ThemeNotifier themeNotifier,
    AppLocalizations l10n,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemeHeader(context, l10n),
              const SizedBox(height: 40),
              _buildThemeOptions(context, themeMode, themeNotifier, l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء رأس صفحة السمة
  Widget _buildThemeHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.theme,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.languageDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// بناء خيارات السمة
  Widget _buildThemeOptions(
    BuildContext context,
    ThemeMode themeMode,
    ThemeNotifier themeNotifier,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        _buildThemeOption(
          context,
          title: l10n.lightMode,
          description: l10n.lightModeDescription,
          icon: Icons.wb_sunny_rounded,
          isSelected: themeMode == ThemeMode.light,
          onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
        ),
        const SizedBox(height: 16),
        _buildThemeOption(
          context,
          title: l10n.darkMode,
          description: l10n.darkModeDescription,
          icon: Icons.nightlight_round,
          isSelected: themeMode == ThemeMode.dark,
          onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
        ),
        const SizedBox(height: 16),
        _buildThemeOption(
          context,
          title: l10n.systemDefault,
          description: l10n.systemDefaultDescription,
          icon: Icons.settings_brightness,
          isSelected: themeMode == ThemeMode.system,
          onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
        ),
      ],
    );
  }

  /// بناء خيار سمة واحد
  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 26) // 0.1 * 255 = 26
                      : theme.dividerColor.withValues(alpha: 26), // 0.1 * 255 = 26
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : null,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected ? colorScheme.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

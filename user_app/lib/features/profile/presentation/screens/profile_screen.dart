import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // الانتقال إلى صفحة تعديل الملف الشخصي
            },
          ),
        ],
      ),
      body: ResponsiveBuilder(
        // تنفيذ واجهة الهاتف
        mobileBuilder: (context) => _buildMobileLayout(context, l10n),

        // تنفيذ واجهة الجهاز اللوحي
        smallTabletBuilder: (context) => _buildTabletLayout(context, l10n),

        // تنفيذ واجهة سطح المكتب
        desktopBuilder: (context) => _buildDesktopLayout(context, l10n),
      ),
    );
  }

  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(context),
          _buildProfileInfo(context, l10n),
          _buildProfileActions(context, l10n),
        ],
      ),
    );
  }

  // بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الملف الشخصي
                Expanded(
                  flex: 1,
                  child: _buildProfileInfo(context, l10n),
                ),
                const SizedBox(width: 16),
                // إجراءات الملف الشخصي
                Expanded(
                  flex: 1,
                  child: _buildProfileActions(context, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القائمة الجانبية
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  _buildProfileHeader(context, isCompact: false),
                  const SizedBox(height: 24),
                  _buildSidebarItem(
                    context,
                    icon: Icons.person,
                    title: l10n.personalInfo,
                    isSelected: true,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.shopping_bag,
                    title: l10n.orders,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.favorite,
                    title: l10n.wishlist,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.location_on,
                    title: l10n.addresses,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.payment,
                    title: l10n.paymentMethods,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.notifications,
                    title: l10n.notifications,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.settings,
                    title: l10n.settings,
                    onTap: () {},
                  ),
                  const Divider(height: 32),
                  _buildSidebarItem(
                    context,
                    icon: Icons.help,
                    title: l10n.help,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.logout,
                    title: l10n.logout,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // المحتوى الرئيسي
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.personalInfo,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileInfo(context, l10n, isCompact: false),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء رأس الملف الشخصي
  Widget _buildProfileHeader(BuildContext context, {bool isCompact = true}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 24.0 : 16.0,
        horizontal: 16.0,
      ),
      color: isCompact
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 26) // 0.1 * 255 = 26
          : Colors.transparent,
      child: Column(
        children: [
          // صورة الملف الشخصي
          CircleAvatar(
            radius: context.responsiveHeight(isCompact ? 40 : 60),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              'أ',
              style: TextStyle(
                fontSize: context.responsiveFontSize(isCompact ? 32 : 48),
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // اسم المستخدم
          Text(
            'أحمد محمد',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // البريد الإلكتروني
          Text(
            'ahmed@example.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 179), // 0.7 * 255 = 179
                ),
            textAlign: TextAlign.center,
          ),

          if (!isCompact) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // تعديل الملف الشخصي
              },
              icon: const Icon(Icons.edit),
              label: const Text('تعديل الملف الشخصي'),
            ),
          ],
        ],
      ),
    );
  }

  // بناء معلومات الملف الشخصي
  Widget _buildProfileInfo(BuildContext context, AppLocalizations l10n,
      {bool isCompact = true}) {
    return Card(
      elevation: isCompact ? 2 : 0,
      margin: EdgeInsets.all(isCompact ? 16.0 : 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompact)
              Text(
                l10n.personalInfo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (isCompact) const SizedBox(height: 16),

            // المعلومات الشخصية
            _buildInfoItem(
              context,
              label: l10n.fullName,
              value: 'أحمد محمد',
              icon: Icons.person,
            ),
            const Divider(),
            _buildInfoItem(
              context,
              label: l10n.email,
              value: 'ahmed@example.com',
              icon: Icons.email,
            ),
            const Divider(),
            _buildInfoItem(
              context,
              label: l10n.phone,
              value: '+966 50 123 4567',
              icon: Icons.phone,
            ),
            const Divider(),
            _buildInfoItem(
              context,
              label: l10n.dateOfBirth,
              value: '01/01/1990',
              icon: Icons.cake,
            ),
            const Divider(),
            _buildInfoItem(
              context,
              label: l10n.gender,
              value: l10n.male,
              icon: Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }

  // بناء عنصر معلومات
  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 179), // 0.7 * 255 = 179
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء إجراءات الملف الشخصي
  Widget _buildProfileActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileActions,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // قائمة الإجراءات
          _buildActionItem(
            context,
            title: l10n.orders,
            subtitle: l10n.viewYourOrders,
            icon: Icons.shopping_bag,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.wishlist,
            subtitle: l10n.viewYourWishlist,
            icon: Icons.favorite,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.addresses,
            subtitle: l10n.manageYourAddresses,
            icon: Icons.location_on,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.paymentMethods,
            subtitle: l10n.manageYourPaymentMethods,
            icon: Icons.payment,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.notifications,
            subtitle: l10n.manageYourNotifications,
            icon: Icons.notifications,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.settings,
            subtitle: l10n.manageYourSettings,
            icon: Icons.settings,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.help,
            subtitle: l10n.getHelp,
            icon: Icons.help,
            onTap: () {},
          ),
          _buildActionItem(
            context,
            title: l10n.logout,
            subtitle: l10n.signOutOfYourAccount,
            icon: Icons.logout,
            onTap: () {},
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // بناء عنصر إجراء
  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      color: isDestructive
          ? Theme.of(context).colorScheme.error.withValues(alpha: 26) // 0.1 * 255 = 26
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDestructive
              ? Theme.of(context).colorScheme.error.withValues(alpha: 77) // 0.3 * 255 = 77
              : Theme.of(context).colorScheme.outline.withValues(alpha: 77), // 0.3 * 255 = 77
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDestructive
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 179), // 0.7 * 255 = 179
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 128), // 0.5 * 255 = 128
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء عنصر القائمة الجانبية
  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 26) // 0.1 * 255 = 26
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

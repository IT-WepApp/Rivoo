import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// مكون لعرض شريط التنقل السفلي
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationItem> items;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: items.map((item) => item.toBottomNavigationBarItem()).toList(),
    );
  }
}

/// نموذج عنصر شريط التنقل السفلي
class BottomNavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  BottomNavigationItem({
    required this.label,
    required this.icon,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;

  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}

/// مكون لعرض شريط التنقل العلوي
class AppTopNavigation extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppTopNavigation({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
    );
  }
}

/// مكون لعرض شريط التنقل الجانبي
class AppDrawerNavigation extends StatelessWidget {
  final String headerTitle;
  final String? headerSubtitle;
  final String? headerImageUrl;
  final List<DrawerNavigationItem> items;
  final VoidCallback? onLogout;

  const AppDrawerNavigation({
    Key? key,
    required this.headerTitle,
    this.headerSubtitle,
    this.headerImageUrl,
    required this.items,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          ...items.map((item) => _buildDrawerItem(context, item)),
          if (onLogout != null) const Divider(),
          if (onLogout != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: onLogout,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(headerTitle),
      accountEmail: headerSubtitle != null ? Text(headerSubtitle!) : null,
      currentAccountPicture: headerImageUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(headerImageUrl!),
            )
          : const CircleAvatar(
              child: Icon(Icons.person),
            ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerNavigationItem item) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      onTap: () {
        Navigator.of(context).pop(); // إغلاق الدرج
        if (item.onTap != null) {
          item.onTap!();
        } else if (item.route != null) {
          context.go(item.route!);
        }
      },
    );
  }
}

/// نموذج عنصر شريط التنقل الجانبي
class DrawerNavigationItem {
  final String title;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;

  DrawerNavigationItem({
    required this.title,
    required this.icon,
    this.route,
    this.onTap,
  }) : assert(route != null || onTap != null, 'يجب توفير إما route أو onTap');
}

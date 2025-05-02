import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../admin_router.dart';
import '../../../../core/auth/auth_provider.dart';

/// قائمة التنقل الجانبية للمسؤول
class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context, ref),
          _buildDrawerItems(context, currentRoute),
        ],
      ),
    );
  }

  /// بناء رأس القائمة الجانبية
  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    
    return UserAccountsDrawerHeader(
      accountName: Text(user?.displayName ?? 'المسؤول'),
      accountEmail: Text(user?.email ?? 'admin@example.com'),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          user?.displayName?.isNotEmpty == true
              ? user!.displayName![0].toUpperCase()
              : 'A',
          style: const TextStyle(fontSize: 24.0),
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  /// بناء عناصر القائمة الجانبية
  Widget _buildDrawerItems(BuildContext context, String currentRoute) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard,
            title: 'لوحة التحكم',
            route: AdminRoutes.adminHome,
            isSelected: currentRoute == AdminRoutes.adminHome,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.category,
            title: 'إدارة الفئات',
            route: AdminRoutes.categoryManagement,
            isSelected: currentRoute == AdminRoutes.categoryManagement,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.shopping_bag,
            title: 'إدارة المنتجات',
            route: AdminRoutes.productManagement,
            isSelected: currentRoute == AdminRoutes.productManagement,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.receipt_long,
            title: 'إدارة الطلبات',
            route: AdminRoutes.orderManagement,
            isSelected: currentRoute == AdminRoutes.orderManagement,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.people,
            title: 'إدارة المستخدمين',
            route: AdminRoutes.userManagement,
            isSelected: currentRoute == AdminRoutes.userManagement,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.store,
            title: 'إدارة المتاجر',
            route: AdminRoutes.storeManagement,
            isSelected: currentRoute == AdminRoutes.storeManagement,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.bar_chart,
            title: 'الإحصائيات والتقارير',
            route: AdminRoutes.statistics,
            isSelected: currentRoute == AdminRoutes.statistics,
          ),
          const Divider(),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  /// بناء عنصر قائمة
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        // إغلاق القائمة الجانبية
        Navigator.pop(context);
        
        // التنقل إلى المسار المطلوب إذا لم نكن فيه بالفعل
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }

  /// بناء عنصر تسجيل الخروج
  Widget _buildLogoutItem(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('تسجيل الخروج'),
          onTap: () async {
            // إغلاق القائمة الجانبية
            Navigator.pop(context);
            
            // تسجيل الخروج
            await ref.read(authProvider.notifier).signOut();
            
            // التنقل إلى صفحة تسجيل الدخول
            if (context.mounted) {
              context.go(AdminRoutes.login);
            }
          },
        );
      },
    );
  }
}

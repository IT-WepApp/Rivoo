import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/product_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/theme/app_colors.dart';

/// صفحة لوحة التحكم الرئيسية للبائع
class SellerDashboardPage extends ConsumerStatefulWidget {
  const SellerDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerDashboardPage> createState() =>
      _SellerDashboardPageState();
}

class _SellerDashboardPageState extends ConsumerState<SellerDashboardPage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();

    // تهيئة خدمة الإشعارات
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.initialize();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      final productService = ref.read(productServiceProvider);
      final authService = ref.read(authServiceProvider);

      // الحصول على إحصائيات الطلبات
      final orderStats = await orderService.getOrderStatistics();

      // الحصول على عدد المنتجات
      final products = await productService.getSellerProducts();

      // الحصول على بيانات البائع
      final sellerData = await authService.getSellerData();

      // الحصول على الطلبات الجديدة
      final newOrders = await orderService.getNewOrders();

      setState(() {
        _dashboardData = {
          'orderStats': orderStats,
          'productsCount': products.length,
          'sellerData': sellerData,
          'newOrders': newOrders.take(5).toList(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم البائع'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push(RouteConstants.notifications),
            tooltip: 'الإشعارات',
          ),
        ],
      ),
      drawer: _buildDrawer(context, theme),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل البيانات...')
          : _errorMessage.isNotEmpty
              ? AppWidgets.errorMessage(
                  message: _errorMessage,
                  onRetry: _loadDashboardData,
                )
              : _buildDashboardContent(context, theme),
      bottomNavigationBar: _buildBottomNavigationBar(context, theme),
    );
  }

  Widget _buildDashboardContent(BuildContext context, ThemeData theme) {
    final orderStats =
        _dashboardData['orderStats'] as Map<String, dynamic>? ?? {};
    final productsCount = _dashboardData['productsCount'] as int? ?? 0;
    final sellerData =
        _dashboardData['sellerData'] as Map<String, dynamic>? ?? {};
    final newOrders = _dashboardData['newOrders'] as List<dynamic>? ?? [];

    final storeName = sellerData['storeName'] as String? ?? 'متجرك';

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ترحيب بالبائع
          Text(
            'مرحباً بك في $storeName',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'هذه لوحة التحكم الخاصة بك، يمكنك إدارة متجرك ومنتجاتك وطلباتك من هنا.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // بطاقات الإحصائيات
          Text(
            'نظرة عامة',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildStatisticsCards(context, theme, orderStats, productsCount),
          const SizedBox(height: 24),

          // الإجراءات السريعة
          Text(
            'إجراءات سريعة',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildQuickActions(context, theme),
          const SizedBox(height: 24),

          // الطلبات الجديدة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الطلبات الجديدة',
                style: theme.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => context.push(RouteConstants.orders),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          newOrders.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('لا توجد طلبات جديدة حالياً.'),
                  ),
                )
              : Column(
                  children: newOrders.map<Widget>((order) {
                    return _buildOrderItem(context, theme, order);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> orderStats,
    int productsCount,
  ) {
    final pendingOrders = orderStats['pendingOrders'] as int? ?? 0;
    final totalSales = orderStats['totalSales'] as double? ?? 0.0;
    final todayOrders = orderStats['todayOrders'] as int? ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          theme,
          'الطلبات الجديدة',
          pendingOrders.toString(),
          Icons.new_releases,
          AppColors.warning,
        ),
        _buildStatCard(
          theme,
          'إجمالي المبيعات',
          '${totalSales.toStringAsFixed(2)} ر.س',
          Icons.attach_money,
          AppColors.success,
        ),
        _buildStatCard(
          theme,
          'طلبات اليوم',
          todayOrders.toString(),
          Icons.today,
          AppColors.info,
        ),
        _buildStatCard(
          theme,
          'المنتجات',
          productsCount.toString(),
          Icons.inventory_2,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          context,
          'إضافة منتج',
          Icons.add_circle,
          AppColors.success,
          () => context.push(RouteConstants.addProduct),
        ),
        _buildActionButton(
          context,
          'إدارة المنتجات',
          Icons.inventory_2,
          AppColors.info,
          () => context.push(RouteConstants.products),
        ),
        _buildActionButton(
          context,
          'الطلبات',
          Icons.shopping_bag,
          AppColors.warning,
          () => context.push(RouteConstants.orders),
        ),
        _buildActionButton(
          context,
          'الإحصائيات',
          Icons.bar_chart,
          AppColors.secondary,
          () => context.push(RouteConstants.statistics),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> order,
  ) {
    final orderId = order['id'] as String? ?? '';
    final customerName = order['customerName'] as String? ?? 'عميل';
    final total = order['total'] as num? ?? 0;
    final createdAt =
        (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return AppWidgets.appCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'طلب #$orderId',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Text(
                  'جديد',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    customerName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${createdAt.day}/${createdAt.month}/${createdAt.year} - ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'المجموع: ${total.toStringAsFixed(2)} ر.س',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  context.push('${RouteConstants.orderDetails}/$orderId'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('عرض التفاصيل'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final sellerData =
        _dashboardData['sellerData'] as Map<String, dynamic>? ?? {};
    final storeName = sellerData['storeName'] as String? ?? 'متجرك';
    final sellerName = sellerData['name'] as String? ?? 'البائع';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  storeName,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sellerName,
                  style: TextStyle(
                    color: AppColors.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('لوحة التحكم'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
              context.go(RouteConstants.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('المنتجات'),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
              context.push(RouteConstants.products);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('الطلبات'),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
              context.push(RouteConstants.orders);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text('العروض'),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
              context.push(RouteConstants.promotions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('الإحصائيات'),
            selected: _selectedIndex == 4,
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
              Navigator.pop(context);
              context.push(RouteConstants.statistics);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('الإشعارات'),
            selected: _selectedIndex == 5,
            onTap: () {
              setState(() {
                _selectedIndex = 5;
              });
              Navigator.pop(context);
              context.push(RouteConstants.notifications);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الملف الشخصي'),
            selected: _selectedIndex == 6,
            onTap: () {
              setState(() {
                _selectedIndex = 6;
              });
              Navigator.pop(context);
              context.push(RouteConstants.profile);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await AppWidgets.showConfirmDialog(
                context: context,
                title: 'تسجيل الخروج',
                message: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                confirmText: 'تسجيل الخروج',
                cancelText: 'إلغاء',
                isDangerous: true,
              );

              if (confirmed && context.mounted) {
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
                if (context.mounted) {
                  context.go(RouteConstants.login);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            context.go(RouteConstants.home);
            break;
          case 1:
            context.push(RouteConstants.products);
            break;
          case 2:
            context.push(RouteConstants.orders);
            break;
          case 3:
            context.push(RouteConstants.profile);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'المنتجات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'الطلبات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الملف',
        ),
      ],
    );
  }
}

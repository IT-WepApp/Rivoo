import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../admin_router.dart';
import 'package:shared_libs/shared_libs.dart';


/// الصفحة الرئيسية للمسؤول
class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول'),
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildQuickAccessGrid(context),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة الترحيب
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مرحباً بك في لوحة تحكم المسؤول',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك إدارة جميع جوانب النظام من هنا. استخدم القائمة الجانبية أو الأزرار أدناه للوصول إلى الأقسام المختلفة.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'ملاحظة: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'تأكد من تحديث البيانات بانتظام للحفاظ على دقة المعلومات المعروضة.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شبكة الوصول السريع
  Widget _buildQuickAccessGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوصول السريع',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildQuickAccessCard(
              context,
              'إدارة الفئات',
              Icons.category,
              AdminRoutes.categoryManagement,
              Colors.blue.shade700,
            ),
            _buildQuickAccessCard(
              context,
              'إدارة المنتجات',
              Icons.shopping_bag,
              AdminRoutes.productManagement,
              Colors.green.shade700,
            ),
            _buildQuickAccessCard(
              context,
              'إدارة الطلبات',
              Icons.receipt_long,
              AdminRoutes.orderManagement,
              Colors.orange.shade700,
            ),
            _buildQuickAccessCard(
              context,
              'إدارة المستخدمين',
              Icons.people,
              AdminRoutes.userManagement,
              Colors.purple.shade700,
            ),
            _buildQuickAccessCard(
              context,
              'إدارة المتاجر',
              Icons.store,
              AdminRoutes.storeManagement,
              Colors.red.shade700,
            ),
            _buildQuickAccessCard(
              context,
              'الإحصائيات والتقارير',
              Icons.bar_chart,
              AdminRoutes.statistics,
              Colors.teal.shade700,
            ),
          ],
        ),
      ],
    );
  }

  /// بناء بطاقة وصول سريع
  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

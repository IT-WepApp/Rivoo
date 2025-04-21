import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

/// صفحة الإحصائيات والتحليلات للبائع
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _errorMessage = '';

  late TabController _tabController;

  // بيانات الإحصائيات
  Map<String, dynamic> _salesData = {};
  Map<String, dynamic> _productsData = {};
  Map<String, dynamic> _customersData = {};

  // فلاتر
  String _timeRange = 'week'; // يوم، أسبوع، شهر، سنة

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);

      // تحميل بيانات المبيعات
      final salesData =
          await orderService.getSellerSalesStatistics(timeRange: _timeRange);

      // تحميل بيانات المنتجات
      final productsData =
          await orderService.getSellerProductsStatistics(timeRange: _timeRange);

      // تحميل بيانات العملاء
      final customersData = await orderService.getSellerCustomersStatistics(
          timeRange: _timeRange);

      setState(() {
        _salesData = salesData;
        _productsData = productsData;
        _customersData = customersData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
      });
    }
  }

  void _changeTimeRange(String range) {
    setState(() {
      _timeRange = range;
    });
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات والتحليلات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'تحديث',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          indicatorColor: AppColors.onPrimary,
          tabs: const [
            Tab(text: 'المبيعات'),
            Tab(text: 'المنتجات'),
            Tab(text: 'العملاء'),
          ],
        ),
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل البيانات...')
          : _errorMessage.isNotEmpty
              ? AppWidgets.errorMessage(
                  message: _errorMessage,
                  onRetry: _loadStatistics,
                )
              : Column(
                  children: [
                    // فلاتر الوقت
                    _buildTimeRangeFilter(theme),

                    // محتوى التبويبات
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSalesTab(theme),
                          _buildProductsTab(theme),
                          _buildCustomersTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTimeRangeFilter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeRangeButton(theme, 'day', 'يوم'),
          _buildTimeRangeButton(theme, 'week', 'أسبوع'),
          _buildTimeRangeButton(theme, 'month', 'شهر'),
          _buildTimeRangeButton(theme, 'year', 'سنة'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(ThemeData theme, String value, String label) {
    final isSelected = _timeRange == value;

    return ElevatedButton(
      onPressed: () => _changeTimeRange(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
        foregroundColor:
            isSelected ? AppColors.onPrimary : AppColors.textPrimary,
        elevation: isSelected ? 2 : 0,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildSalesTab(ThemeData theme) {
    if (_salesData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات مبيعات متاحة'),
      );
    }

    final totalSales = _salesData['totalSales'] as num? ?? 0;
    final totalOrders = _salesData['totalOrders'] as int? ?? 0;
    final averageOrderValue = _salesData['averageOrderValue'] as num? ?? 0;
    final salesGrowth = _salesData['salesGrowth'] as num? ?? 0;
    final salesByDay = _salesData['salesByDay'] as List<dynamic>? ?? [];
    final salesByCategory =
        _salesData['salesByCategory'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقات الإحصائيات الرئيسية
        _buildStatsCards(
          theme,
          [
            {
              'title': 'إجمالي المبيعات',
              'value': '${totalSales.toStringAsFixed(2)} ر.س',
              'icon': Icons.attach_money,
              'color': AppColors.success,
            },
            {
              'title': 'عدد الطلبات',
              'value': totalOrders.toString(),
              'icon': Icons.shopping_bag,
              'color': AppColors.info,
            },
            {
              'title': 'متوسط قيمة الطلب',
              'value': '${averageOrderValue.toStringAsFixed(2)} ر.س',
              'icon': Icons.trending_up,
              'color': AppColors.secondary,
            },
            {
              'title': 'نمو المبيعات',
              'value':
                  '${salesGrowth >= 0 ? '+' : ''}${salesGrowth.toStringAsFixed(1)}%',
              'icon':
                  salesGrowth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              'color': salesGrowth >= 0 ? AppColors.success : AppColors.error,
            },
          ],
        ),
        const SizedBox(height: 24),

        // رسم بياني للمبيعات حسب اليوم
        _buildSectionTitle(theme, 'المبيعات حسب اليوم'),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: _buildSalesByDayChart(theme, salesByDay),
        ),
        const SizedBox(height: 24),

        // رسم بياني للمبيعات حسب الفئة
        _buildSectionTitle(theme, 'المبيعات حسب الفئة'),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: _buildSalesByCategoryChart(theme, salesByCategory),
        ),
      ],
    );
  }

  Widget _buildProductsTab(ThemeData theme) {
    if (_productsData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات منتجات متاحة'),
      );
    }

    final totalProducts = _productsData['totalProducts'] as int? ?? 0;
    final outOfStockProducts = _productsData['outOfStockProducts'] as int? ?? 0;
    final lowStockProducts = _productsData['lowStockProducts'] as int? ?? 0;
    final topSellingProducts =
        _productsData['topSellingProducts'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقات الإحصائيات الرئيسية
        _buildStatsCards(
          theme,
          [
            {
              'title': 'إجمالي المنتجات',
              'value': totalProducts.toString(),
              'icon': Icons.inventory,
              'color': AppColors.info,
            },
            {
              'title': 'نفاد المخزون',
              'value': outOfStockProducts.toString(),
              'icon': Icons.remove_shopping_cart,
              'color': AppColors.error,
            },
            {
              'title': 'مخزون منخفض',
              'value': lowStockProducts.toString(),
              'icon': Icons.warning,
              'color': AppColors.warning,
            },
          ],
        ),
        const SizedBox(height: 24),

        // قائمة المنتجات الأكثر مبيعاً
        _buildSectionTitle(theme, 'المنتجات الأكثر مبيعاً'),
        const SizedBox(height: 8),
        _buildTopSellingProductsList(theme, topSellingProducts),
      ],
    );
  }

  Widget _buildCustomersTab(ThemeData theme) {
    if (_customersData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات عملاء متاحة'),
      );
    }

    final totalCustomers = _customersData['totalCustomers'] as int? ?? 0;
    final newCustomers = _customersData['newCustomers'] as int? ?? 0;
    final returningCustomers =
        _customersData['returningCustomers'] as int? ?? 0;
    final customerRetentionRate =
        _customersData['customerRetentionRate'] as num? ?? 0;
    final topCustomers = _customersData['topCustomers'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقات الإحصائيات الرئيسية
        _buildStatsCards(
          theme,
          [
            {
              'title': 'إجمالي العملاء',
              'value': totalCustomers.toString(),
              'icon': Icons.people,
              'color': AppColors.info,
            },
            {
              'title': 'عملاء جدد',
              'value': newCustomers.toString(),
              'icon': Icons.person_add,
              'color': AppColors.success,
            },
            {
              'title': 'عملاء عائدون',
              'value': returningCustomers.toString(),
              'icon': Icons.repeat,
              'color': AppColors.secondary,
            },
            {
              'title': 'معدل الاحتفاظ',
              'value': '${customerRetentionRate.toStringAsFixed(1)}%',
              'icon': Icons.favorite,
              'color': AppColors.error,
            },
          ],
        ),
        const SizedBox(height: 24),

        // قائمة العملاء الأكثر شراءً
        _buildSectionTitle(theme, 'العملاء الأكثر شراءً'),
        const SizedBox(height: 8),
        _buildTopCustomersList(theme, topCustomers),
      ],
    );
  }

  Widget _buildStatsCards(ThemeData theme, List<Map<String, dynamic>> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final title = stat['title'] as String;
        final value = stat['value'] as String;
        final icon = stat['icon'] as IconData;
        final color = stat['color'] as Color;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSalesByDayChart(ThemeData theme, List<dynamic> salesByDay) {
    if (salesByDay.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    // تحويل البيانات إلى تنسيق مناسب للرسم البياني
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < salesByDay.length; i++) {
      final item = salesByDay[i] as Map<String, dynamic>;
      final sales = item['sales'] as num? ?? 0;
      final day = item['day'] as String? ?? '';

      spots.add(FlSpot(i.toDouble(), sales.toDouble()));
      labels.add(day);
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                      labels[value.toInt()],
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        minX: 0,
        maxX: (salesByDay.length - 1).toDouble(),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.background,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesByCategoryChart(
      ThemeData theme, List<dynamic> salesByCategory) {
    if (salesByCategory.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    // تحويل البيانات إلى تنسيق مناسب للرسم البياني
    final sections = <PieChartSectionData>[];
    final legends = <Widget>[];

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    for (int i = 0; i < salesByCategory.length; i++) {
      final item = salesByCategory[i] as Map<String, dynamic>;
      final category = item['category'] as String? ?? '';
      final sales = item['sales'] as num? ?? 0;
      final percentage = item['percentage'] as num? ?? 0;

      final color = colors[i % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: sales.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legends.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '${sales.toStringAsFixed(0)} ر.س',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        // الرسم البياني الدائري
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),

        // مفتاح الرسم البياني
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legends,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSellingProductsList(ThemeData theme, List<dynamic> products) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد بيانات متاحة'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index] as Map<String, dynamic>;
        final productId = product['id'] as String? ?? '';
        final name = product['name'] as String? ?? '';
        final imageUrl = product['imageUrl'] as String? ?? '';
        final sales = product['sales'] as num? ?? 0;
        final quantity = product['quantity'] as int? ?? 0;
        final stock = product['stock'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory, color: Colors.grey),
                  ),
            title: Text(
              name,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'المبيعات: ${sales.toStringAsFixed(2)} ر.س',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'الكمية المباعة: $quantity',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'المخزون المتبقي: $stock',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: stock <= 5 ? Colors.red : null,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () =>
                  context.push('${RouteConstants.editProduct}/$productId'),
              tooltip: 'عرض المنتج',
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopCustomersList(ThemeData theme, List<dynamic> customers) {
    if (customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد بيانات متاحة'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index] as Map<String, dynamic>;
        final name = customer['name'] as String? ?? '';
        final email = customer['email'] as String? ?? '';
        final phone = customer['phone'] as String? ?? '';
        final totalSpent = customer['totalSpent'] as num? ?? 0;
        final ordersCount = customer['ordersCount'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: theme.textTheme.bodySmall,
                  ),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 4),
                Text(
                  'إجمالي الإنفاق: ${totalSpent.toStringAsFixed(2)} ر.س',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'عدد الطلبات: $ordersCount',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

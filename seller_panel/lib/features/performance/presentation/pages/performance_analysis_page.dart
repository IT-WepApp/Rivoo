import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'package:shared_libs/theme/app_colors.dart';

/// صفحة تحليل الأداء والتحسين للبائع
class PerformanceAnalysisPage extends ConsumerStatefulWidget {
  const PerformanceAnalysisPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PerformanceAnalysisPage> createState() =>
      _PerformanceAnalysisPageState();
}

class _PerformanceAnalysisPageState
    extends ConsumerState<PerformanceAnalysisPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _errorMessage = '';

  late TabController _tabController;

  // بيانات تحليل الأداء
  Map<String, dynamic> _performanceData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPerformanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // هنا يتم تحميل بيانات تحليل الأداء من Firebase
      // في هذا المثال، نستخدم بيانات وهمية

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _performanceData = {
          'conversionRate': 3.8,
          'cartAbandonmentRate': 28.5,
          'averageOrderValue': 185.75,
          'returnRate': 2.1,
          'customerRetentionRate': 68.3,
          'pageLoadTime': 1.2,
          'searchSuccessRate': 92.7,
          'checkoutCompletionRate': 76.4,
          'productViewsToCartAdds': 15.2,
          'cartAddsToCheckout': 42.8,
          'topSearchTerms': [
            {'term': 'خضروات طازجة', 'count': 156},
            {'term': 'فواكه', 'count': 124},
            {'term': 'عصائر طبيعية', 'count': 98},
            {'term': 'لحوم', 'count': 87},
            {'term': 'منتجات ألبان', 'count': 76},
          ],
          'topExitPages': [
            {'page': 'صفحة الدفع', 'exitRate': 18.5},
            {'page': 'صفحة سلة التسوق', 'exitRate': 12.3},
            {'page': 'صفحة تفاصيل المنتج', 'exitRate': 8.7},
            {'page': 'صفحة البحث', 'exitRate': 6.2},
            {'page': 'الصفحة الرئيسية', 'exitRate': 4.1},
          ],
          'improvementSuggestions': [
            'تحسين سرعة تحميل صفحة الدفع لتقليل معدل الخروج',
            'تبسيط عملية الدفع لزيادة معدل إتمام عمليات الشراء',
            'إضافة توصيات منتجات مشابهة في صفحة تفاصيل المنتج',
            'تحسين نتائج البحث للكلمات الرئيسية الأكثر استخداماً',
            'إضافة حوافز للعملاء لإكمال عمليات الشراء المتروكة',
          ],
        };

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل بيانات تحليل الأداء: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل الأداء والتحسين'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPerformanceData,
            tooltip: 'تحديث',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: const [
            Tab(text: 'مؤشرات الأداء'),
            Tab(text: 'سلوك المستخدم'),
            Tab(text: 'التحسينات المقترحة'),
          ],
        ),
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(
              message: 'جاري تحميل بيانات تحليل الأداء...')
          : _errorMessage.isNotEmpty
              ? AppWidgets.errorMessage(
                  message: _errorMessage,
                  onRetry: _loadPerformanceData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPerformanceIndicatorsTab(theme),
                    _buildUserBehaviorTab(theme),
                    _buildImprovementSuggestionsTab(theme),
                  ],
                ),
    );
  }

  Widget _buildPerformanceIndicatorsTab(ThemeData theme) {
    if (_performanceData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    final conversionRate = _performanceData['conversionRate'] as double? ?? 0;
    final cartAbandonmentRate =
        _performanceData['cartAbandonmentRate'] as double? ?? 0;
    final averageOrderValue =
        _performanceData['averageOrderValue'] as double? ?? 0;
    final returnRate = _performanceData['returnRate'] as double? ?? 0;
    final customerRetentionRate =
        _performanceData['customerRetentionRate'] as double? ?? 0;
    final pageLoadTime = _performanceData['pageLoadTime'] as double? ?? 0;
    final searchSuccessRate =
        _performanceData['searchSuccessRate'] as double? ?? 0;
    final checkoutCompletionRate =
        _performanceData['checkoutCompletionRate'] as double? ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'مؤشرات الأداء الرئيسية'),
          const SizedBox(height: 16),

          // مؤشرات الأداء الرئيسية
          _buildPerformanceIndicator(
            theme,
            'معدل التحويل',
            '$conversionRate%',
            'نسبة الزوار الذين أكملوا عملية الشراء',
            Icons.trending_up,
            _getIndicatorColor(conversionRate, 2, 4),
            conversionRate / 10, // تحويل النسبة إلى قيمة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'معدل ترك سلة التسوق',
            '$cartAbandonmentRate%',
            'نسبة المستخدمين الذين أضافوا منتجات للسلة ولم يكملوا الشراء',
            Icons.remove_shopping_cart,
            _getIndicatorColor(100 - cartAbandonmentRate, 60, 80),
            1 - (cartAbandonmentRate / 100), // تحويل النسبة إلى قيمة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'متوسط قيمة الطلب',
            '${averageOrderValue.toStringAsFixed(2)} ر.س',
            'متوسط قيمة الطلبات المكتملة',
            Icons.shopping_cart,
            _getIndicatorColor(averageOrderValue, 150, 200),
            averageOrderValue / 300, // تحويل القيمة إلى نسبة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'معدل الإرجاع',
            '$returnRate%',
            'نسبة المنتجات التي تم إرجاعها',
            Icons.assignment_return,
            _getIndicatorColor(100 - returnRate, 95, 98),
            1 - (returnRate / 10), // تحويل النسبة إلى قيمة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'معدل الاحتفاظ بالعملاء',
            '$customerRetentionRate%',
            'نسبة العملاء الذين عادوا للشراء مرة أخرى',
            Icons.people,
            _getIndicatorColor(customerRetentionRate, 60, 80),
            customerRetentionRate / 100, // تحويل النسبة إلى قيمة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'زمن تحميل الصفحة',
            '$pageLoadTime ثانية',
            'متوسط زمن تحميل صفحات المتجر',
            Icons.speed,
            _getIndicatorColor(3 - pageLoadTime, 1, 2),
            1 - (pageLoadTime / 3), // تحويل الزمن إلى قيمة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'معدل نجاح البحث',
            '$searchSuccessRate%',
            'نسبة عمليات البحث التي أدت إلى نتائج مناسبة',
            Icons.search,
            _getIndicatorColor(searchSuccessRate, 80, 90),
            searchSuccessRate / 100, // تحويل النسبة إلى قيمة بين 0 و 1
          ),
          const SizedBox(height: 16),

          _buildPerformanceIndicator(
            theme,
            'معدل إتمام عملية الدفع',
            '$checkoutCompletionRate%',
            'نسبة المستخدمين الذين بدأوا عملية الدفع وأكملوها',
            Icons.payment,
            _getIndicatorColor(checkoutCompletionRate, 70, 85),
            checkoutCompletionRate / 100, // تحويل النسبة إلى قيمة بين 0 و 1
          ),
        ],
      ),
    );
  }

  Widget _buildUserBehaviorTab(ThemeData theme) {
    if (_performanceData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    final productViewsToCartAdds =
        _performanceData['productViewsToCartAdds'] as double? ?? 0;
    final cartAddsToCheckout =
        _performanceData['cartAddsToCheckout'] as double? ?? 0;
    final topSearchTerms =
        _performanceData['topSearchTerms'] as List<dynamic>? ?? [];
    final topExitPages =
        _performanceData['topExitPages'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'سلوك المستخدم'),
          const SizedBox(height: 16),

          // نسب التحويل في مراحل الشراء
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نسب التحويل في مراحل الشراء',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مشاهدة المنتج → إضافة للسلة',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: productViewsToCartAdds / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getIndicatorColor(
                                    productViewsToCartAdds, 10, 20),
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$productViewsToCartAdds%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إضافة للسلة → إتمام الدفع',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: cartAddsToCheckout / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getIndicatorColor(cartAddsToCheckout, 30, 50),
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$cartAddsToCheckout%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // الكلمات الأكثر بحثاً
          _buildSectionTitle(theme, 'الكلمات الأكثر بحثاً'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < topSearchTerms.length; i++)
                    _buildSearchTermItem(
                      theme,
                      topSearchTerms[i]['term'] as String? ?? '',
                      topSearchTerms[i]['count'] as int? ?? 0,
                      i == topSearchTerms.length - 1 ? false : true,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // الصفحات الأكثر خروجاً
          _buildSectionTitle(theme, 'الصفحات الأكثر خروجاً'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < topExitPages.length; i++)
                    _buildExitPageItem(
                      theme,
                      topExitPages[i]['page'] as String? ?? '',
                      topExitPages[i]['exitRate'] as double? ?? 0,
                      i == topExitPages.length - 1 ? false : true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestionsTab(ThemeData theme) {
    if (_performanceData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    final improvementSuggestions =
        _performanceData['improvementSuggestions'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'التحسينات المقترحة'),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < improvementSuggestions.length; i++)
                    _buildSuggestionItem(
                      theme,
                      improvementSuggestions[i] as String? ?? '',
                      i + 1,
                      i == improvementSuggestions.length - 1 ? false : true,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // زر تنفيذ التحسينات
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // هنا يمكن إضافة منطق لتنفيذ التحسينات المقترحة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري تنفيذ التحسينات المقترحة...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.trending_up),
              label: const Text('تنفيذ التحسينات المقترحة'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء عنصر مؤشر أداء
  Widget _buildPerformanceIndicator(
    ThemeData theme,
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  // بناء عنصر كلمة بحث
  Widget _buildSearchTermItem(
    ThemeData theme,
    String term,
    int count,
    bool showDivider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  term,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }

  // بناء عنصر صفحة خروج
  Widget _buildExitPageItem(
    ThemeData theme,
    String page,
    double exitRate,
    bool showDivider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.exit_to_app,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  page,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getExitRateColor(exitRate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${exitRate.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getExitRateColor(exitRate),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }

  // بناء عنصر اقتراح تحسين
  Widget _buildSuggestionItem(
    ThemeData theme,
    String suggestion,
    int index,
    bool showDivider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }

  // بناء عنوان قسم
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  // الحصول على لون المؤشر بناءً على القيمة
  Color _getIndicatorColor(double value, double threshold1, double threshold2) {
    if (value < threshold1) {
      return AppColors.error;
    } else if (value < threshold2) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  // الحصول على لون معدل الخروج
  Color _getExitRateColor(double exitRate) {
    if (exitRate > 15) {
      return AppColors.error;
    } else if (exitRate > 8) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }
}

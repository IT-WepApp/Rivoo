import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../../../shared_libs/lib/theme/app_colors.dart';

/// صفحة الملف الشخصي للبائع
class SellerProfilePage extends ConsumerStatefulWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends ConsumerState<SellerProfilePage> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  // بيانات الملف الشخصي
  String _sellerName = '';
  String _sellerEmail = '';
  String _sellerPhone = '';
  String _sellerAddress = '';
  String _sellerProfileImage = '';
  String _storeName = '';
  String _storeDescription = '';
  String _storeCategory = '';
  String _storeCreationDate = '';
  int _totalProducts = 0;
  int _totalOrders = 0;
  double _totalRevenue = 0;
  double _rating = 0;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // هنا يتم تحميل بيانات الملف الشخصي من Firebase
      // في هذا المثال، نستخدم بيانات وهمية
      
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _sellerName = 'محمد أحمد';
        _sellerEmail = 'seller@rivosy.com';
        _sellerPhone = '0512345678';
        _sellerAddress = 'الرياض، المملكة العربية السعودية';
        _sellerProfileImage = 'https://randomuser.me/api/portraits/men/32.jpg';
        _storeName = 'متجر الريفوسي';
        _storeDescription = 'متجر متخصص في بيع المنتجات الغذائية الطازجة';
        _storeCategory = 'مواد غذائية';
        _storeCreationDate = '15 يناير 2023';
        _totalProducts = 48;
        _totalOrders = 156;
        _totalRevenue = 12580.50;
        _rating = 4.7;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل بيانات الملف الشخصي: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(RouteConstants.editProfile),
            tooltip: 'تعديل الملف الشخصي',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteConstants.settings),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل بيانات الملف الشخصي...')
          : _errorMessage.isNotEmpty
              ? AppWidgets.errorMessage(
                  message: _errorMessage,
                  onRetry: _loadProfileData,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات البائع الأساسية
                      _buildSellerBasicInfo(theme),
                      const SizedBox(height: 24),
                      
                      // معلومات المتجر
                      _buildSectionTitle(theme, 'معلومات المتجر'),
                      _buildStoreInfo(theme),
                      const SizedBox(height: 24),
                      
                      // إحصائيات المتجر
                      _buildSectionTitle(theme, 'إحصائيات المتجر'),
                      _buildStoreStats(theme),
                      const SizedBox(height: 24),
                      
                      // الإجراءات السريعة
                      _buildSectionTitle(theme, 'إجراءات سريعة'),
                      _buildQuickActions(theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildSellerBasicInfo(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة الملف الشخصي
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: _sellerProfileImage.isNotEmpty
                  ? NetworkImage(_sellerProfileImage)
                  : null,
              child: _sellerProfileImage.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // معلومات البائع
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sellerName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sellerEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sellerPhone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _sellerAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoreInfo(ThemeData theme) {
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
                const Icon(
                  Icons.store,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _storeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _storeCategory,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _storeDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'تاريخ الإنشاء: $_storeCreationDate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'التقييم: $_rating/5',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoreStats(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          theme,
          'المنتجات',
          _totalProducts.toString(),
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatCard(
          theme,
          'الطلبات',
          _totalOrders.toString(),
          Icons.shopping_bag,
          AppColors.success,
        ),
        _buildStatCard(
          theme,
          'الإيرادات',
          '${_totalRevenue.toStringAsFixed(2)} ر.س',
          Icons.attach_money,
          AppColors.secondary,
        ),
        _buildStatCard(
          theme,
          'التقييم',
          '$_rating/5',
          Icons.star,
          AppColors.warning,
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
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionButton(
              theme,
              'إضافة منتج جديد',
              Icons.add_circle,
              AppColors.success,
              () => context.push(RouteConstants.addProduct),
            ),
            const Divider(),
            _buildActionButton(
              theme,
              'إدارة المخزون',
              Icons.inventory,
              AppColors.info,
              () => context.push(RouteConstants.inventory),
            ),
            const Divider(),
            _buildActionButton(
              theme,
              'عرض الطلبات الجديدة',
              Icons.shopping_bag,
              AppColors.warning,
              () => context.push(RouteConstants.orders),
            ),
            const Divider(),
            _buildActionButton(
              theme,
              'عرض الإحصائيات',
              Icons.bar_chart,
              AppColors.secondary,
              () => context.push(RouteConstants.statistics),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/features/profile/domain/entities/user.dart';

/// شاشة الملف الشخصي
class ProfileScreen extends StatefulWidget {
  /// إنشاء شاشة الملف الشخصي
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// تحميل بيانات الملف الشخصي
  Future<void> _loadUserProfile() async {
    // في الواقع، سيتم استدعاء واجهة برمجة التطبيقات لجلب بيانات المستخدم
    // هذا مجرد تنفيذ وهمي لأغراض العرض
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      // بيانات وهمية للمستخدم
      _user = User(
        id: '123',
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        phone: '+201234567890',
        avatarUrl: 'https://example.com/avatar.jpg',
        type: UserType.premium,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        lastLoginAt: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // الانتقال إلى شاشة الإعدادات
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // معلومات المستخدم الأساسية
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  // صورة المستخدم
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _user.avatarUrl != null
                        ? NetworkImage(_user.avatarUrl!)
                        : null,
                    child: _user.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // اسم المستخدم
                  Text(
                    _user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // نوع المستخدم
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getUserTypeText(_user.type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // البريد الإلكتروني
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  
                  // رقم الهاتف
                  if (_user.phone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _user.phone!,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // زر تعديل الملف الشخصي
                  ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى شاشة تعديل الملف الشخصي
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('تعديل الملف الشخصي'),
                  ),
                ],
              ),
            ),
            
            // قائمة الخيارات
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOptionCard(
                    icon: Icons.shopping_bag,
                    title: 'طلباتي',
                    subtitle: 'عرض سجل الطلبات السابقة',
                    onTap: () {
                      // الانتقال إلى شاشة الطلبات
                      Navigator.pushNamed(context, '/orders');
                    },
                  ),
                  
                  _buildOptionCard(
                    icon: Icons.favorite,
                    title: 'المفضلة',
                    subtitle: 'عرض المنتجات المفضلة',
                    onTap: () {
                      // الانتقال إلى شاشة المفضلة
                      Navigator.pushNamed(context, '/favorites');
                    },
                  ),
                  
                  _buildOptionCard(
                    icon: Icons.location_on,
                    title: 'العناوين',
                    subtitle: 'إدارة عناوين الشحن',
                    onTap: () {
                      // الانتقال إلى شاشة العناوين
                      Navigator.pushNamed(context, '/addresses');
                    },
                  ),
                  
                  _buildOptionCard(
                    icon: Icons.payment,
                    title: 'طرق الدفع',
                    subtitle: 'إدارة بطاقات الائتمان وطرق الدفع',
                    onTap: () {
                      // الانتقال إلى شاشة طرق الدفع
                      Navigator.pushNamed(context, '/payment-methods');
                    },
                  ),
                  
                  _buildOptionCard(
                    icon: Icons.headset_mic,
                    title: 'الدعم الفني',
                    subtitle: 'الاتصال بفريق الدعم الفني',
                    onTap: () {
                      // الانتقال إلى شاشة الدعم الفني
                      Navigator.pushNamed(context, '/support');
                    },
                  ),
                  
                  _buildOptionCard(
                    icon: Icons.info,
                    title: 'عن التطبيق',
                    subtitle: 'معلومات عن التطبيق والإصدار',
                    onTap: () {
                      // عرض معلومات التطبيق
                      _showAboutDialog(context);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // زر تسجيل الخروج
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // تسجيل الخروج
                        _confirmLogout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة خيار
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// الحصول على نص نوع المستخدم
  String _getUserTypeText(UserType type) {
    switch (type) {
      case UserType.regular:
        return 'مستخدم عادي';
      case UserType.premium:
        return 'مستخدم مميز';
      case UserType.admin:
        return 'مسؤول';
      default:
        return 'مستخدم';
    }
  }

  /// عرض مربع حوار تأكيد تسجيل الخروج
  Future<void> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // تنفيذ تسجيل الخروج
      // في الواقع، سيتم استدعاء خدمة المصادقة لتسجيل الخروج
      // ثم الانتقال إلى شاشة تسجيل الدخول
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// عرض مربع حوار معلومات التطبيق
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.shopping_cart,
                  size: 80,
                  color: AppTheme.primaryColor,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Rivoo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('الإصدار 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'تطبيق تسوق إلكتروني يوفر تجربة تسوق سهلة وممتعة.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Rivoo. جميع الحقوق محفوظة.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

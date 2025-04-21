import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';


/// بطاقة الفئة
class CategoryCard extends StatelessWidget {
  /// معرف الفئة
  final String id;
  
  /// اسم الفئة
  final String name;
  
  /// عنوان صورة الفئة
  final String imageUrl;
  
  /// عدد المنتجات في الفئة
  final int productCount;
  
  /// دالة تنفذ عند النقر على البطاقة
  final VoidCallback? onTap;

  /// إنشاء بطاقة فئة
  const CategoryCard({
    Key? key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة الفئة
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.category,
                      size: 32,
                      color: AppTheme.primaryColor,
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // اسم الفئة
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // عدد المنتجات
            Text(
              '$productCount منتج',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

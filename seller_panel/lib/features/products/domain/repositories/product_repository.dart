import '../entities/product_entity.dart';

// واجهة مستودع المنتجات في طبقة Domain
// تحدد العمليات التي يمكن إجراؤها على المنتجات بشكل مستقل عن التنفيذ

abstract class ProductRepository {
  // الحصول على قائمة المنتجات للبائع
  Future<List<ProductEntity>> getProducts(String sellerId);
  
  // الحصول على منتج محدد بواسطة المعرف
  Future<ProductEntity?> getProductById(String productId);
  
  // إضافة منتج جديد
  Future<String> addProduct(ProductEntity product);
  
  // تحديث منتج موجود
  Future<bool> updateProduct(ProductEntity product);
  
  // حذف منتج
  Future<bool> deleteProduct(String productId);
  
  // تغيير حالة توفر المنتج
  Future<bool> toggleProductAvailability(String productId, bool isAvailable);
  
  // رفع صور متعددة للمنتج
  Future<List<String>> uploadProductImages(String productId, List<String> localImagePaths);
  
  // حذف صورة من صور المنتج
  Future<bool> deleteProductImage(String productId, String imageUrl);
}

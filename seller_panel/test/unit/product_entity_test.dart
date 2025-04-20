import 'package:flutter_test/flutter_test.dart';
import 'package:seller_panel/features/products/domain/entities/product_entity.dart';

void main() {
  group('ProductEntity', () {
    test('يجب أن يتم إنشاء كيان المنتج بشكل صحيح', () {
      // الإعداد
      final productEntity = ProductEntity(
        id: '1',
        name: 'منتج اختبار',
        description: 'وصف المنتج للاختبار',
        price: 100.0,
        imageUrls: ['url1', 'url2'],
        category: 'فئة الاختبار',
        isAvailable: true,
        sellerId: 'seller1',
        createdAt: DateTime(2025, 4, 20),
        updatedAt: DateTime(2025, 4, 20),
        stockQuantity: 10,
      );

      // التحقق
      expect(productEntity.id, '1');
      expect(productEntity.name, 'منتج اختبار');
      expect(productEntity.description, 'وصف المنتج للاختبار');
      expect(productEntity.price, 100.0);
      expect(productEntity.imageUrls, ['url1', 'url2']);
      expect(productEntity.category, 'فئة الاختبار');
      expect(productEntity.isAvailable, true);
      expect(productEntity.sellerId, 'seller1');
      expect(productEntity.createdAt, DateTime(2025, 4, 20));
      expect(productEntity.updatedAt, DateTime(2025, 4, 20));
      expect(productEntity.stockQuantity, 10);
    });

    test('يجب أن تعمل دالة copyWith بشكل صحيح', () {
      // الإعداد
      final productEntity = ProductEntity(
        id: '1',
        name: 'منتج اختبار',
        description: 'وصف المنتج للاختبار',
        price: 100.0,
        imageUrls: ['url1'],
        category: 'فئة الاختبار',
        isAvailable: true,
        sellerId: 'seller1',
        createdAt: DateTime(2025, 4, 20),
        updatedAt: DateTime(2025, 4, 20),
        stockQuantity: 10,
      );

      // التنفيذ
      final updatedProduct = productEntity.copyWith(
        name: 'منتج محدث',
        price: 150.0,
        imageUrls: ['url1', 'url2', 'url3'],
        isAvailable: false,
      );

      // التحقق
      expect(updatedProduct.id, '1'); // لم يتغير
      expect(updatedProduct.name, 'منتج محدث'); // تم تحديثه
      expect(updatedProduct.description, 'وصف المنتج للاختبار'); // لم يتغير
      expect(updatedProduct.price, 150.0); // تم تحديثه
      expect(updatedProduct.imageUrls, ['url1', 'url2', 'url3']); // تم تحديثه
      expect(updatedProduct.category, 'فئة الاختبار'); // لم يتغير
      expect(updatedProduct.isAvailable, false); // تم تحديثه
      expect(updatedProduct.sellerId, 'seller1'); // لم يتغير
      expect(updatedProduct.createdAt, DateTime(2025, 4, 20)); // لم يتغير
      expect(updatedProduct.updatedAt, DateTime(2025, 4, 20)); // لم يتغير
      expect(updatedProduct.stockQuantity, 10); // لم يتغير
    });

    test('يجب أن يدعم قائمة صور متعددة', () {
      // الإعداد
      final productEntity = ProductEntity(
        id: '1',
        name: 'منتج اختبار',
        description: 'وصف المنتج للاختبار',
        price: 100.0,
        imageUrls: ['url1', 'url2', 'url3', 'url4', 'url5'],
        category: 'فئة الاختبار',
        isAvailable: true,
        sellerId: 'seller1',
        createdAt: DateTime(2025, 4, 20),
        updatedAt: DateTime(2025, 4, 20),
        stockQuantity: 10,
      );

      // التحقق
      expect(productEntity.imageUrls.length, 5);
      expect(productEntity.imageUrls[0], 'url1');
      expect(productEntity.imageUrls[4], 'url5');
    });
  });
}

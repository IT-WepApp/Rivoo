import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/product_firebase_datasource.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// تنفيذ مستودع المنتجات باستخدام مصدر بيانات Firebase
class ProductRepositoryImpl implements ProductRepository {
  final ProductFirebaseDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<ProductEntity>> getProducts(String sellerId) async {
    final productsData = await dataSource.getProducts(sellerId);
    return productsData.map((data) => _mapToEntity(data)).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    final productData = await dataSource.getProductById(productId);
    if (productData == null) return null;
    return _mapToEntity(productData);
  }

  @override
  Future<String> addProduct(ProductEntity product) async {
    final productData = _mapFromEntity(product);
    return await dataSource.addProduct(productData);
  }

  @override
  Future<bool> updateProduct(ProductEntity product) async {
    final productData = _mapFromEntity(product);
    return await dataSource.updateProduct(product.id, productData);
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    return await dataSource.deleteProduct(productId);
  }

  @override
  Future<bool> toggleProductAvailability(String productId, bool isAvailable) async {
    return await dataSource.toggleProductAvailability(productId, isAvailable);
  }

  @override
  Future<List<String>> uploadProductImages(String productId, List<String> localImagePaths) async {
    return await dataSource.uploadProductImages(productId, localImagePaths);
  }

  @override
  Future<bool> deleteProductImage(String productId, String imageUrl) async {
    return await dataSource.deleteProductImage(productId, imageUrl);
  }

  // تحويل من Map إلى كيان المنتج
  ProductEntity _mapToEntity(Map<String, dynamic> data) {
    return ProductEntity(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      sellerId: data['sellerId'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      attributes: data['attributes'],
      stockQuantity: data['stockQuantity'] ?? 0,
    );
  }

  // تحويل من كيان المنتج إلى Map
  Map<String, dynamic> _mapFromEntity(ProductEntity entity) {
    return {
      'name': entity.name,
      'description': entity.description,
      'price': entity.price,
      'imageUrls': entity.imageUrls,
      'category': entity.category,
      'isAvailable': entity.isAvailable,
      'sellerId': entity.sellerId,
      'createdAt': entity.id.isEmpty ? FieldValue.serverTimestamp() : entity.createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'attributes': entity.attributes,
      'stockQuantity': entity.stockQuantity,
    };
  }
}

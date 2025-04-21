import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// تعريف نموذج المنتج المبسط للاستخدام المحلي
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String categoryId;
  final String storeId;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.storeId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      categoryId: json['categoryId'] ?? '',
      storeId: json['storeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'storeId': storeId,
    };
  }
}

class FavoritesNotifier extends Notifier<List<ProductModel>> {
  late final String? userId;
  late final FirebaseFirestore _firestore;

  @override
  List<ProductModel> build() {
    userId = ref.watch(userIdProvider);
    _firestore = FirebaseFirestore.instance;
    
    // تأجيل تحميل المفضلات إلى ما بعد بناء الحالة الأولية
    Future.microtask(() {
      if (userId != null) {
        _loadFavorites();
      } else {
        _loadLocalFavorites();
      }
    });
    
    return [];
  }

  Future<void> _loadFavorites() async {
    if (userId == null) return;

    try {
      // تحميل المفضلة من Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final favorites = snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      state = favorites;

      // حفظ المفضلة محلياً أيضاً
      _saveLocalFavorites(favorites);
    } catch (e) {
      print('خطأ في تحميل المفضلة: $e');
      // في حالة الفشل، تحميل المفضلة المحلية
      _loadLocalFavorites();
    }
  }

  Future<void> _loadLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];

      final favorites = favoritesJson.map((json) {
        final data = jsonDecode(json);
        return ProductModel(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      state = favorites;
    } catch (e) {
      print('خطأ في تحميل المفضلة المحلية: $e');
    }
  }

  Future<void> _saveLocalFavorites(List<ProductModel> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((product) {
        return jsonEncode(product.toJson());
      }).toList();

      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      print('خطأ في حفظ المفضلة المحلية: $e');
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> productData) async {
    final product = ProductModel.fromJson(productData);
    final isFavorite = state.any((p) => p.id == product.id);

    if (isFavorite) {
      // إزالة من المفضلة
      state = state.where((p) => p.id != product.id).toList();

      if (userId != null) {
        try {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .doc(product.id)
              .delete();
        } catch (e) {
          print('خطأ في إزالة المنتج من المفضلة: $e');
        }
      }
    } else {
      // إضافة إلى المفضلة
      state = [...state, product];

      if (userId != null) {
        try {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .doc(product.id)
              .set({
            'name': product.name,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'categoryId': product.categoryId,
            'storeId': product.storeId,
            'addedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('خطأ في إضافة المنتج إلى المفضلة: $e');
        }
      }
    }

    // حفظ المفضلة محلياً
    _saveLocalFavorites(state);
  }

  bool isFavorite(String productId) {
    return state.any((product) => product.id == productId);
  }

  Future<void> clearFavorites() async {
    state = [];

    if (userId != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        print('خطأ في حذف جميع المفضلة: $e');
      }
    }

    // حذف المفضلة المحلية
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorites');
    } catch (e) {
      print('خطأ في حذف المفضلة المحلية: $e');
    }
  }

  Future<void> syncFavorites() async {
    if (userId == null) return;

    try {
      // تحميل المفضلة من Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final remoteFavorites = snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      // تحميل المفضلة المحلية
      final prefs = await SharedPreferences.getInstance();
      final localFavoritesJson = prefs.getStringList('favorites') ?? [];

      final localFavorites = localFavoritesJson.map((json) {
        final data = jsonDecode(json);
        return ProductModel(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      // دمج المفضلة المحلية والبعيدة
      final mergedFavorites = <ProductModel>[];
      final mergedIds = <String>{};

      // إضافة المفضلة البعيدة
      for (final product in remoteFavorites) {
        if (!mergedIds.contains(product.id)) {
          mergedFavorites.add(product);
          mergedIds.add(product.id);
        }
      }

      // إضافة المفضلة المحلية التي لم تكن موجودة في البعيدة
      for (final product in localFavorites) {
        if (!mergedIds.contains(product.id)) {
          mergedFavorites.add(product);
          mergedIds.add(product.id);

          // إضافة المنتج إلى Firestore
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .doc(product.id)
              .set({
            'name': product.name,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'categoryId': product.categoryId,
            'storeId': product.storeId,
            'addedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      state = mergedFavorites;

      // حفظ المفضلة المدمجة محلياً
      _saveLocalFavorites(mergedFavorites);
    } catch (e) {
      print('خطأ في مزامنة المفضلة: $e');
    }
  }
}

// مزود لمعرف المستخدم الحالي
final userIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.userData?.uid;
});

// مزود للمفضلات
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<ProductModel>>(() {
  return FavoritesNotifier();
});

// مزود لمعرفة ما إذا كان منتج معين في المفضلة
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((product) => product.id == productId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesNotifier extends StateNotifier<List<Product>> {
  final String? userId;
  final FirebaseFirestore _firestore;

  FavoritesNotifier(this.userId, this._firestore) : super([]) {
    if (userId != null) {
      _loadFavorites();
    } else {
      _loadLocalFavorites();
    }
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
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'],
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
        return Product(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'],
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      state = favorites;
    } catch (e) {
      print('خطأ في تحميل المفضلة المحلية: $e');
    }
  }

  Future<void> _saveLocalFavorites(List<Product> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((product) {
        return jsonEncode({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'categoryId': product.categoryId,
          'storeId': product.storeId,
        });
      }).toList();

      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      print('خطأ في حفظ المفضلة المحلية: $e');
    }
  }

  Future<void> toggleFavorite(Product product) async {
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
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'],
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      // تحميل المفضلة المحلية
      final prefs = await SharedPreferences.getInstance();
      final localFavoritesJson = prefs.getStringList('favorites') ?? [];

      final localFavorites = localFavoritesJson.map((json) {
        final data = jsonDecode(json);
        return Product(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'],
          categoryId: data['categoryId'] ?? '',
          storeId: data['storeId'] ?? '',
        );
      }).toList();

      // دمج المفضلة المحلية والبعيدة
      final mergedFavorites = <Product>[];
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

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Product>>((ref) {
  final userId = ref.watch(userIdProvider);
  final firestore = FirebaseFirestore.instance;
  return FavoritesNotifier(userId, firestore);
});

// مزود لمعرفة ما إذا كان منتج معين في المفضلة
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((product) => product.id == productId);
});

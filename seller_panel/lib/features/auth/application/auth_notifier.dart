import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // يحتوي على SellerModel

class AuthNotifier extends StateNotifier<SellerModel?> {
  AuthNotifier() : super(null); // بالبداية المستخدم غير مسجل دخول

  Future<void> signIn(String email, String password) async {
    // من المفترض هنا استدعاء خدمة تسجيل دخول حقيقية
    if (email == 'seller@example.com' && password == 'password') {
      state = const SellerModel(
        id: '1',
        name: 'Seller User',
        email: 'seller@example.com',
        storeId: 'store_123',
      );
    } else {
      state = null; // فشل تسجيل الدخول
    }
  }

  Future<void> signOut() async {
    state = null;
  }
}

// مزود لـ AuthNotifier
final sellerAuthProvider =
    StateNotifierProvider<AuthNotifier, SellerModel?>((ref) {
  return AuthNotifier();
});

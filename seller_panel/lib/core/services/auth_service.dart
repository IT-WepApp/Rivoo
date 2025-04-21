import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';
import '../constants/app_constants.dart';

/// خدمة المصادقة للبائعين
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecureStorageService _secureStorage = SecureStorageServiceImpl();

  // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // التحقق من أن المستخدم هو بائع
      final user = userCredential.user;
      if (user != null) {
        final isSeller = await _checkSellerRole(user.uid);
        if (isSeller) {
          // تخزين بيانات المصادقة بشكل آمن
          await _secureStorage.storeUserId(user.uid);
          await _secureStorage.storeAuthToken(await user.getIdToken() ?? '');

          // تحديث آخر تسجيل دخول في Firestore
          await _updateLastLogin(user.uid);

          return user;
        } else {
          // إذا لم يكن المستخدم بائعاً، قم بتسجيل الخروج
          await signOut();
          throw Exception('المستخدم ليس بائعاً');
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // تسجيل حساب جديد للبائع
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String storeName,
    String phoneNumber,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // إنشاء وثيقة البائع في Firestore
        await _createSellerDocument(
          user.uid,
          email,
          name,
          storeName,
          phoneNumber,
        );

        // تخزين بيانات المصادقة بشكل آمن
        await _secureStorage.storeUserId(user.uid);
        await _secureStorage.storeAuthToken(await user.getIdToken() ?? '');

        // إرسال بريد تأكيد الحساب
        await user.sendEmailVerification();

        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // إنشاء وثيقة البائع في Firestore
  Future<void> _createSellerDocument(
    String uid,
    String email,
    String name,
    String storeName,
    String phoneNumber,
  ) async {
    await _firestore.collection(AppConstants.sellersCollection).doc(uid).set({
      'email': email,
      'name': name,
      'storeName': storeName,
      'phoneNumber': phoneNumber,
      'role': AppConstants.sellerRole,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
      'storeLogoUrl': '',
      'storeBannerUrl': '',
      'storeDescription': '',
      'storeAddress': '',
      'storeLocation': null, // GeoPoint will be added later
      'deliveryAreas': [],
      'minOrderAmount': 0,
      'deliveryFee': 0,
      'averageRating': 0,
      'totalRatings': 0,
      'fcmTokens': [],
    });
  }

  // تحديث آخر تسجيل دخول في Firestore
  Future<void> _updateLastLogin(String uid) async {
    await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(uid)
        .update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // التحقق من أن المستخدم هو بائع
  Future<bool> _checkSellerRole(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(uid)
          .get();
      return doc.exists && doc.data()?['role'] == AppConstants.sellerRole;
    } catch (e) {
      return false;
    }
  }

  // إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.clearAuthData();
  }

  // الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // التحقق من حالة تسجيل الدخول
  Future<bool> isSignedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final isSeller = await _checkSellerRole(currentUser.uid);
      return isSeller;
    }
    return false;
  }

  // الحصول على معرف المستخدم الحالي
  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }

    // محاولة استرجاع المعرف من التخزين الآمن
    return await _secureStorage.getUserId();
  }

  // تحديث بيانات البائع
  Future<void> updateSellerProfile({
    String? name,
    String? storeName,
    String? phoneNumber,
    String? storeDescription,
    String? storeAddress,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (storeName != null) updateData['storeName'] = storeName;
    if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
    if (storeDescription != null) {
      updateData['storeDescription'] = storeDescription;
    }
    if (storeAddress != null) updateData['storeAddress'] = storeAddress;

    if (updateData.isNotEmpty) {
      await _firestore
          .collection(AppConstants.sellersCollection)
          .doc(userId)
          .update(updateData);
    }
  }

  // تحديث كلمة المرور
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // إعادة المصادقة قبل تغيير كلمة المرور
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // الحصول على بيانات البائع
  Future<Map<String, dynamic>?> getSellerData() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      return null;
    }

    final doc = await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(userId)
        .get();
    if (doc.exists) {
      return doc.data();
    }

    return null;
  }

  // تحديث رمز FCM للإشعارات
  Future<void> updateFcmToken(String token) async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      return;
    }

    await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(userId)
        .update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  // حذف رمز FCM للإشعارات
  Future<void> removeFcmToken(String token) async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      return;
    }

    await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(userId)
        .update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}

// مزود خدمة المصادقة
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// مزود حالة المصادقة
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// مزود بيانات البائع
final sellerDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getSellerData();
});

// مزود حالة تسجيل الدخول
final isSignedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isSignedIn();
});

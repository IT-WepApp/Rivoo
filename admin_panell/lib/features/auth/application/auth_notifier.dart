import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/services/crashlytics_manager.dart';

class AuthNotifier extends StateNotifier<AdminModel?> {
  final FirebaseAuth _auth;
  final SecureStorageServiceImpl _secureStorage;
  final CrashlyticsManager _crashlytics;

  AuthNotifier({
    FirebaseAuth? auth,
    SecureStorageServiceImpl? secureStorage,
    CrashlyticsManager? crashlytics,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _secureStorage = secureStorage ?? secureStorageServiceProvider,
       _crashlytics = crashlytics ?? crashlyticsManagerProvider,
       super(null);

  Future<void> signIn(String email, String password) async {
    try {
      // استخدام Firebase Authentication للمصادقة
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }
      
      // تخزين توكن المصادقة بشكل آمن
      final token = await userCredential.user!.getIdToken();
      await _secureStorage.saveAccessToken(token);
      await _secureStorage.saveUserId(userCredential.user!.uid);
      
      // تعيين معرف المستخدم في Crashlytics لتسهيل تتبع الأخطاء
      await _crashlytics.setUserIdentifier(userCredential.user!.uid);
      
      // في الحالة الحقيقية، يجب استرداد بيانات المستخدم من Firestore أو API
      // هذا مجرد مثال مبسط
      final adminUser = AdminModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'Admin User',
      );
      
      // تخزين اسم المستخدم بشكل آمن
      await _secureStorage.saveUserName(adminUser.name);
      
      // تحديث حالة المصادقة
      state = adminUser;
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await _crashlytics.recordError(e, stack);
      
      // إعادة رمي الاستثناء ليتم التعامل معه في واجهة المستخدم
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // تسجيل الخروج من Firebase
      await _auth.signOut();
      
      // مسح البيانات المخزنة بشكل آمن
      await _secureStorage.clearAuthData();
      
      // تحديث حالة المصادقة
      state = null;
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await _crashlytics.recordError(e, stack);
      
      // إعادة رمي الاستثناء ليتم التعامل معه في واجهة المستخدم
      rethrow;
    }
  }
  
  // التحقق من حالة المصادقة الحالية
  Future<void> checkAuthStatus() async {
    try {
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        // التحقق من وجود توكن مخزن
        final token = await _secureStorage.getAccessToken();
        final userId = await _secureStorage.getUserId();
        final userName = await _secureStorage.getUserName();
        
        if (token != null && userId != null && userName != null) {
          // إذا كان هناك توكن مخزن، نحاول استعادة الجلسة
          state = AdminModel(
            id: userId,
            name: userName,
          );
          
          // تعيين معرف المستخدم في Crashlytics
          await _crashlytics.setUserIdentifier(userId);
        } else {
          state = null;
        }
      } else {
        // المستخدم مسجل الدخول بالفعل
        final userName = currentUser.displayName ?? 'Admin User';
        
        state = AdminModel(
          id: currentUser.uid,
          name: userName,
        );
        
        // تخزين بيانات المستخدم بشكل آمن
        await _secureStorage.saveUserId(currentUser.uid);
        await _secureStorage.saveUserName(userName);
        
        // تعيين معرف المستخدم في Crashlytics
        await _crashlytics.setUserIdentifier(currentUser.uid);
      }
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await _crashlytics.recordError(e, stack);
      
      // في حالة حدوث خطأ، نعتبر المستخدم غير مسجل الدخول
      state = null;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AdminModel?>((ref) => AuthNotifier());

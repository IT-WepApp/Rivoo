import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

/// خدمة المصادقة المحسنة مع دعم المصادقة متعددة العوامل
class EnhancedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // مفاتيح التخزين الآمن
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _mfaEnabledKey = 'mfa_enabled';
  static const String _lastActivityKey = 'last_activity';
  static const String _deviceIdKey = 'device_id';
  
  // مدة صلاحية الجلسة (30 يوم)
  static const int _sessionExpiryDays = 30;
  
  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // التحقق من تفعيل المصادقة متعددة العوامل
        final isMfaEnabled = await _isMfaEnabled(user.uid);
        
        if (isMfaEnabled) {
          // إذا كانت المصادقة متعددة العوامل مفعلة، فلا نقوم بتخزين الرموز حتى يتم التحقق
          return user;
        } else {
          // إذا لم تكن المصادقة متعددة العوامل مفعلة، نقوم بتخزين الرموز مباشرة
          await _storeUserSession(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  /// التحقق من رمز المصادقة متعددة العوامل
  Future<bool> verifyMfaCode(String code) async {
    try {
      // هنا يتم التحقق من صحة الرمز المدخل
      // في حالة استخدام Firebase، يمكن استخدام PhoneAuthProvider أو تطبيق مخصص
      
      // هذا مثال بسيط للتوضيح فقط
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // في التطبيق الحقيقي، يجب التحقق من الرمز بشكل صحيح
      // مثلاً باستخدام Firebase Phone Auth أو TOTP
      
      // بعد التحقق الناجح، نقوم بتخزين الجلسة
      await _storeUserSession(user);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// تفعيل المصادقة متعددة العوامل
  Future<bool> enableMfa(String phoneNumber) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // في التطبيق الحقيقي، هنا يتم ربط رقم الهاتف بحساب المستخدم
      // أو إعداد TOTP (Time-based One-Time Password)
      
      // تخزين حالة تفعيل المصادقة متعددة العوامل
      await _secureStorage.write(key: '${_mfaEnabledKey}_${user.uid}', value: 'true');
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// تعطيل المصادقة متعددة العوامل
  Future<bool> disableMfa() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // في التطبيق الحقيقي، هنا يتم إلغاء ربط رقم الهاتف من حساب المستخدم
      // أو تعطيل TOTP
      
      // تخزين حالة تفعيل المصادقة متعددة العوامل
      await _secureStorage.write(key: '${_mfaEnabledKey}_${user.uid}', value: 'false');
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// التحقق من تفعيل المصادقة متعددة العوامل
  Future<bool> _isMfaEnabled(String userId) async {
    final value = await _secureStorage.read(key: '${_mfaEnabledKey}_$userId');
    return value == 'true';
  }
  
  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserSession();
    } catch (e) {
      rethrow;
    }
  }
  
  /// التحقق من حالة المصادقة
  Future<bool> isAuthenticated() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    // التحقق من صلاحية الجلسة
    final isSessionValid = await _isSessionValid();
    if (!isSessionValid) {
      await signOut();
      return false;
    }
    
    // تحديث وقت آخر نشاط
    await _updateLastActivity();
    
    return true;
  }
  
  /// الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  /// تخزين جلسة المستخدم
  Future<void> _storeUserSession(User user) async {
    try {
      // الحصول على رمز الوصول من Firebase
      final idToken = await user.getIdToken();
      
      // إنشاء معرف فريد للجهاز إذا لم يكن موجوداً
      final deviceId = await _getOrCreateDeviceId();
      
      // تخزين رموز المصادقة بشكل آمن
      await _secureStorage.write(key: _accessTokenKey, value: idToken);
      await _secureStorage.write(key: _userIdKey, value: user.uid);
      
      // تخزين دور المستخدم (يمكن الحصول عليه من Firestore أو claims)
      // هذا مثال بسيط، في التطبيق الحقيقي يجب الحصول على الدور من مصدر موثوق
      await _secureStorage.write(key: _userRoleKey, value: 'user');
      
      // تخزين وقت انتهاء صلاحية الجلسة
      final expiryDate = DateTime.now().add(Duration(days: _sessionExpiryDays));
      await _secureStorage.write(
        key: _tokenExpiryKey,
        value: expiryDate.millisecondsSinceEpoch.toString(),
      );
      
      // تحديث وقت آخر نشاط
      await _updateLastActivity();
    } catch (e) {
      rethrow;
    }
  }
  
  /// مسح جلسة المستخدم
  Future<void> _clearUserSession() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _userRoleKey);
    await _secureStorage.delete(key: _lastActivityKey);
    // لا نقوم بحذف معرف الجهاز لأنه يستخدم للتعرف على الجهاز
  }
  
  /// التحقق من صلاحية الجلسة
  Future<bool> _isSessionValid() async {
    try {
      // التحقق من وجود رمز الوصول
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken == null) return false;
      
      // التحقق من تاريخ انتهاء الصلاحية
      final expiryString = await _secureStorage.read(key: _tokenExpiryKey);
      if (expiryString == null) return false;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
      if (DateTime.now().isAfter(expiryDate)) return false;
      
      // التحقق من وقت آخر نشاط
      final lastActivityString = await _secureStorage.read(key: _lastActivityKey);
      if (lastActivityString != null) {
        final lastActivity = DateTime.fromMillisecondsSinceEpoch(int.parse(lastActivityString));
        final inactivityDuration = DateTime.now().difference(lastActivity);
        
        // إذا لم يكن هناك نشاط لمدة 7 أيام، نقوم بتسجيل الخروج
        if (inactivityDuration.inDays > 7) {
          return false;
        }
      }
      
      // التحقق من معرف الجهاز
      final storedDeviceId = await _secureStorage.read(key: _deviceIdKey);
      final currentDeviceId = await _getDeviceId();
      if (storedDeviceId != currentDeviceId) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// تحديث وقت آخر نشاط
  Future<void> _updateLastActivity() async {
    await _secureStorage.write(
      key: _lastActivityKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
  
  /// الحصول على معرف الجهاز أو إنشاء معرف جديد
  Future<String> _getOrCreateDeviceId() async {
    final deviceId = await _getDeviceId();
    if (deviceId != null) return deviceId;
    
    // إنشاء معرف جديد
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final newDeviceId = base64Url.encode(values);
    
    // تخزين المعرف الجديد
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, newDeviceId);
    
    return newDeviceId;
  }
  
  /// الحصول على معرف الجهاز المخزن
  Future<String?> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }
  
  /// تغيير كلمة المرور
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;
      
      // إعادة المصادقة قبل تغيير كلمة المرور
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// تسجيل مستخدم جديد
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // تحديث اسم المستخدم
        await user.updateDisplayName(name);
        
        // تخزين جلسة المستخدم
        await _storeUserSession(user);
        
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  /// الحصول على رمز الوصول الحالي
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  /// الحصول على دور المستخدم الحالي
  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: _userRoleKey);
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:user_app/core/utils/encryption_utils.dart';

part 'secure_storage_service.g.dart';

/// خدمة التخزين الآمن المحسنة
/// توفر تخزينًا آمنًا للبيانات الحساسة مع تشفير إضافي
class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  final EncryptionUtils _encryptionUtils;
  
  // مفاتيح التخزين
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _preferencesKey = 'user_preferences';
  
  SecureStorageService({
    required FlutterSecureStorage secureStorage,
    required EncryptionUtils encryptionUtils,
  }) : 
    _secureStorage = secureStorage,
    _encryptionUtils = encryptionUtils;

  /// حفظ رمز المصادقة بشكل آمن مع تشفير وتوقيت انتهاء الصلاحية
  Future<void> saveAuthToken(String token, {int expiryMinutes = 60}) async {
    final expiryTime = DateTime.now().add(Duration(minutes: expiryMinutes));
    final tokenData = {
      'token': token,
      'expiry': expiryTime.toIso8601String(),
    };
    
    final encryptedData = _encryptionUtils.encrypt(jsonEncode(tokenData));
    await _secureStorage.write(key: _tokenKey, value: encryptedData);
  }

  /// استرجاع رمز المصادقة مع التحقق من صلاحيته
  Future<String?> getAuthToken() async {
    try {
      final encryptedData = await _secureStorage.read(key: _tokenKey);
      if (encryptedData == null) return null;
      
      final decryptedData = _encryptionUtils.decrypt(encryptedData);
      final tokenData = jsonDecode(decryptedData) as Map<String, dynamic>;
      
      final expiryTime = DateTime.parse(tokenData['expiry']);
      if (DateTime.now().isAfter(expiryTime)) {
        // الرمز منتهي الصلاحية، قم بحذفه والعودة بقيمة فارغة
        await _secureStorage.delete(key: _tokenKey);
        return null;
      }
      
      return tokenData['token'] as String;
    } catch (e) {
      // في حالة وجود أي خطأ، قم بحذف الرمز والعودة بقيمة فارغة
      await _secureStorage.delete(key: _tokenKey);
      return null;
    }
  }

  /// حفظ رمز التحديث بشكل آمن
  Future<void> saveRefreshToken(String token) async {
    final encryptedToken = _encryptionUtils.encrypt(token);
    await _secureStorage.write(key: _refreshTokenKey, value: encryptedToken);
  }

  /// استرجاع رمز التحديث
  Future<String?> getRefreshToken() async {
    try {
      final encryptedToken = await _secureStorage.read(key: _refreshTokenKey);
      if (encryptedToken == null) return null;
      
      return _encryptionUtils.decrypt(encryptedToken);
    } catch (e) {
      return null;
    }
  }

  /// حفظ بيانات المستخدم بشكل آمن مع توقيع رقمي للتحقق من السلامة
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userDataString = jsonEncode(userData);
    
    // إنشاء توقيع رقمي للبيانات للتحقق من سلامتها
    final signature = _createSignature(userDataString);
    
    final dataWithSignature = {
      'data': userDataString,
      'signature': signature,
    };
    
    final encryptedData = _encryptionUtils.encrypt(jsonEncode(dataWithSignature));
    await _secureStorage.write(key: _userDataKey, value: encryptedData);
  }

  /// استرجاع بيانات المستخدم مع التحقق من سلامتها
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final encryptedData = await _secureStorage.read(key: _userDataKey);
      if (encryptedData == null) return null;
      
      final decryptedData = _encryptionUtils.decrypt(encryptedData);
      final dataMap = jsonDecode(decryptedData) as Map<String, dynamic>;
      
      final userDataString = dataMap['data'] as String;
      final signature = dataMap['signature'] as String;
      
      // التحقق من سلامة البيانات باستخدام التوقيع الرقمي
      if (_verifySignature(userDataString, signature)) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } else {
        // البيانات قد تكون تعرضت للعبث، قم بحذفها
        await _secureStorage.delete(key: _userDataKey);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// حفظ تفضيلات المستخدم
  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final encryptedData = _encryptionUtils.encrypt(jsonEncode(preferences));
    await _secureStorage.write(key: _preferencesKey, value: encryptedData);
  }

  /// استرجاع تفضيلات المستخدم
  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final encryptedData = await _secureStorage.read(key: _preferencesKey);
      if (encryptedData == null) return null;
      
      final decryptedData = _encryptionUtils.decrypt(encryptedData);
      return jsonDecode(decryptedData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// حفظ قيمة مخصصة بشكل آمن
  Future<void> saveSecureValue(String key, String value) async {
    final encryptedValue = _encryptionUtils.encrypt(value);
    await _secureStorage.write(key: key, value: encryptedValue);
  }

  /// استرجاع قيمة مخصصة
  Future<String?> getSecureValue(String key) async {
    try {
      final encryptedValue = await _secureStorage.read(key: key);
      if (encryptedValue == null) return null;
      
      return _encryptionUtils.decrypt(encryptedValue);
    } catch (e) {
      return null;
    }
  }

  /// حذف قيمة مخصصة
  Future<void> deleteSecureValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// حذف جميع البيانات المخزنة
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// إنشاء توقيع رقمي للبيانات باستخدام HMAC-SHA256
  String _createSignature(String data) {
    final key = _encryptionUtils.getSecretKey();
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// التحقق من صحة التوقيع الرقمي
  bool _verifySignature(String data, String signature) {
    final computedSignature = _createSignature(data);
    return computedSignature == signature;
  }
}

/// مزود خدمة التخزين الآمن
@riverpod
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  final secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  final encryptionUtils = EncryptionUtils();
  
  return SecureStorageService(
    secureStorage: secureStorage,
    encryptionUtils: encryptionUtils,
  );
}

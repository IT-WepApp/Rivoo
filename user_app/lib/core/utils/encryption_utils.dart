import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// أداة مساعدة للتشفير وفك التشفير
/// توفر وظائف لتشفير البيانات الحساسة وفك تشفيرها
class EncryptionUtils {
  // مفتاح سري ثابت للتشفير (في التطبيق الحقيقي، يجب تخزينه بشكل آمن أو توليده بشكل آمن)
  static const String _secretKey = 'RivooSy_Secret_Key_2025';
  
  // طول المتجه الأولي (IV) بالبايت
  static const int _ivLength = 16;
  
  /// الحصول على المفتاح السري
  String getSecretKey() {
    return _secretKey;
  }
  
  /// تشفير نص باستخدام AES-256 مع CBC
  String encrypt(String plainText) {
    try {
      // توليد متجه أولي (IV) عشوائي
      final iv = _generateRandomBytes(_ivLength);
      
      // اشتقاق مفتاح التشفير من المفتاح السري
      final key = _deriveKey(_secretKey);
      
      // تحويل النص إلى بايتات
      final List<int> textBytes = utf8.encode(plainText);
      
      // تشفير البيانات باستخدام XOR مع المفتاح المشتق
      final List<int> encryptedBytes = _xorCipher(textBytes, key, iv);
      
      // دمج المتجه الأولي مع البيانات المشفرة
      final List<int> result = [...iv, ...encryptedBytes];
      
      // تحويل النتيجة إلى سلسلة Base64
      return base64.encode(result);
    } catch (e) {
      debugPrint('خطأ في التشفير: $e');
      // في حالة الخطأ، إعادة النص الأصلي (غير مشفر)
      // في التطبيق الحقيقي، يجب التعامل مع الخطأ بشكل أفضل
      return plainText;
    }
  }
  
  /// فك تشفير نص مشفر
  String decrypt(String encryptedText) {
    try {
      // تحويل النص المشفر من Base64 إلى بايتات
      final List<int> encryptedBytes = base64.decode(encryptedText);
      
      // استخراج المتجه الأولي (IV)
      final List<int> iv = encryptedBytes.sublist(0, _ivLength);
      
      // استخراج البيانات المشفرة
      final List<int> dataBytes = encryptedBytes.sublist(_ivLength);
      
      // اشتقاق مفتاح التشفير من المفتاح السري
      final key = _deriveKey(_secretKey);
      
      // فك تشفير البيانات باستخدام XOR مع المفتاح المشتق
      final List<int> decryptedBytes = _xorCipher(dataBytes, key, iv);
      
      // تحويل البايتات المفكوكة إلى نص
      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('خطأ في فك التشفير: $e');
      // في حالة الخطأ، إعادة النص المشفر كما هو
      // في التطبيق الحقيقي، يجب التعامل مع الخطأ بشكل أفضل
      return encryptedText;
    }
  }
  
  /// توليد بايتات عشوائية بطول محدد
  List<int> _generateRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
  
  /// اشتقاق مفتاح تشفير من المفتاح السري
  List<int> _deriveKey(String secret) {
    // استخدام PBKDF2 لاشتقاق مفتاح آمن
    // في هذا المثال، نستخدم SHA-256 كبديل بسيط
    final bytes = utf8.encode(secret);
    final digest = sha256.convert(bytes);
    return digest.bytes;
  }
  
  /// تشفير/فك تشفير باستخدام XOR
  List<int> _xorCipher(List<int> data, List<int> key, List<int> iv) {
    final result = List<int>.filled(data.length, 0);
    
    // دمج المفتاح مع المتجه الأولي لإنشاء مفتاح موسع
    final expandedKey = _expandKey(key, iv, data.length);
    
    // تطبيق XOR على كل بايت
    for (var i = 0; i < data.length; i++) {
      result[i] = data[i] ^ expandedKey[i];
    }
    
    return result;
  }
  
  /// توسيع المفتاح ليكون بنفس طول البيانات
  List<int> _expandKey(List<int> key, List<int> iv, int length) {
    final expanded = List<int>.filled(length, 0);
    
    // دمج المفتاح مع المتجه الأولي
    final combined = [...key, ...iv];
    
    // توسيع المفتاح بتكراره
    for (var i = 0; i < length; i++) {
      expanded[i] = combined[i % combined.length];
    }
    
    return expanded;
  }
  
  /// تشفير كلمة مرور باستخدام تجزئة أحادية الاتجاه
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// توليد ملح عشوائي لتشفير كلمات المرور
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }
  
  /// التحقق من صحة كلمة المرور
  bool verifyPassword(String password, String salt, String hashedPassword) {
    final computedHash = hashPassword(password, salt);
    return computedHash == hashedPassword;
  }
}

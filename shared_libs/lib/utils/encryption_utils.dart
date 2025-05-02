import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// أدوات التشفير وفك التشفير
///
/// توفر هذه الفئة وظائف للتشفير وفك التشفير وتجزئة البيانات
/// لحماية المعلومات الحساسة في التطبيق

class EncryptionUtils {
  // مفتاح التشفير الافتراضي (يجب تغييره في بيئة الإنتاج)
  static final _defaultKey = encrypt.Key.fromUtf8('RivooSecureEncryptionKey32Bytes!!');
  
  // متجه التهيئة الافتراضي (يجب تغييره في بيئة الإنتاج)
  static final _defaultIv = encrypt.IV.fromLength(16);
  
  // منع إنشاء نسخة من الفئة
  EncryptionUtils._();
  
  /// تشفير نص باستخدام خوارزمية AES
  ///
  /// يستخدم خوارزمية AES-256 في وضع CBC مع حشو PKCS7
  static String encrypt(String text, {
    encrypt.Key? key,
    encrypt.IV? iv,
  }) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key ?? _defaultKey, mode: encrypt.AESMode.cbc),
    );
    
    final encrypted = encrypter.encrypt(text, iv: iv ?? _defaultIv);
    return encrypted.base64;
  }
  
  /// فك تشفير نص مشفر باستخدام خوارزمية AES
  ///
  /// يستخدم نفس المفتاح ومتجه التهيئة المستخدم في التشفير
  static String decrypt(String encryptedText, {
    encrypt.Key? key,
    encrypt.IV? iv,
  }) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key ?? _defaultKey, mode: encrypt.AESMode.cbc),
    );
    
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv ?? _defaultIv);
  }
  
  /// إنشاء تجزئة SHA-256 للنص
  ///
  /// مفيد لتخزين كلمات المرور بشكل آمن
  static String hashSHA256(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// إنشاء تجزئة SHA-512 للنص
  ///
  /// يوفر مستوى أعلى من الأمان لكلمات المرور والبيانات الحساسة
  static String hashSHA512(String text) {
    final bytes = utf8.encode(text);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }
  
  /// إنشاء تجزئة MD5 للنص
  ///
  /// ملاحظة: MD5 ليس آمنًا للاستخدام في تطبيقات الأمان، ويستخدم فقط للتحقق من سلامة البيانات
  static String hashMD5(String text) {
    final bytes = utf8.encode(text);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  /// إنشاء مفتاح تشفير من كلمة مرور
  ///
  /// يستخدم تجزئة SHA-256 لإنشاء مفتاح 32 بايت من كلمة المرور
  static encrypt.Key keyFromPassword(String password) {
    final hash = hashSHA256(password);
    return encrypt.Key.fromUtf8(hash.substring(0, 32));
  }
  
  /// إنشاء متجه تهيئة من نص
  ///
  /// يستخدم تجزئة MD5 لإنشاء متجه تهيئة 16 بايت من النص
  static encrypt.IV ivFromText(String text) {
    final hash = hashMD5(text);
    return encrypt.IV.fromUtf8(hash.substring(0, 16));
  }
  
  /// تشفير كائن JSON
  ///
  /// يحول الكائن إلى سلسلة JSON ثم يشفرها
  static String encryptJson(Map<String, dynamic> json, {
    encrypt.Key? key,
    encrypt.IV? iv,
  }) {
    final jsonString = jsonEncode(json);
    return encrypt(jsonString, key: key, iv: iv);
  }
  
  /// فك تشفير كائن JSON
  ///
  /// يفك تشفير النص ثم يحلله كـ JSON
  static Map<String, dynamic> decryptJson(String encryptedText, {
    encrypt.Key? key,
    encrypt.IV? iv,
  }) {
    final jsonString = decrypt(encryptedText, key: key, iv: iv);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  
  /// إنشاء رمز عشوائي آمن
  ///
  /// مفيد لإنشاء رموز التحقق ورموز إعادة تعيين كلمة المرور
  static String generateSecureToken(int length) {
    final random = encrypt.SecureRandom(length);
    return base64Url.encode(random.bytes).substring(0, length);
  }
}


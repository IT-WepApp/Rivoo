import 'package:crypto/crypto.dart';
import 'dart:convert';

/// أداة التشفير (مثال باستخدام SHA-256)
class EncryptionUtils {
  /// تشفير النص باستخدام SHA-256
  String encrypt(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // يمكن إضافة طرق تشفير أخرى هنا إذا لزم الأمر
}


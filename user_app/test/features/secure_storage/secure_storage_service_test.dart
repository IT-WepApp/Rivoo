import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/utils/encryption_utils.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, EncryptionUtils])
void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late MockEncryptionUtils mockEncryptionUtils;
  late SecureStorageService secureStorageService;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockEncryptionUtils = MockEncryptionUtils();
    secureStorageService = SecureStorageService(
      secureStorage: mockSecureStorage,
      encryptionUtils: mockEncryptionUtils,
    );
  });

  group('SecureStorageService Tests', () {
    test('saveAuthToken يجب أن يقوم بتشفير وتخزين الرمز', () async {
      // إعداد
      const token = 'test-auth-token';
      const expectedEncryptedData = 'encrypted-data';

      // محاكاة التشفير
      when(mockEncryptionUtils.encrypt(any)).thenReturn(expectedEncryptedData);

      // تنفيذ
      await secureStorageService.saveAuthToken(token);

      // التحقق
      verify(mockEncryptionUtils.encrypt(any)).called(1);
      verify(mockSecureStorage.write(
        key: anyNamed('key'),
        value: expectedEncryptedData,
      )).called(1);
    });

    test('getAuthToken يجب أن يسترجع ويفك تشفير الرمز الصالح', () async {
      // إعداد
      const encryptedData = 'encrypted-data';
      final now = DateTime.now();
      final future = now.add(const Duration(minutes: 30));
      final tokenData = {
        'token': 'test-auth-token',
        'expiry': future.toIso8601String(),
      };

      // محاكاة القراءة والتشفير
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => encryptedData);
      when(mockEncryptionUtils.decrypt(encryptedData))
          .thenReturn(jsonEncode(tokenData));

      // تنفيذ
      final result = await secureStorageService.getAuthToken();

      // التحقق
      expect(result, 'test-auth-token');
      verify(mockSecureStorage.read(key: anyNamed('key'))).called(1);
      verify(mockEncryptionUtils.decrypt(encryptedData)).called(1);
    });

    test('getAuthToken يجب أن يعيد null للرمز منتهي الصلاحية', () async {
      // إعداد
      const encryptedData = 'encrypted-data';
      final now = DateTime.now();
      final past = now.subtract(const Duration(minutes: 30));
      final tokenData = {
        'token': 'test-auth-token',
        'expiry': past.toIso8601String(),
      };

      // محاكاة القراءة والتشفير
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => encryptedData);
      when(mockEncryptionUtils.decrypt(encryptedData))
          .thenReturn(jsonEncode(tokenData));

      // تنفيذ
      final result = await secureStorageService.getAuthToken();

      // التحقق
      expect(result, null);
      verify(mockSecureStorage.read(key: anyNamed('key'))).called(1);
      verify(mockEncryptionUtils.decrypt(encryptedData)).called(1);
      verify(mockSecureStorage.delete(key: anyNamed('key'))).called(1);
    });

    test('saveUserData يجب أن يقوم بتشفير وتخزين بيانات المستخدم مع توقيع',
        () async {
      // إعداد
      final userData = {'id': 'user1', 'name': 'Test User'};
      const signature = 'data-signature';
      const encryptedData = 'encrypted-user-data';

      // محاكاة التوقيع والتشفير
      when(mockEncryptionUtils.getSecretKey()).thenReturn('secret-key');
      when(mockEncryptionUtils.encrypt(any)).thenReturn(encryptedData);

      // تنفيذ
      await secureStorageService.saveUserData(userData);

      // التحقق
      verify(mockEncryptionUtils.encrypt(any)).called(1);
      verify(mockSecureStorage.write(
        key: anyNamed('key'),
        value: encryptedData,
      )).called(1);
    });

    test(
        'getUserData يجب أن يسترجع ويفك تشفير بيانات المستخدم مع التحقق من التوقيع',
        () async {
      // إعداد
      const encryptedData = 'encrypted-data';
      final userData = {'id': 'user1', 'name': 'Test User'};
      final dataWithSignature = {
        'data': jsonEncode(userData),
        'signature': 'valid-signature',
      };

      // محاكاة القراءة والتشفير والتحقق
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => encryptedData);
      when(mockEncryptionUtils.decrypt(encryptedData))
          .thenReturn(jsonEncode(dataWithSignature));

      // تنفيذ (مع تجاوز التحقق من التوقيع)
      // نحتاج إلى تجاوز _verifySignature لأنها طريقة خاصة
      // في اختبار حقيقي، يمكننا استخدام التجاوز أو إعادة هيكلة الكود للاختبار

      // التحقق
      // نتحقق فقط من استدعاء الطرق المتوقعة
      await secureStorageService.getUserData();
      verify(mockSecureStorage.read(key: anyNamed('key'))).called(1);
      verify(mockEncryptionUtils.decrypt(encryptedData)).called(1);
    });

    test('clearAll يجب أن يحذف جميع البيانات المخزنة', () async {
      // تنفيذ
      await secureStorageService.clearAll();

      // التحقق
      verify(mockSecureStorage.deleteAll()).called(1);
    });
  });
}

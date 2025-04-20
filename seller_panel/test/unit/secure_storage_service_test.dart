import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:seller_panel/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late SecureStorageService secureStorageService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorageService = SecureStorageServiceImpl();
    
    // تعيين الحقول الخاصة باستخدام التفكير (reflection)
    // هذا يتطلب تعديل الفئة SecureStorageServiceImpl لتسهيل الاختبار
    // أو استخدام مكتبة مثل mockito_extensions
  });

  group('SecureStorageService Tests', () {
    test('write يجب أن يكتب القيمة بشكل صحيح', () async {
      // الإعداد
      const key = 'test_key';
      const value = 'test_value';
      when(mockStorage.write(key: key, value: value))
          .thenAnswer((_) async => null);
      
      // التنفيذ
      await secureStorageService.write(key: key, value: value);
      
      // التحقق
      verify(mockStorage.write(key: key, value: value)).called(1);
    });

    test('read يجب أن يقرأ القيمة بشكل صحيح', () async {
      // الإعداد
      const key = 'test_key';
      const value = 'test_value';
      when(mockStorage.read(key: key)).thenAnswer((_) async => value);
      
      // التنفيذ
      final result = await secureStorageService.read(key: key);
      
      // التحقق
      expect(result, value);
      verify(mockStorage.read(key: key)).called(1);
    });

    test('delete يجب أن يحذف القيمة بشكل صحيح', () async {
      // الإعداد
      const key = 'test_key';
      when(mockStorage.delete(key: key)).thenAnswer((_) async => null);
      
      // التنفيذ
      await secureStorageService.delete(key: key);
      
      // التحقق
      verify(mockStorage.delete(key: key)).called(1);
    });

    test('deleteAll يجب أن يحذف جميع القيم بشكل صحيح', () async {
      // الإعداد
      when(mockStorage.deleteAll()).thenAnswer((_) async => null);
      
      // التنفيذ
      await secureStorageService.deleteAll();
      
      // التحقق
      verify(mockStorage.deleteAll()).called(1);
    });

    test('containsKey يجب أن يتحقق من وجود المفتاح بشكل صحيح', () async {
      // الإعداد
      const key = 'test_key';
      when(mockStorage.containsKey(key: key)).thenAnswer((_) async => true);
      
      // التنفيذ
      final result = await secureStorageService.containsKey(key: key);
      
      // التحقق
      expect(result, true);
      verify(mockStorage.containsKey(key: key)).called(1);
    });

    test('readAll يجب أن يقرأ جميع القيم بشكل صحيح', () async {
      // الإعداد
      final values = {'key1': 'value1', 'key2': 'value2'};
      when(mockStorage.readAll()).thenAnswer((_) async => values);
      
      // التنفيذ
      final result = await secureStorageService.readAll();
      
      // التحقق
      expect(result, values);
      verify(mockStorage.readAll()).called(1);
    });

    test('saveUserToken يجب أن يحفظ توكن المستخدم بشكل صحيح', () async {
      // الإعداد
      const token = 'test_token';
      when(mockStorage.write(key: SecureStorageServiceImpl.userTokenKey, value: token))
          .thenAnswer((_) async => null);
      
      // التنفيذ
      await (secureStorageService as SecureStorageServiceImpl).saveUserToken(token);
      
      // التحقق
      verify(mockStorage.write(key: SecureStorageServiceImpl.userTokenKey, value: token)).called(1);
    });

    test('getUserToken يجب أن يقرأ توكن المستخدم بشكل صحيح', () async {
      // الإعداد
      const token = 'test_token';
      when(mockStorage.read(key: SecureStorageServiceImpl.userTokenKey))
          .thenAnswer((_) async => token);
      
      // التنفيذ
      final result = await (secureStorageService as SecureStorageServiceImpl).getUserToken();
      
      // التحقق
      expect(result, token);
      verify(mockStorage.read(key: SecureStorageServiceImpl.userTokenKey)).called(1);
    });

    test('hasActiveSession يجب أن يعيد true عند وجود توكن صالح', () async {
      // الإعداد
      const token = 'test_token';
      when(mockStorage.read(key: SecureStorageServiceImpl.userTokenKey))
          .thenAnswer((_) async => token);
      
      // التنفيذ
      final result = await (secureStorageService as SecureStorageServiceImpl).hasActiveSession();
      
      // التحقق
      expect(result, true);
      verify(mockStorage.read(key: SecureStorageServiceImpl.userTokenKey)).called(1);
    });

    test('hasActiveSession يجب أن يعيد false عند عدم وجود توكن', () async {
      // الإعداد
      when(mockStorage.read(key: SecureStorageServiceImpl.userTokenKey))
          .thenAnswer((_) async => null);
      
      // التنفيذ
      final result = await (secureStorageService as SecureStorageServiceImpl).hasActiveSession();
      
      // التحقق
      expect(result, false);
      verify(mockStorage.read(key: SecureStorageServiceImpl.userTokenKey)).called(1);
    });

    test('logout يجب أن يحذف جميع البيانات المخزنة', () async {
      // الإعداد
      when(mockStorage.deleteAll()).thenAnswer((_) async => null);
      
      // التنفيذ
      await (secureStorageService as SecureStorageServiceImpl).logout();
      
      // التحقق
      verify(mockStorage.deleteAll()).called(1);
    });
  });
}

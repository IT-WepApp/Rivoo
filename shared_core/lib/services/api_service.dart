import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة واجهة برمجة التطبيقات (API) المسؤولة عن التعامل مع طلبات الشبكة
/// تستخدم مكتبة Dio للاتصال بالخادم وإدارة الطلبات
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.rivoo.com/v1';
  
  /// تهيئة خدمة الـ API مع الإعدادات الافتراضية
  Future<void> init() async {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // إضافة معترض للطلبات لإضافة رمز المصادقة
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        if (kDebugMode) {
          print('خطأ في طلب API: ${error.message}');
        }
        return handler.next(error);
      },
    ));
  }

  /// إرسال طلب GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// إرسال طلب POST
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// إرسال طلب PUT
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// إرسال طلب DELETE
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// تحميل ملف إلى الخادم
  Future<Response> uploadFile(String path, String filePath, {Map<String, dynamic>? data}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });
      return await _dio.post(path, data: formData);
    } catch (e) {
      rethrow;
    }
  }
}

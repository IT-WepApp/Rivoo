import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:shared_libs/models/user_model.dart';


/// مصدر البيانات البعيد للمصادقة
class AuthRemoteDataSource {
  final http.Client _client;
  final ApiConfig _apiConfig;

  AuthRemoteDataSource(this._client, this._apiConfig);

  /// تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${_apiConfig.baseUrl}/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw ServerException(
        message: errorBody['message'] ?? 'فشل تسجيل الدخول',
        code: response.statusCode.toString(),
      );
    }
  }

  /// تسجيل الخروج
  Future<void> logout(String token) async {
    final response = await _client.post(
      Uri.parse('${_apiConfig.baseUrl}/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw ServerException(
        message: errorBody['message'] ?? 'فشل تسجيل الخروج',
        code: response.statusCode.toString(),
      );
    }
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<UserModel> getCurrentUser(String token) async {
    final response = await _client.get(
      Uri.parse('${_apiConfig.baseUrl}/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw ServerException(
        message: errorBody['message'] ?? 'فشل الحصول على بيانات المستخدم',
        code: response.statusCode.toString(),
      );
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.post(
      Uri.parse('${_apiConfig.baseUrl}/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw ServerException(
        message: errorBody['message'] ?? 'فشل تغيير كلمة المرور',
        code: response.statusCode.toString(),
      );
    }
  }
}

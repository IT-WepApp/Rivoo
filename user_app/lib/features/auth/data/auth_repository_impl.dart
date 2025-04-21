import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../package/google_sign_in/google_sign_in.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
import 'datasources/auth_local_datasource.dart';
import 'datasources/auth_remote_datasource.dart';

/// تنفيذ مستودع المصادقة
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;
  final GoogleSignIn _googleSignIn;

  /// إنشاء نسخة جديدة من تنفيذ مستودع المصادقة
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
    GoogleSignIn? googleSignIn,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // التحقق من صحة البريد الإلكتروني وكلمة المرور
      if (email.isEmpty || password.isEmpty) {
        return Either.left(AuthFailure('البريد الإلكتروني وكلمة المرور مطلوبان'));
      }

      // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
      final user = await _remoteDatasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // حفظ بيانات المستخدم
      await _localDatasource.saveUserData(user);

      return Either.right(user);
    } catch (e) {
      return Either.left(_mapException(e));
    } on Exception catch (e) {
      return Either.left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // التحقق من صحة البريد الإلكتروني وكلمة المرور والاسم
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return Either.left(ValidationFailure('جميع الحقول مطلوبة'));
      }

      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(password)) {
        return Either.left(ValidationFailure('كلمة المرور ضعيفة جدًا. يجب أن تحتوي على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا.'));
      }

      // إنشاء حساب جديد
      final user = await _remoteDatasource.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      // حفظ بيانات المستخدم
      await _localDatasource.saveUserData(user);

      return Either.right(user);
    } catch (e) {
      return Either.left(_mapException(e));
    } on Exception catch (e) {
      return Either.left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // الحصول على رمز المصادقة
      final token = await _localDatasource.getAuthToken();

      // تسجيل الخروج من الخادم
      if (token != null) {
        await _remoteDatasource.signOut(token);
      }

      // حذف رمز المصادقة وبيانات المستخدم
      await _localDatasource.deleteAuthToken();
      await _localDatasource.deleteUserData();

      // تسجيل الخروج من حساب جوجل إذا كان مستخدمًا
      await _googleSignIn.signOut();

      return Either.right(null);
    } catch (e) {
      return Either.left(_mapException(e));
    } on Exception catch (e) {
      return Either.left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      // تنفيذ تسجيل الدخول باستخدام حساب جوجل
      return Either.left(UnexpectedFailure('لم يتم تنفيذ هذه الميزة بعد'));
    } catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      // تنفيذ إعادة تعيين كلمة المرور
      await _remoteDatasource.resetPassword(email);
      return Either.right(null);
    } catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) async {
    try {
      // تنفيذ التحقق من صحة الرمز
      final isValid = await _remoteDatasource.validateToken(token);
      return Either.right(isValid);
    } catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      // تنفيذ تحديث بيانات المستخدم
      final user = await _remoteDatasource.updateUserProfile(
        userId: userId,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      
      // حفظ بيانات المستخدم المحدثة
      await _localDatasource.saveUserData(user);
      
      return Either.right(user);
    } catch (e) {
      return Either.left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // التحقق من قوة كلمة المرور الجديدة
      if (!_isStrongPassword(newPassword)) {
        return Either.left(ValidationFailure('كلمة المرور ضعيفة جدًا. يجب أن تحتوي على 8 أحرف على الأقل وتتضمن أحرفًا كبيرة وصغيرة وأرقامًا ورموزًا.'));
      }
      
      // تنفيذ تغيير كلمة المرور
      await _remoteDatasource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      return Either.right(null);
    } catch (e) {
      return Either.left(_mapException(e));
    }
  }
}

/// دالة مساعدة للتحقق من قوة كلمة المرور
bool _isStrongPassword(String password) {
  // كلمة المرور يجب أن تكون 8 أحرف على الأقل
  if (password.length < 8) {
    return false;
  }

  // كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return false;
  }

  // كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل
  if (!password.contains(RegExp(r'[a-z]'))) {
    return false;
  }

  // كلمة المرور يجب أن تحتوي على رقم واحد على الأقل
  if (!password.contains(RegExp(r'[0-9]'))) {
    return false;
  }

  // كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return false;
  }

  return true;
}

/// دالة مساعدة لتحويل الاستثناءات إلى أخطاء
Failure _mapException(dynamic exception) {
  if (exception is http.ClientException) {
    return AuthFailure('خطأ في الاتصال بالخادم: ${exception.message}');
  } else if (exception is TimeoutException) {
    return AuthFailure('انتهت مهلة الاتصال بالخادم');
  } else if (exception is FormatException) {
    return AuthFailure('خطأ في تنسيق البيانات: ${exception.message}');
  } else if (exception is GoogleSignInException) {
    return AuthFailure('خطأ في تسجيل الدخول بحساب جوجل: ${exception.message}');
  } else {
    return UnexpectedFailure(exception.toString());
  }
}

/// استثناء تسجيل الدخول بحساب جوجل
class GoogleSignInException implements Exception {
  final String message;
  
  GoogleSignInException(this.message);
  
  @override
  String toString() => 'GoogleSignInException: $message';
}

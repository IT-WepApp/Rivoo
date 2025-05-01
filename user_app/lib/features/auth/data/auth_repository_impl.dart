import 'dart:convert';

import 'package:user_app/core/architecture/domain/either.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:user_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shared_libs/entities/user_entity.dart';
import 'package:user_app/features/auth/domain/repositories/auth_repository.dart';

/// تنفيذ مستودع المصادقة
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  /// إنشاء مستودع المصادقة
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDatasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _localDatasource.saveUserData(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('فشل تسجيل الدخول: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await _remoteDatasource.signInWithGoogle();
      await _localDatasource.saveUserData(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('فشل تسجيل الدخول باستخدام Google: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _remoteDatasource.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      await _localDatasource.saveUserData(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('فشل إنشاء الحساب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await _localDatasource.getAuthToken();
      if (token == null) {
        return const Right(false);
      }
      return const Right(true);
    } catch (e) {
      return Left(AuthFailure('فشل التحقق من حالة المصادقة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDatasource.signOut();
      await _localDatasource.deleteAuthToken();
      await _localDatasource.deleteUserData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('فشل تسجيل الخروج: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _localDatasource.getStoredUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('فشل الحصول على المستخدم الحالي: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken() async {
    try {
      final token = await _localDatasource.getAuthToken();
      if (token == null) {
        return const Right(false);
      }
      final isValid = await _remoteDatasource.validateToken(token);
      return Right(isValid);
    } catch (e) {
      return Left(AuthFailure('فشل التحقق من صلاحية الرمز: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    try {
      final user = await _remoteDatasource.updateUserProfile(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        address: address,
        photoUrl: photoUrl,
      );
      await _localDatasource.saveUserData(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('فشل تحديث الملف الشخصي: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDatasource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('فشل تغيير كلمة المرور: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _remoteDatasource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('فشل إعادة تعيين كلمة المرور: ${e.toString()}'));
    }
  }
}

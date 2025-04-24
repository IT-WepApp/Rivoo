// تنفيذ مستودع المصادقة (Repository Implementation) في طبقة Data
// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:shared_libs/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../../core/services/crashlytics_manager.dart';
import '../models/user_model.dart';

/// تنفيذ مستودع المصادقة
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final CrashlyticsManager crashlytics;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.crashlytics,
  });

  @override
  Future<UserEntity> signIn({required String email, required String password}) async {
    try {
      final json = await remoteDataSource.login(email: email, password: password);
      final userModel = UserModel.fromJson(json);
      await localDataSource.cacheUser(userModel);

      // تعيين معرف المستخدم في Crashlytics لتسهيل تتبع الأخطاء
      await crashlytics.setUserIdentifier(userId: userModel.id);

      return userModel;
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await crashlytics.recordError(e, stack);
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final token = await localDataSource.getAccessToken();
      await remoteDataSource.logout(token!);
      await localDataSource.clearUser();
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await crashlytics.recordError(e, stack);
      throw Exception('فشل تسجيل الخروج: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // محاولة الحصول على المستخدم من المصدر البعيد أولاً
      final token = await localDataSource.getAccessToken();
      final remoteUser = await remoteDataSource.getCurrentUser(token!);

      await localDataSource.cacheUser(remoteUser);

      // تعيين معرف المستخدم في Crashlytics
      await crashlytics.setUserIdentifier(userId: remoteUser.id);

      return remoteUser;
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await crashlytics.recordError(e, stack);

      // إذا لم يكن هناك مستخدم حالي، نحاول الحصول على آخر مستخدم مخزن محلياً
      final localUser = await localDataSource.getLastSignedInUser();

      if (localUser != null) {
        // تعيين معرف المستخدم في Crashlytics
        await crashlytics.setUserIdentifier(userId: localUser.id);
      }

      return localUser;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final currentUser = await getCurrentUser();
      return currentUser != null;
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await crashlytics.recordError(e, stack);
      return false;
    }
  }
}
// تنفيذ مستودع المصادقة (Repository Implementation) في طبقة Data
// lib/features/auth/data/repositories/auth_repository_impl.dart

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../../core/services/crashlytics_manager.dart';

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
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signIn(email, password);
      await localDataSource.cacheUser(userModel);

      // تعيين معرف المستخدم في Crashlytics لتسهيل تتبع الأخطاء
      await crashlytics.setUserIdentifier(userModel.id);

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
      await remoteDataSource.signOut();
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
      final remoteUser = await remoteDataSource.getCurrentUser();

      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);

        // تعيين معرف المستخدم في Crashlytics
        await crashlytics.setUserIdentifier(remoteUser.id);

        return remoteUser;
      }

      // إذا لم يكن هناك مستخدم حالي، نحاول الحصول على آخر مستخدم مخزن محلياً
      final localUser = await localDataSource.getLastSignedInUser();

      if (localUser != null) {
        // تعيين معرف المستخدم في Crashlytics
        await crashlytics.setUserIdentifier(localUser.id);
      }

      return localUser;
    } catch (e, stack) {
      // تسجيل الخطأ في Crashlytics
      await crashlytics.recordError(e, stack);
      return null;
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

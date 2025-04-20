import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:admin_panell/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:admin_panell/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:admin_panell/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:admin_panell/features/auth/domain/entities/user_entity.dart';
import 'package:admin_panell/features/auth/data/models/user_model.dart';
import 'package:admin_panell/core/services/crashlytics_manager.dart';

// توليد الملفات المطلوبة لـ Mockito
@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource, CrashlyticsManager])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockCrashlyticsManager mockCrashlyticsManager;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockCrashlyticsManager = MockCrashlyticsManager();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      crashlytics: mockCrashlyticsManager,
    );
  });

  final testEmail = 'test@example.com';
  final testPassword = 'password123';
  final testUserModel = UserModel(
    id: '1',
    name: 'Test User',
    email: testEmail,
    role: 'admin',
  );

  group('signIn', () {
    test('يجب أن يعيد UserEntity عند نجاح تسجيل الدخول', () async {
      // ترتيب
      when(mockRemoteDataSource.signIn(testEmail, testPassword))
          .thenAnswer((_) async => testUserModel);

      // تنفيذ
      final result = await repository.signIn(testEmail, testPassword);

      // تحقق
      expect(result, equals(testUserModel));
      verify(mockRemoteDataSource.signIn(testEmail, testPassword)).called(1);
      verify(mockLocalDataSource.cacheUser(testUserModel)).called(1);
      verify(mockCrashlyticsManager.setUserIdentifier(testUserModel.id)).called(1);
    });

    test('يجب أن يرمي استثناء عند فشل تسجيل الدخول', () async {
      // ترتيب
      final testException = Exception('فشل تسجيل الدخول');
      when(mockRemoteDataSource.signIn(testEmail, testPassword))
          .thenThrow(testException);

      // تنفيذ وتحقق
      expect(
        () => repository.signIn(testEmail, testPassword),
        throwsA(isA<Exception>()),
      );
      verify(mockRemoteDataSource.signIn(testEmail, testPassword)).called(1);
      verify(mockCrashlyticsManager.recordError(any, any)).called(1);
    });
  });

  group('getCurrentUser', () {
    test('يجب أن يعيد المستخدم من المصدر البعيد إذا كان متاحاً', () async {
      // ترتيب
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => testUserModel);

      // تنفيذ
      final result = await repository.getCurrentUser();

      // تحقق
      expect(result, equals(testUserModel));
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.cacheUser(testUserModel)).called(1);
      verify(mockCrashlyticsManager.setUserIdentifier(testUserModel.id)).called(1);
    });

    test('يجب أن يعيد المستخدم من المصدر المحلي إذا لم يكن متاحاً من المصدر البعيد', () async {
      // ترتيب
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => null);
      when(mockLocalDataSource.getLastSignedInUser())
          .thenAnswer((_) async => testUserModel);

      // تنفيذ
      final result = await repository.getCurrentUser();

      // تحقق
      expect(result, equals(testUserModel));
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.getLastSignedInUser()).called(1);
      verify(mockCrashlyticsManager.setUserIdentifier(testUserModel.id)).called(1);
    });

    test('يجب أن يعيد null إذا لم يكن هناك مستخدم متاح', () async {
      // ترتيب
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => null);
      when(mockLocalDataSource.getLastSignedInUser())
          .thenAnswer((_) async => null);

      // تنفيذ
      final result = await repository.getCurrentUser();

      // تحقق
      expect(result, isNull);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.getLastSignedInUser()).called(1);
    });
  });
}

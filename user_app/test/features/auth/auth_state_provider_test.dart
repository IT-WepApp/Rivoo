import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:riverpod/riverpod.dart';
import 'package:user_app/core/state/auth_state_provider.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

import 'auth_state_provider_test.mocks.dart';

// إنشاء نماذج وهمية للاختبار
@GenerateMocks([FirebaseAuth, User, AuthService])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockAuthService mockAuthService;
  late ProviderContainer container;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockAuthService = MockAuthService();

    // إعداد حاوية المزودات للاختبار
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );

    // تنظيف بعد كل اختبار
    addTearDown(container.dispose);
  });

  group('AuthStateNotifier Tests', () {
    test('يجب أن تكون الحالة الأولية هي initial', () {
      final authState = container.read(authStateNotifierProvider);
      expect(authState, const AuthState.initial());
    });

    test('يجب أن تتغير الحالة إلى unauthenticated عندما يكون المستخدم null', () async {
      // محاكاة تغير حالة المصادقة مع مستخدم فارغ
      final controller = StreamController<User?>();
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => controller.stream);
      
      // إعادة إنشاء المزود مع المحاكاة الجديدة
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          // تجاوز مزود FirebaseAuth
        ],
      );
      
      // إرسال قيمة null في تدفق حالة المصادقة
      controller.add(null);
      
      // الانتظار لتحديث الحالة
      await Future.delayed(Duration.zero);
      
      // التحقق من الحالة الجديدة
      final authState = container.read(authStateNotifierProvider);
      expect(authState, const AuthState.unauthenticated());
      
      // تنظيف
      await controller.close();
    });

    test('يجب أن تتغير الحالة إلى authenticated عند تسجيل الدخول بنجاح', () async {
      // إعداد نموذج المستخدم المتوقع
      final userModel = UserModel(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        role: 'customer',
      );
      
      // محاكاة تسجيل الدخول الناجح
      when(mockAuthService.signInWithEmailAndPassword(
        'test@example.com', 
        'password123'
      )).thenAnswer((_) async {});
      
      // محاكاة الحصول على بيانات المستخدم
      when(mockAuthService.getUserData('test-user-id'))
          .thenAnswer((_) async => userModel);
      
      // محاكاة تغير حالة المصادقة
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test-user-id');
      
      final controller = StreamController<User?>();
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => controller.stream);
      
      // إعادة إنشاء المزود مع المحاكاة الجديدة
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          // تجاوز مزود FirebaseAuth
        ],
      );
      
      // تنفيذ تسجيل الدخول
      await container.read(authStateNotifierProvider.notifier)
          .signInWithEmailAndPassword('test@example.com', 'password123');
      
      // إرسال حالة المستخدم المسجل
      controller.add(mockUser);
      
      // الانتظار لتحديث الحالة
      await Future.delayed(Duration.zero);
      
      // التحقق من الحالة النهائية
      final authState = container.read(authStateNotifierProvider);
      expect(
        authState,
        AuthState.authenticated(userModel),
      );
      
      // تنظيف
      await controller.close();
    });

    test('يجب أن تتغير الحالة إلى error عند فشل تسجيل الدخول', () async {
      // محاكاة فشل تسجيل الدخول
      when(mockAuthService.signInWithEmailAndPassword(
        'test@example.com', 
        'wrong_password'
      )).thenThrow(Exception('Invalid credentials'));
      
      // تنفيذ تسجيل الدخول مع بيانات خاطئة
      await container.read(authStateNotifierProvider.notifier)
          .signInWithEmailAndPassword('test@example.com', 'wrong_password');
      
      // التحقق من الحالة النهائية
      final authState = container.read(authStateNotifierProvider);
      expect(
        authState,
        predicate<AuthState>((state) => 
          state.toString().contains('AuthState.error') &&
          state.toString().contains('Invalid credentials')
        ),
      );
    });
  });

  group('Auth Providers Tests', () {
    test('isAuthenticated يجب أن يعيد true عندما يكون المستخدم مصادقًا', () {
      // تعيين حالة المصادقة إلى authenticated
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(
            (ref) => AuthStateNotifier()..state = AuthState.authenticated(
              UserModel(
                id: 'test-id',
                name: 'Test User',
                email: 'test@example.com',
                role: 'customer',
              ),
            ),
          ),
        ],
      );
      
      // التحقق من قيمة isAuthenticated
      final isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, true);
    });

    test('isAuthenticated يجب أن يعيد false عندما لا يكون المستخدم مصادقًا', () {
      // تعيين حالة المصادقة إلى unauthenticated
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(
            (ref) => AuthStateNotifier()..state = const AuthState.unauthenticated(),
          ),
        ],
      );
      
      // التحقق من قيمة isAuthenticated
      final isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, false);
    });

    test('currentUser يجب أن يعيد نموذج المستخدم عندما يكون مصادقًا', () {
      // إعداد نموذج المستخدم المتوقع
      final userModel = UserModel(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        role: 'customer',
      );
      
      // تعيين حالة المصادقة إلى authenticated
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(
            (ref) => AuthStateNotifier()..state = AuthState.authenticated(userModel),
          ),
        ],
      );
      
      // التحقق من قيمة currentUser
      final currentUser = container.read(currentUserProvider);
      expect(currentUser, userModel);
    });

    test('userRole يجب أن يعيد دور المستخدم عندما يكون مصادقًا', () {
      // إعداد نموذج المستخدم المتوقع
      final userModel = UserModel(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        role: 'admin',
      );
      
      // تعيين حالة المصادقة إلى authenticated
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(
            (ref) => AuthStateNotifier()..state = AuthState.authenticated(userModel),
          ),
        ],
      );
      
      // التحقق من قيمة userRole
      final userRole = container.read(userRoleProvider);
      expect(userRole, 'admin');
    });
  });
}

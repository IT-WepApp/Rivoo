import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/auth/application/auth_notifier.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:user_app/core/auth/auth_guard.dart';
import 'package:go_router/go_router.dart';

@GenerateMocks([
  AuthService,
  GoRouter,
])
void main() {
  late MockAuthService mockAuthService;
  late AuthGuard authGuard;

  setUp(() {
    mockAuthService = MockAuthService();
    authGuard = AuthGuard(mockAuthService);
  });

  group('AuthGuard Tests', () {
    test(
        'canActivate should return true for authenticated user with correct role',
        () async {
      // ترتيب
      when(mockAuthService.currentUser).thenReturn(MockUser());
      when(mockAuthService.getUserRole(any))
          .thenAnswer((_) async => UserRole.admin);

      // تنفيذ
      final result = await authGuard.canActivate(
        requiredRoles: [UserRole.admin, UserRole.driver],
      );

      // تحقق
      expect(result, isTrue);
      verify(mockAuthService.currentUser).called(1);
      verify(mockAuthService.getUserRole(any)).called(1);
    });

    test(
        'canActivate should return false for authenticated user with incorrect role',
        () async {
      // ترتيب
      when(mockAuthService.currentUser).thenReturn(MockUser());
      when(mockAuthService.getUserRole(any))
          .thenAnswer((_) async => UserRole.customer);

      // تنفيذ
      final result = await authGuard.canActivate(
        requiredRoles: [UserRole.admin, UserRole.driver],
      );

      // تحقق
      expect(result, isFalse);
      verify(mockAuthService.currentUser).called(1);
      verify(mockAuthService.getUserRole(any)).called(1);
    });

    test('canActivate should return false for unauthenticated user', () async {
      // ترتيب
      when(mockAuthService.currentUser).thenReturn(null);

      // تنفيذ
      final result = await authGuard.canActivate(
        requiredRoles: [UserRole.admin, UserRole.driver],
      );

      // تحقق
      expect(result, isFalse);
      verify(mockAuthService.currentUser).called(1);
      verifyNever(mockAuthService.getUserRole(any));
    });

    test('redirectToLogin should redirect to login page', () async {
      // ترتيب
      final mockRouter = MockGoRouter();
      when(mockRouter.go(any)).thenAnswer((_) async => null);

      // تنفيذ
      await authGuard.redirectToLogin(mockRouter);

      // تحقق
      verify(mockRouter.go('/login')).called(1);
    });

    test('redirectToHome should redirect to home page', () async {
      // ترتيب
      final mockRouter = MockGoRouter();
      when(mockRouter.go(any)).thenAnswer((_) async => null);

      // تنفيذ
      await authGuard.redirectToHome(mockRouter);

      // تحقق
      verify(mockRouter.go('/')).called(1);
    });

    test('redirectToUnauthorized should redirect to unauthorized page',
        () async {
      // ترتيب
      final mockRouter = MockGoRouter();
      when(mockRouter.go(any)).thenAnswer((_) async => null);

      // تنفيذ
      await authGuard.redirectToUnauthorized(mockRouter);

      // تحقق
      verify(mockRouter.go('/unauthorized')).called(1);
    });
  });

  group('AuthGuardWidget Tests', () {
    testWidgets('AuthGuardWidget should show child when user is authorized',
        (WidgetTester tester) async {
      // ترتيب
      when(mockAuthService.currentUser).thenReturn(MockUser());
      when(mockAuthService.getUserRole(any))
          .thenAnswer((_) async => UserRole.admin);

      final authNotifier = AuthNotifier(mockAuthService);

      // تنفيذ
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((_) => authNotifier),
          ],
          child: MaterialApp(
            home: AuthGuardWidget(
              requiredRoles: [UserRole.admin],
              child: const Text('Protected Content'),
              unauthorizedFallback: const Text('Unauthorized'),
              loadingFallback: const CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // انتظار تحميل البيانات
      await tester.pump();

      // تحقق
      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Unauthorized'), findsNothing);
    });

    testWidgets(
        'AuthGuardWidget should show unauthorized fallback when user is not authorized',
        (WidgetTester tester) async {
      // ترتيب
      when(mockAuthService.currentUser).thenReturn(MockUser());
      when(mockAuthService.getUserRole(any))
          .thenAnswer((_) async => UserRole.customer);

      final authNotifier = AuthNotifier(mockAuthService);

      // تنفيذ
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((_) => authNotifier),
          ],
          child: MaterialApp(
            home: AuthGuardWidget(
              requiredRoles: [UserRole.admin],
              child: const Text('Protected Content'),
              unauthorizedFallback: const Text('Unauthorized'),
              loadingFallback: const CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // انتظار تحميل البيانات
      await tester.pump();

      // تحقق
      expect(find.text('Protected Content'), findsNothing);
      expect(find.text('Unauthorized'), findsOneWidget);
    });
  });
}

// Mock classes
class MockUser {}

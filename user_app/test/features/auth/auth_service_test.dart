import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthService authService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockFirebaseAuth);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
    when(mockUser.email).thenReturn('test@example.com');
  });

  group('AuthService Tests', () {
    test('signInWithEmailAndPassword should return user on success', () async {
      // ترتيب
      const email = 'test@example.com';
      const password = 'Password123!';
      
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      // تنفيذ
      final result = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // تحقق
      expect(result, isNotNull);
      expect(result.uid, 'test_user_id');
      expect(result.email, 'test@example.com');
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).called(1);
    });

    test('createUserWithEmailAndPassword should return user on success', () async {
      // ترتيب
      const email = 'new@example.com';
      const password = 'Password123!';
      
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      // تنفيذ
      final result = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // تحقق
      expect(result, isNotNull);
      expect(result.uid, 'test_user_id');
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).called(1);
    });

    test('signOut should call Firebase signOut', () async {
      // ترتيب
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);

      // تنفيذ
      await authService.signOut();

      // تحقق
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('getCurrentUser should return current user', () async {
      // ترتيب
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // تنفيذ
      final result = authService.getCurrentUser();

      // تحقق
      expect(result, isNotNull);
      expect(result!.uid, 'test_user_id');
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('validatePassword should return true for strong password', () {
      // تنفيذ
      final result = authService.validatePassword('Password123!');

      // تحقق
      expect(result, true);
    });

    test('validatePassword should return false for weak password', () {
      // تنفيذ
      final result = authService.validatePassword('weak');

      // تحقق
      expect(result, false);
    });
  });
}

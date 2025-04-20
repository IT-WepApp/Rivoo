import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/features/auth/application/auth_service.dart';
import 'package:user_app/core/services/secure_storage_service.dart';
import 'package:user_app/core/utils/encryption_utils.dart';
import 'package:user_app/core/constants/app_constants.dart';

@GenerateMocks([
  FirebaseAuth, 
  UserCredential, 
  User, 
  SecureStorageService, 
  FirebaseFirestore,
  DocumentReference,
  CollectionReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockSecureStorageService mockSecureStorage;
  late AuthService authService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockDocumentReference mockDocumentReference;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockSecureStorage = MockSecureStorageService();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockDocumentReference = MockDocumentReference();
    mockCollectionReference = MockCollectionReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    
    authService = AuthService(mockSecureStorage, mockFirebaseAuth, mockFirestore);
    
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.getIdToken()).thenAnswer((_) async => 'test_token');
    when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
  });

  group('AuthService Tests', () {
    test('signIn should save auth token and user data securely', () async {
      // ترتيب
      const email = 'test@example.com';
      const password = 'Password123!';
      
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);
      
      when(mockSecureStorage.saveAuthToken(any, expiryMinutes: anyNamed('expiryMinutes')))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.saveRefreshToken(any))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.saveUserData(any))
          .thenAnswer((_) async => null);

      // تنفيذ
      final result = await authService.signIn(email, password);

      // تحقق
      expect(result, equals(mockUserCredential));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).called(1);
      
      // التحقق من استدعاء طرق التخزين الآمن
      verify(mockSecureStorage.saveAuthToken(any, expiryMinutes: AppConstants.sessionTimeoutMinutes)).called(1);
      verify(mockSecureStorage.saveRefreshToken(any)).called(1);
      verify(mockSecureStorage.saveUserData(any)).called(1);
    });

    test('signUp should save auth token and user data securely', () async {
      // ترتيب
      const email = 'new@example.com';
      const password = 'Password123!';
      
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);
      
      when(mockSecureStorage.saveAuthToken(any, expiryMinutes: anyNamed('expiryMinutes')))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.saveRefreshToken(any))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.saveUserData(any))
          .thenAnswer((_) async => null);
      when(mockUser.sendEmailVerification())
          .thenAnswer((_) async => null);

      // تنفيذ
      final result = await authService.signUp(email, password);

      // تحقق
      expect(result, equals(mockUserCredential));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).called(1);
      
      // التحقق من استدعاء طرق التخزين الآمن
      verify(mockSecureStorage.saveAuthToken(any, expiryMinutes: AppConstants.sessionTimeoutMinutes)).called(1);
      verify(mockSecureStorage.saveRefreshToken(any)).called(1);
      verify(mockSecureStorage.saveUserData(any)).called(1);
      verify(mockUser.sendEmailVerification()).called(1);
    });

    test('signOut should clear all secure storage data', () async {
      // ترتيب
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);
      when(mockSecureStorage.clearAll()).thenAnswer((_) async => null);

      // تنفيذ
      await authService.signOut();

      // تحقق
      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockSecureStorage.clearAll()).called(1);
    });

    test('getUserRole should get role from secure storage first if available', () async {
      // ترتيب
      final userData = {
        'uid': 'test_user_id',
        'role': 'admin',
      };
      
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);

      // تنفيذ
      final result = await authService.getUserRole('test_user_id');

      // تحقق
      expect(result, equals(UserRole.admin));
      verify(mockSecureStorage.getUserData()).called(1);
      // لا يجب استدعاء Firestore لأن البيانات موجودة في التخزين الآمن
      verifyNever(mockFirestore.collection(any).doc(any).get());
    });

    test('getUserRole should get role from Firestore if not in secure storage', () async {
      // ترتيب
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn({
        'role': 'driver',
      });

      // تنفيذ
      final result = await authService.getUserRole('test_user_id');

      // تحقق
      expect(result, equals(UserRole.driver));
      verify(mockSecureStorage.getUserData()).called(1);
      verify(mockFirestore.collection('users').doc('test_user_id').get()).called(1);
    });

    test('updateUserRole should update role in both Firestore and secure storage', () async {
      // ترتيب
      final userData = {
        'uid': 'test_user_id',
        'role': 'customer',
      };
      
      when(mockDocumentReference.update(any)).thenAnswer((_) async => null);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);
      when(mockSecureStorage.saveUserData(any)).thenAnswer((_) async => null);

      // تنفيذ
      await authService.updateUserRole('test_user_id', UserRole.admin);

      // تحقق
      verify(mockDocumentReference.update(any)).called(1);
      verify(mockSecureStorage.getUserData()).called(1);
      verify(mockSecureStorage.saveUserData(any)).called(1);
    });

    test('deleteAccount should delete user and clear secure storage', () async {
      // ترتيب
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockDocumentReference.delete()).thenAnswer((_) async => null);
      when(mockUser.delete()).thenAnswer((_) async => null);
      when(mockSecureStorage.clearAll()).thenAnswer((_) async => null);

      // تنفيذ
      await authService.deleteAccount();

      // تحقق
      verify(mockDocumentReference.delete()).called(1);
      verify(mockUser.delete()).called(1);
      verify(mockSecureStorage.clearAll()).called(1);
    });

    test('_isStrongPassword should return true for strong password', () {
      // تنفيذ
      // نحتاج إلى جعل الطريقة الخاصة قابلة للاختبار
      // في اختبار حقيقي، يمكننا استخدام التجاوز أو إعادة هيكلة الكود للاختبار
      
      // هذا مثال فقط، قد لا يعمل مباشرة بسبب أن الطريقة خاصة
      // final result = authService._isStrongPassword('Password123!');
      // expect(result, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_app/features/support/data/support_service.dart';
import 'package:user_app/features/support/domain/entities/ticket.dart';

// تعريف فئات وهمية يدوياً بدلاً من استخدام @GenerateMocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockUser extends Mock implements User {}
class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}
class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}
class MockQueryDocumentSnapshot<T> extends Mock implements QueryDocumentSnapshot<T> {}
class MockQuery<T> extends Mock implements Query<T> {}
class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseStorage mockStorage;
  late MockUser mockUser;
  late MockCollectionReference<Map<String, dynamic>> mockTicketsCollection;
  late MockCollectionReference<Map<String, dynamic>> mockMessagesCollection;
  late MockDocumentReference<Map<String, dynamic>> mockTicketDocument;
  late SupportService supportService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockStorage = MockFirebaseStorage();
    mockUser = MockUser();
    mockTicketsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockMessagesCollection = MockCollectionReference<Map<String, dynamic>>();
    mockTicketDocument = MockDocumentReference<Map<String, dynamic>>();

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockFirestore.collection('tickets')).thenReturn(mockTicketsCollection);
    when(mockTicketsCollection.doc(any)).thenReturn(mockTicketDocument);
    when(mockTicketDocument.collection('messages')).thenReturn(mockMessagesCollection);

    supportService = SupportService(
      firestore: mockFirestore,
      auth: mockAuth,
      storage: mockStorage,
    );
  });

  group('SupportService', () {
    test('createTicket should add a new ticket to Firestore', () async {
      // Arrange
      final ticket = Ticket(
        id: 'test-ticket-id',
        userId: 'test-user-id',
        subject: 'Test Subject',
        description: 'Test Description',
        status: TicketStatus.open,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: TicketCategory.order,
      );

      // استخدام when مع أي معلمة بدلاً من معلمة محددة
      when(mockTicketDocument.set(any)).thenAnswer((_) => Future.value());

      // Act
      await supportService.createTicket(ticket);

      // Assert
      verify(mockFirestore.collection('tickets')).called(1);
      verify(mockTicketsCollection.doc(ticket.id)).called(1);
      verify(mockTicketDocument.set(any)).called(1);
    });

    test('getTickets should return a list of tickets', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockTicketsCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) => Future.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(mockQueryDocSnapshot.id).thenReturn('test-ticket-id');
      when(mockQueryDocSnapshot.data()).thenReturn({
        'userId': 'test-user-id',
        'subject': 'Test Subject',
        'description': 'Test Description',
        'status': 'open',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'category': 'order',
      });

      // Act
      final tickets = await supportService.getTickets();

      // Assert
      expect(tickets.length, 1);
      expect(tickets[0].id, 'test-ticket-id');
      expect(tickets[0].subject, 'Test Subject');
      verify(mockTicketsCollection.where('userId', isEqualTo: 'test-user-id')).called(1);
    });

    test('getTicketById should return a ticket by id', () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockTicketDocument.get()).thenAnswer((_) => Future.value(mockSnapshot));
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn('test-ticket-id');
      when(mockSnapshot.data()).thenReturn({
        'userId': 'test-user-id',
        'subject': 'Test Subject',
        'description': 'Test Description',
        'status': 'open',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'category': 'order',
      });

      // Act
      final ticket = await supportService.getTicketById('test-ticket-id');

      // Assert
      expect(ticket!.id, 'test-ticket-id');
      expect(ticket.subject, 'Test Subject');
      verify(mockTicketsCollection.doc('test-ticket-id')).called(1);
      verify(mockTicketDocument.get()).called(1);
    });

    test('updateTicketStatus should update ticket status', () async {
      // Arrange
      // استخدام when مع أي معلمة بدلاً من معلمة محددة
      when(mockTicketDocument.update(any)).thenAnswer((_) => Future.value());

      // Act
      await supportService.updateTicketStatus('test-ticket-id', TicketStatus.closed);

      // Assert
      verify(mockTicketsCollection.doc('test-ticket-id')).called(1);
      verify(mockTicketDocument.update(any)).called(1);
    });
  });
}

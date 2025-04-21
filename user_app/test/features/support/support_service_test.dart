import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/features/support/application/support_service.dart';
import 'package:user_app/features/support/domain/ticket.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  FirebaseStorage,
  CollectionReference,
  DocumentReference,
  User,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseStorage mockStorage;
  late MockUser mockUser;
  late SupportService supportService;
  late MockCollectionReference<Map<String, dynamic>> mockTicketsCollection;
  late MockCollectionReference<Map<String, dynamic>> mockMessagesCollection;
  late MockDocumentReference<Map<String, dynamic>> mockTicketDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockStorage = MockFirebaseStorage();
    mockUser = MockUser();
    mockTicketsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockMessagesCollection = MockCollectionReference<Map<String, dynamic>>();
    mockTicketDoc = MockDocumentReference<Map<String, dynamic>>();

    supportService = SupportService(
      firestore: mockFirestore,
      auth: mockAuth,
      storage: mockStorage,
    );

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
    when(mockFirestore.collection('support_tickets'))
        .thenReturn(mockTicketsCollection);
    when(mockFirestore.collection('support_messages'))
        .thenReturn(mockMessagesCollection);
  });

  group('SupportService Tests', () {
    test('createTicket should create a new support ticket', () async {
      // ترتيب
      const subject = 'مشكلة في الطلب';
      const description = 'لم يصل الطلب في الوقت المحدد';
      const type = TicketType.orderIssue;
      const priority = TicketPriority.high;
      const orderId = 'order_123';

      when(mockTicketsCollection.doc(any)).thenReturn(mockTicketDoc);
      when(mockTicketDoc.set(any)).thenAnswer((_) async => null);
      when(mockMessagesCollection.doc(any)).thenReturn(mockTicketDoc);

      // تنفيذ
      final ticket = await supportService.createTicket(
        subject: subject,
        description: description,
        type: type,
        priority: priority,
        orderId: orderId,
      );

      // تحقق
      expect(ticket, isNotNull);
      expect(ticket.subject, subject);
      expect(ticket.description, description);
      expect(ticket.type, type);
      expect(ticket.priority, priority);
      expect(ticket.orderId, orderId);
      expect(ticket.status, TicketStatus.open);
      expect(ticket.userId, 'test_user_id');
      verify(mockTicketDoc.set(any))
          .called(2); // مرة للتذكرة ومرة للرسالة الأولية
    });

    test('sendMessage should add a message to a ticket', () async {
      // ترتيب
      const ticketId = 'ticket_123';
      const message = 'هل يمكنكم مساعدتي في هذه المشكلة؟';

      when(mockTicketsCollection.doc(ticketId)).thenReturn(mockTicketDoc);
      when(mockTicketDoc.get()).thenAnswer(
          (_) async => MockDocumentSnapshot<Map<String, dynamic>>());
      when(mockTicketDoc.exists).thenReturn(true);
      when(mockMessagesCollection.doc(any)).thenReturn(mockTicketDoc);
      when(mockTicketDoc.set(any)).thenAnswer((_) async => null);
      when(mockTicketDoc.update(any)).thenAnswer((_) async => null);

      // تنفيذ
      final supportMessage = await supportService.sendMessage(
        ticketId: ticketId,
        message: message,
      );

      // تحقق
      expect(supportMessage, isNotNull);
      expect(supportMessage.ticketId, ticketId);
      expect(supportMessage.message, message);
      expect(supportMessage.senderId, 'test_user_id');
      expect(supportMessage.isFromSupport, false);
      verify(mockTicketDoc.set(any)).called(1);
      verify(mockTicketDoc.update(any)).called(1);
    });

    test('updateTicketStatus should update ticket status', () async {
      // ترتيب
      const ticketId = 'ticket_123';
      const status = TicketStatus.closed;

      when(mockTicketsCollection.doc(ticketId)).thenReturn(mockTicketDoc);
      when(mockTicketDoc.get()).thenAnswer(
          (_) async => MockDocumentSnapshot<Map<String, dynamic>>());
      when(mockTicketDoc.exists).thenReturn(true);
      when(mockTicketDoc.update(any)).thenAnswer((_) async => null);

      // تنفيذ
      await supportService.updateTicketStatus(
        ticketId: ticketId,
        status: status,
      );

      // تحقق
      verify(mockTicketDoc.update(any)).called(1);
    });

    test('closeTicket should close a ticket', () async {
      // ترتيب
      const ticketId = 'ticket_123';

      when(mockTicketsCollection.doc(ticketId)).thenReturn(mockTicketDoc);
      when(mockTicketDoc.get()).thenAnswer(
          (_) async => MockDocumentSnapshot<Map<String, dynamic>>());
      when(mockTicketDoc.exists).thenReturn(true);
      when(mockTicketDoc.update(any)).thenAnswer((_) async => null);

      // تنفيذ
      await supportService.closeTicket(ticketId);

      // تحقق
      verify(mockTicketDoc.update(argThat(predicate<Map<String, dynamic>>(
          (map) => map['status'] == TicketStatus.closed.index)))).called(1);
    });

    test('reopenTicket should reopen a closed ticket', () async {
      // ترتيب
      const ticketId = 'ticket_123';

      when(mockTicketsCollection.doc(ticketId)).thenReturn(mockTicketDoc);
      when(mockTicketDoc.get()).thenAnswer(
          (_) async => MockDocumentSnapshot<Map<String, dynamic>>());
      when(mockTicketDoc.exists).thenReturn(true);
      when(mockTicketDoc.update(any)).thenAnswer((_) async => null);

      // تنفيذ
      await supportService.reopenTicket(ticketId);

      // تحقق
      verify(mockTicketDoc.update(argThat(predicate<Map<String, dynamic>>(
          (map) => map['status'] == TicketStatus.open.index)))).called(1);
    });
  });
}

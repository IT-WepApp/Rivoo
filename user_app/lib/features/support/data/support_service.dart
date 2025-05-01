import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_libs/entities/ticket_entity.dart';
import 'package:shared_libs/enums/ticket_status.dart';
import 'package:shared_libs/enums/ticket_category.dart';

/// خدمة الدعم الفني
class SupportService {
  /// مثيل Firestore
  final FirebaseFirestore firestore;
  
  /// مثيل FirebaseAuth
  final FirebaseAuth auth;
  
  /// مثيل FirebaseStorage
  final FirebaseStorage storage;

  /// إنشاء خدمة الدعم الفني
  SupportService({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  /// إنشاء تذكرة دعم جديدة
  Future<void> createTicket(Ticket ticket) async {
    await firestore.collection('tickets').doc(ticket.id).set({
      'userId': ticket.userId,
      'subject': ticket.subject,
      'description': ticket.description,
      'status': ticket.status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(ticket.createdAt),
      'updatedAt': Timestamp.fromDate(ticket.updatedAt),
      'category': ticket.category.toString().split('.').last,
      'attachments': ticket.attachments,
    });
  }

  /// الحصول على تذاكر المستخدم الحالي
  Future<List<Ticket>> getTickets() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Ticket(
        id: doc.id,
        userId: data['userId'],
        subject: data['subject'],
        description: data['description'],
        status: _parseTicketStatus(data['status']),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        category: _parseTicketCategory(data['category']),
        attachments: data['attachments'] != null
            ? List<String>.from(data['attachments'])
            : null,
      );
    }).toList();
  }

  /// الحصول على تذكرة بواسطة المعرف
  Future<Ticket?> getTicketById(String ticketId) async {
    final docSnapshot = await firestore.collection('tickets').doc(ticketId).get();

    if (!docSnapshot.exists) {
      return null;
    }

    final data = docSnapshot.data()!;
    return Ticket(
      id: docSnapshot.id,
      userId: data['userId'],
      subject: data['subject'],
      description: data['description'],
      status: _parseTicketStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      category: _parseTicketCategory(data['category']),
      attachments: data['attachments'] != null
          ? List<String>.from(data['attachments'])
          : null,
    );
  }

  /// تحديث حالة التذكرة
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    await firestore.collection('tickets').doc(ticketId).update({
      'status': status.toString().split('.').last,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// إرسال رسالة في تذكرة
  Future<void> sendMessage(TicketMessage message) async {
    await firestore
        .collection('tickets')
        .doc(message.ticketId)
        .collection('messages')
        .doc(message.id)
        .set({
      'senderId': message.senderId,
      'senderName': message.senderName,
      'isSupport': message.isSupport,
      'content': message.content,
      'sentAt': Timestamp.fromDate(message.sentAt),
      'attachments': message.attachments,
    });

    // تحديث وقت آخر تحديث للتذكرة
    await firestore.collection('tickets').doc(message.ticketId).update({
      'updatedAt': Timestamp.fromDate(message.sentAt),
    });
  }

  /// الحصول على رسائل تذكرة
  Future<List<TicketMessage>> getTicketMessages(String ticketId) async {
    final querySnapshot = await firestore
        .collection('tickets')
        .doc(ticketId)
        .collection('messages')
        .orderBy('sentAt')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return TicketMessage(
        id: doc.id,
        ticketId: ticketId,
        senderId: data['senderId'],
        senderName: data['senderName'],
        isSupport: data['isSupport'],
        content: data['content'],
        sentAt: (data['sentAt'] as Timestamp).toDate(),
        attachments: data['attachments'] != null
            ? List<String>.from(data['attachments'])
            : null,
      );
    }).toList();
  }

  /// تحويل النص إلى حالة تذكرة
  TicketStatus _parseTicketStatus(String status) {
    switch (status) {
      case 'open':
        return TicketStatus.open;
      case 'inProgress':
        return TicketStatus.inProgress;
      case 'closed':
        return TicketStatus.closed;
      case 'cancelled':
        return TicketStatus.cancelled;
      default:
        return TicketStatus.open;
    }
  }

  /// تحويل النص إلى فئة تذكرة
  TicketCategory _parseTicketCategory(String category) {
    switch (category) {
      case 'order':
        return TicketCategory.order;
      case 'product':
        return TicketCategory.product;
      case 'payment':
        return TicketCategory.payment;
      case 'account':
        return TicketCategory.account;
      case 'other':
        return TicketCategory.other;
      default:
        return TicketCategory.other;
    }
  }
}

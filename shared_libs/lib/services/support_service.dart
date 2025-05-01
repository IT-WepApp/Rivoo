import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias to avoid conflict
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/ticket_entity.dart'; // Updated import
import '../enums/ticket_status.dart';   // Updated import
import '../enums/ticket_category.dart'; // Updated import
import '../utils/logger.dart'; // Assuming logger exists

// --- Provider --- (Define where appropriate, e.g., in a providers file or app level)

/// مزود خدمة الدعم الفني الموحدة
final supportServiceProvider = Provider<SupportService>((ref) {
  // يمكنك الحصول على مثيلات Firestore/Auth/Storage من مزودات أخرى إذا لزم الأمر
  return SupportService(
    firestore: FirebaseFirestore.instance,
    auth: fb_auth.FirebaseAuth.instance,
    storage: FirebaseStorage.instance,
  );
});

// --- Service Implementation ---

/// خدمة الدعم الفني الموحدة
class SupportService {
  final FirebaseFirestore _firestore;
  final fb_auth.FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final AppLogger _logger = AppLogger(); // Assuming AppLogger exists

  SupportService({
    required FirebaseFirestore firestore,
    required fb_auth.FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  /// إنشاء تذكرة دعم جديدة
  Future<void> createTicket(TicketEntity ticket) async {
    try {
      await _firestore.collection('tickets').doc(ticket.id).set({
        'userId': ticket.userId,
        'subject': ticket.subject,
        'description': ticket.description,
        'status': ticket.status.toString().split('.').last,
        'createdAt': Timestamp.fromDate(ticket.createdAt),
        'updatedAt': Timestamp.fromDate(ticket.updatedAt),
        'category': ticket.category.toString().split('.').last,
        'attachments': ticket.attachments,
      });
      _logger.info('Support ticket ${ticket.id} created successfully for user ${ticket.userId}');
    } catch (e) {
      _logger.error('Failed to create support ticket ${ticket.id}', e, StackTrace.current);
      throw Exception('فشل إنشاء تذكرة الدعم: $e');
    }
  }

  /// الحصول على تذاكر المستخدم الحالي
  Future<List<TicketEntity>> getMyTickets() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _logger.warning('Attempted to get tickets without authenticated user.');
      throw Exception('المستخدم غير مصادق عليه.');
    }

    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // Order by creation date
          .get();

      final tickets = querySnapshot.docs.map((doc) {
        return _mapDocumentToTicketEntity(doc);
      }).toList();
       _logger.fine('Fetched ${tickets.length} tickets for user $userId');
      return tickets;
    } catch (e) {
       _logger.error('Failed to fetch tickets for user $userId', e, StackTrace.current);
      throw Exception('فشل الحصول على تذاكر الدعم: $e');
    }
  }

  /// الحصول على تذكرة بواسطة المعرف
  Future<TicketEntity?> getTicketById(String ticketId) async {
    try {
      final docSnapshot = await _firestore.collection('tickets').doc(ticketId).get();

      if (!docSnapshot.exists) {
        _logger.warning('Ticket $ticketId not found.');
        return null;
      }

      return _mapDocumentToTicketEntity(docSnapshot);
    } catch (e) {
      _logger.error('Failed to fetch ticket $ticketId', e, StackTrace.current);
      throw Exception('فشل الحصول على بيانات التذكرة: $e');
    }
  }

  /// تحديث حالة التذكرة (يمكن استخدامه بواسطة المستخدم أو الدعم)
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(), // Use server timestamp
      });
       _logger.info('Ticket $ticketId status updated to $status');
    } catch (e) {
       _logger.error('Failed to update status for ticket $ticketId', e, StackTrace.current);
      throw Exception('فشل تحديث حالة التذكرة: $e');
    }
  }

  /// إرسال رسالة في تذكرة
  Future<void> sendMessage(TicketMessageEntity message) async {
    try {
      // 1. إضافة الرسالة إلى المجموعة الفرعية
      await _firestore
          .collection('tickets')
          .doc(message.ticketId)
          .collection('messages')
          .doc(message.id) // Use provided ID or let Firestore generate one
          .set({
        'senderId': message.senderId,
        'senderName': message.senderName,
        'isSupport': message.isSupport,
        'content': message.content,
        'sentAt': Timestamp.fromDate(message.sentAt),
        'attachments': message.attachments,
      });

      // 2. تحديث وقت آخر تحديث للتذكرة الرئيسية
      await _firestore.collection('tickets').doc(message.ticketId).update({
        'updatedAt': Timestamp.fromDate(message.sentAt),
        // يمكنك أيضاً تحديث الحالة هنا إذا لزم الأمر، مثلاً إلى 'inProgress'
        // 'status': TicketStatus.inProgress.toString().split('.').last,
      });
      _logger.info('Message sent in ticket ${message.ticketId} by sender ${message.senderId}');
    } catch (e) {
      _logger.error('Failed to send message in ticket ${message.ticketId}', e, StackTrace.current);
      throw Exception('فشل إرسال الرسالة: $e');
    }
  }

  /// الحصول على رسائل تذكرة (مرتبة حسب تاريخ الإرسال)
  Stream<List<TicketMessageEntity>> getTicketMessagesStream(String ticketId) {
     try {
        return _firestore
            .collection('tickets')
            .doc(ticketId)
            .collection('messages')
            .orderBy('sentAt', descending: false) // Order chronologically
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) {
                  return _mapDocumentToTicketMessageEntity(doc, ticketId);
                }).toList());
     } catch (e) {
        _logger.error('Failed to get message stream for ticket $ticketId', e, StackTrace.current);
        // Return an empty stream or stream with error
        return Stream.value([]);
        // Or: return Stream.error(Exception('فشل الحصول على الرسائل: $e'));
     }
  }

  // --- Helper Methods ---

  /// تحويل وثيقة Firestore إلى TicketEntity
  TicketEntity _mapDocumentToTicketEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Cast for safety
    return TicketEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      status: _parseTicketStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      category: _parseTicketCategory(data['category']),
      attachments: data['attachments'] != null
          ? List<String>.from(data['attachments'])
          : null,
    );
  }

  /// تحويل وثيقة Firestore إلى TicketMessageEntity
  TicketMessageEntity _mapDocumentToTicketMessageEntity(DocumentSnapshot doc, String ticketId) {
     final data = doc.data() as Map<String, dynamic>; // Cast for safety
     return TicketMessageEntity(
        id: doc.id,
        ticketId: ticketId, // Pass ticketId for context
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? '',
        isSupport: data['isSupport'] ?? false,
        content: data['content'] ?? '',
        sentAt: (data['sentAt'] as Timestamp? ?? Timestamp.now()).toDate(),
        attachments: data['attachments'] != null
            ? List<String>.from(data['attachments'])
            : null,
      );
  }


  /// تحويل النص إلى حالة تذكرة
  TicketStatus _parseTicketStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'inprogress':
        return TicketStatus.inProgress;
      case 'closed':
        return TicketStatus.closed;
      case 'cancelled':
        return TicketStatus.cancelled;
      default:
         _logger.warning('Unknown ticket status string: $statusString. Defaulting to open.');
        return TicketStatus.open; // Default status
    }
  }

  /// تحويل النص إلى فئة تذكرة
  TicketCategory _parseTicketCategory(String? categoryString) {
    switch (categoryString?.toLowerCase()) {
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
        _logger.warning('Unknown ticket category string: $categoryString. Defaulting to other.');
        return TicketCategory.other; // Default category
    }
  }

  // يمكنك إضافة وظائف لرفع المرفقات إلى Firebase Storage هنا
  // Future<String> uploadAttachment(String ticketId, File file) async { ... }
}


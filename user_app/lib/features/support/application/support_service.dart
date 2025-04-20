import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:user_app/features/support/domain/ticket.dart';

/// مزود خدمة الدعم
final supportServiceProvider = Provider<SupportService>((ref) {
  return SupportService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    storage: FirebaseStorage.instance,
  );
});

/// خدمة الدعم
class SupportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  SupportService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  /// الحصول على مرجع مجموعة التذاكر
  CollectionReference get _ticketsCollection =>
      _firestore.collection('support_tickets');

  /// الحصول على مرجع مجموعة الرسائل
  CollectionReference get _messagesCollection =>
      _firestore.collection('support_messages');

  /// إنشاء تذكرة دعم جديدة
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required TicketType type,
    TicketPriority priority = TicketPriority.medium,
    String? orderId,
  }) async {
    // التحقق من تسجيل الدخول
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لإنشاء تذكرة دعم');
    }

    // إنشاء معرف فريد للتذكرة
    final ticketId = _uuid.v4();
    
    // إنشاء كائن التذكرة
    final ticket = SupportTicket(
      id: ticketId,
      userId: user.uid,
      subject: subject,
      description: description,
      status: TicketStatus.open,
      priority: priority,
      type: type,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      orderId: orderId,
    );

    // حفظ التذكرة في قاعدة البيانات
    await _ticketsCollection.doc(ticketId).set(ticket.toMap());

    // إنشاء رسالة أولية للتذكرة
    final initialMessage = SupportMessage(
      id: _uuid.v4(),
      ticketId: ticketId,
      message: description,
      senderId: user.uid,
      isFromSupport: false,
      timestamp: DateTime.now(),
    );

    // حفظ الرسالة في قاعدة البيانات
    await _messagesCollection.doc(initialMessage.id).set(initialMessage.toMap());

    return ticket;
  }

  /// الحصول على قائمة التذاكر للمستخدم الحالي
  Stream<List<SupportTicket>> getUserTickets() {
    // التحقق من تسجيل الدخول
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // الاستعلام عن التذاكر الخاصة بالمستخدم
    return _ticketsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SupportTicket.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// الحصول على تذكرة محددة
  Stream<SupportTicket?> getTicket(String ticketId) {
    return _ticketsCollection.doc(ticketId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return SupportTicket.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// الحصول على رسائل تذكرة محددة
  Stream<List<SupportMessage>> getTicketMessages(String ticketId) {
    return _messagesCollection
        .where('ticketId', isEqualTo: ticketId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SupportMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// إرسال رسالة جديدة إلى تذكرة
  Future<SupportMessage> sendMessage({
    required String ticketId,
    required String message,
    String? attachmentPath,
  }) async {
    // التحقق من تسجيل الدخول
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لإرسال رسالة');
    }

    // التحقق من وجود التذكرة
    final ticketDoc = await _ticketsCollection.doc(ticketId).get();
    if (!ticketDoc.exists) {
      throw Exception('التذكرة غير موجودة');
    }

    // إنشاء معرف فريد للرسالة
    final messageId = _uuid.v4();
    
    // رفع المرفق إذا وجد
    String? attachmentUrl;
    if (attachmentPath != null) {
      final ref = _storage.ref().child('support_attachments/$ticketId/$messageId');
      await ref.putFile(await new File(attachmentPath).create());
      attachmentUrl = await ref.getDownloadURL();
    }

    // إنشاء كائن الرسالة
    final supportMessage = SupportMessage(
      id: messageId,
      ticketId: ticketId,
      message: message,
      senderId: user.uid,
      attachmentUrl: attachmentUrl,
      isFromSupport: false,
      timestamp: DateTime.now(),
    );

    // حفظ الرسالة في قاعدة البيانات
    await _messagesCollection.doc(messageId).set(supportMessage.toMap());

    // تحديث وقت التحديث في التذكرة
    await _ticketsCollection.doc(ticketId).update({
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'status': TicketStatus.pending.index, // تغيير الحالة إلى قيد الانتظار
    });

    return supportMessage;
  }

  /// تحديث حالة تذكرة
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    // التحقق من تسجيل الدخول
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لتحديث حالة التذكرة');
    }

    // التحقق من وجود التذكرة
    final ticketDoc = await _ticketsCollection.doc(ticketId).get();
    if (!ticketDoc.exists) {
      throw Exception('التذكرة غير موجودة');
    }

    // التحقق من ملكية التذكرة
    final ticket = SupportTicket.fromMap(ticketDoc.data() as Map<String, dynamic>);
    if (ticket.userId != user.uid) {
      throw Exception('لا يمكنك تحديث تذكرة لا تملكها');
    }

    // تحديث حالة التذكرة
    final updates = {
      'status': status.index,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    // إضافة وقت الإغلاق إذا كانت الحالة مغلقة
    if (status == TicketStatus.closed) {
      updates['closedAt'] = DateTime.now().millisecondsSinceEpoch;
    }

    await _ticketsCollection.doc(ticketId).update(updates);
  }

  /// تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead(String ticketId) async {
    // التحقق من تسجيل الدخول
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لتعليم الرسائل كمقروءة');
    }

    // الحصول على الرسائل غير المقروءة من الدعم
    final unreadMessages = await _messagesCollection
        .where('ticketId', isEqualTo: ticketId)
        .where('isFromSupport', isEqualTo: true)
        .where('isRead', isEqualTo: false)
        .get();

    // تعليم كل رسالة كمقروءة
    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // تحديث عدد الرسائل غير المقروءة في التذكرة
    batch.update(_ticketsCollection.doc(ticketId), {'unreadMessages': 0});

    await batch.commit();
  }

  /// إغلاق تذكرة
  Future<void> closeTicket(String ticketId) async {
    await updateTicketStatus(
      ticketId: ticketId,
      status: TicketStatus.closed,
    );
  }

  /// إعادة فتح تذكرة
  Future<void> reopenTicket(String ticketId) async {
    await updateTicketStatus(
      ticketId: ticketId,
      status: TicketStatus.open,
    );
  }
}

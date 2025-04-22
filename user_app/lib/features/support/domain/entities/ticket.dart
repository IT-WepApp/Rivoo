import 'package:user_app/core/architecture/domain/entity.dart';

/// حالات تذكرة الدعم
enum TicketStatus {
  /// مفتوحة
  open,
  
  /// قيد المعالجة
  inProgress,
  
  /// مغلقة
  closed,
  
  /// ملغية
  cancelled
}

/// فئات تذكرة الدعم
enum TicketCategory {
  /// طلب
  order,
  
  /// منتج
  product,
  
  /// دفع
  payment,
  
  /// حساب
  account,
  
  /// أخرى
  other
}

/// كيان تذكرة الدعم
class Ticket extends Entity {
  /// معرف المستخدم
  final String userId;
  
  /// عنوان التذكرة
  final String subject;
  
  /// وصف المشكلة
  final String description;
  
  /// حالة التذكرة
  final TicketStatus status;
  
  /// تاريخ الإنشاء
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث
  final DateTime updatedAt;
  
  /// فئة التذكرة
  final TicketCategory category;
  
  /// المرفقات (اختياري)
  final List<String>? attachments;

  /// إنشاء تذكرة دعم
  const Ticket({
    required String id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.attachments,
  }) : super(id: id);

  @override
  List<Object?> get props => [
        id,
        userId,
        subject,
        description,
        status,
        createdAt,
        updatedAt,
        category,
        attachments,
      ];
}

/// كيان رسالة في تذكرة الدعم
class TicketMessage extends Entity {
  /// معرف التذكرة
  final String ticketId;
  
  /// معرف المرسل
  final String senderId;
  
  /// اسم المرسل
  final String senderName;
  
  /// هل المرسل هو فريق الدعم
  final bool isSupport;
  
  /// محتوى الرسالة
  final String content;
  
  /// تاريخ الإرسال
  final DateTime sentAt;
  
  /// المرفقات (اختياري)
  final List<String>? attachments;

  /// إنشاء رسالة تذكرة دعم
  const TicketMessage({
    required String id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.isSupport,
    required this.content,
    required this.sentAt,
    this.attachments,
  }) : super(id: id);

  @override
  List<Object?> get props => [
        id,
        ticketId,
        senderId,
        senderName,
        isSupport,
        content,
        sentAt,
        attachments,
      ];
}

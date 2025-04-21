import 'package:flutter/foundation.dart';

/// حالة تذكرة الدعم
enum TicketStatus {
  open, // مفتوحة
  pending, // قيد الانتظار
  resolved, // تم الحل
  closed // مغلقة
}

/// أولوية تذكرة الدعم
enum TicketPriority {
  low, // منخفضة
  medium, // متوسطة
  high, // عالية
  urgent // عاجلة
}

/// نوع تذكرة الدعم
enum TicketType {
  general, // استفسار عام
  orderIssue, // مشكلة في الطلب
  paymentIssue, // مشكلة في الدفع
  accountIssue, // مشكلة في الحساب
  appIssue, // مشكلة في التطبيق
  suggestion, // اقتراح
  other // أخرى
}

/// نموذج رسالة الدعم
class SupportMessage {
  final String id;
  final String ticketId;
  final String message;
  final String senderId;
  final String? attachmentUrl;
  final bool isFromSupport;
  final DateTime timestamp;
  final bool isRead;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.senderId,
    this.attachmentUrl,
    required this.isFromSupport,
    required this.timestamp,
    this.isRead = false,
  });

  SupportMessage copyWith({
    String? id,
    String? ticketId,
    String? message,
    String? senderId,
    String? attachmentUrl,
    bool? isFromSupport,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return SupportMessage(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isFromSupport: isFromSupport ?? this.isFromSupport,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'message': message,
      'senderId': senderId,
      'attachmentUrl': attachmentUrl,
      'isFromSupport': isFromSupport,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      id: map['id'] ?? '',
      ticketId: map['ticketId'] ?? '',
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      attachmentUrl: map['attachmentUrl'],
      isFromSupport: map['isFromSupport'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'] ?? false,
    );
  }

  @override
  String toString() {
    return 'SupportMessage(id: $id, ticketId: $ticketId, message: $message, senderId: $senderId, attachmentUrl: $attachmentUrl, isFromSupport: $isFromSupport, timestamp: $timestamp, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SupportMessage &&
        other.id == id &&
        other.ticketId == ticketId &&
        other.message == message &&
        other.senderId == senderId &&
        other.attachmentUrl == attachmentUrl &&
        other.isFromSupport == isFromSupport &&
        other.timestamp == timestamp &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ticketId.hashCode ^
        message.hashCode ^
        senderId.hashCode ^
        attachmentUrl.hashCode ^
        isFromSupport.hashCode ^
        timestamp.hashCode ^
        isRead.hashCode;
  }
}

/// نموذج تذكرة الدعم
class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final TicketType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;
  final String? orderId;
  final List<SupportMessage> messages;
  final int unreadMessages;
  final String? assignedToId;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
    this.orderId,
    this.messages = const [],
    this.unreadMessages = 0,
    this.assignedToId,
  });

  SupportTicket copyWith({
    String? id,
    String? userId,
    String? subject,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    TicketType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    String? orderId,
    List<SupportMessage>? messages,
    int? unreadMessages,
    String? assignedToId,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      orderId: orderId ?? this.orderId,
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      assignedToId: assignedToId ?? this.assignedToId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'description': description,
      'status': status.index,
      'priority': priority.index,
      'type': type.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'closedAt': closedAt?.millisecondsSinceEpoch,
      'orderId': orderId,
      'messages': messages.map((x) => x.toMap()).toList(),
      'unreadMessages': unreadMessages,
      'assignedToId': assignedToId,
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      status: TicketStatus.values[map['status'] ?? 0],
      priority: TicketPriority.values[map['priority'] ?? 0],
      type: TicketType.values[map['type'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      closedAt: map['closedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['closedAt'])
          : null,
      orderId: map['orderId'],
      messages: List<SupportMessage>.from(
          map['messages']?.map((x) => SupportMessage.fromMap(x)) ?? []),
      unreadMessages: map['unreadMessages'] ?? 0,
      assignedToId: map['assignedToId'],
    );
  }

  @override
  String toString() {
    return 'SupportTicket(id: $id, userId: $userId, subject: $subject, description: $description, status: $status, priority: $priority, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt, orderId: $orderId, messages: $messages, unreadMessages: $unreadMessages, assignedToId: $assignedToId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SupportTicket &&
        other.id == id &&
        other.userId == userId &&
        other.subject == subject &&
        other.description == description &&
        other.status == status &&
        other.priority == priority &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.closedAt == closedAt &&
        other.orderId == orderId &&
        listEquals(other.messages, messages) &&
        other.unreadMessages == unreadMessages &&
        other.assignedToId == assignedToId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        subject.hashCode ^
        description.hashCode ^
        status.hashCode ^
        priority.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        closedAt.hashCode ^
        orderId.hashCode ^
        messages.hashCode ^
        unreadMessages.hashCode ^
        assignedToId.hashCode;
  }
}

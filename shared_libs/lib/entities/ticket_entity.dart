import 'package:equatable/equatable.dart';
import '../enums/ticket_status.dart';
import '../enums/ticket_category.dart';

/// كيان تذكرة الدعم الموحد
class TicketEntity extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketCategory category;
  final List<String>? attachments;

  const TicketEntity({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.attachments,
  });

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

  // يمكن إضافة copyWith إذا لزم الأمر
  TicketEntity copyWith({
    String? id,
    String? userId,
    String? subject,
    String? description,
    TicketStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    TicketCategory? category,
    List<String>? attachments,
  }) {
    return TicketEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
    );
  }
}

/// كيان رسالة تذكرة الدعم الموحد
class TicketMessageEntity extends Equatable {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final bool isSupport;
  final String content;
  final DateTime sentAt;
  final List<String>? attachments;

  const TicketMessageEntity({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.isSupport,
    required this.content,
    required this.sentAt,
    this.attachments,
  });

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

  // يمكن إضافة copyWith إذا لزم الأمر
  TicketMessageEntity copyWith({
    String? id,
    String? ticketId,
    String? senderId,
    String? senderName,
    bool? isSupport,
    String? content,
    DateTime? sentAt,
    List<String>? attachments,
  }) {
    return TicketMessageEntity(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isSupport: isSupport ?? this.isSupport,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      attachments: attachments ?? this.attachments,
    );
  }
}


import 'package:user_app/core/architecture/domain/entity.dart';

/// كيان التذكرة
class Ticket extends Entity {
  /// معرف المستخدم الذي أنشأ التذكرة
  final String userId;
  
  /// عنوان التذكرة
  final String title;
  
  /// وصف المشكلة
  final String description;
  
  /// حالة التذكرة
  final TicketStatus status;
  
  /// أولوية التذكرة
  final TicketPriority priority;
  
  /// تاريخ إنشاء التذكرة
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للتذكرة
  final DateTime updatedAt;
  
  /// تاريخ إغلاق التذكرة
  final DateTime? closedAt;

  /// إنشاء كيان التذكرة
  const Ticket({
    required String id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  }) : super(id: id);

  /// نسخة جديدة من الكيان مع تحديث بعض الحقول
  Ticket copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        status,
        priority,
        createdAt,
        updatedAt,
        closedAt,
      ];
}

/// حالة التذكرة
enum TicketStatus {
  /// جديدة
  new_,
  
  /// قيد المعالجة
  inProgress,
  
  /// بانتظار رد المستخدم
  waitingForUserResponse,
  
  /// مغلقة
  closed,
  
  /// ملغاة
  cancelled,
}

/// أولوية التذكرة
enum TicketPriority {
  /// منخفضة
  low,
  
  /// متوسطة
  medium,
  
  /// عالية
  high,
  
  /// حرجة
  critical,
}

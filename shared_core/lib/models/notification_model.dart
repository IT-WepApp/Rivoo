import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// نموذج الإشعار
/// يستخدم لتمثيل بيانات الإشعارات في التطبيق
@JsonSerializable()
class NotificationModel extends Equatable {
  /// معرف الإشعار الفريد
  final String id;
  
  /// معرف المستخدم المستلم للإشعار
  final String userId;
  
  /// عنوان الإشعار
  final String title;
  
  /// نص الإشعار
  final String body;
  
  /// نوع الإشعار
  final NotificationType type;
  
  /// معرف الكائن المرتبط بالإشعار (مثل معرف الطلب أو المنتج)
  final String? relatedId;
  
  /// بيانات إضافية للإشعار
  final Map<String, dynamic>? data;
  
  /// رابط الصورة المرفقة بالإشعار (إن وجدت)
  final String? imageUrl;
  
  /// ما إذا كان الإشعار مقروءاً
  final bool isRead;
  
  /// تاريخ إنشاء الإشعار
  final DateTime createdAt;
  
  /// تاريخ قراءة الإشعار (إن وجد)
  final DateTime? readAt;

  /// منشئ النموذج
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.data,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? relatedId,
    Map<String, dynamic>? data,
    String? imageUrl,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// وضع علامة "مقروء" على الإشعار
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// إنشاء نموذج من Map
  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        relatedId,
        data,
        imageUrl,
        isRead,
        createdAt,
        readAt,
      ];
}

/// تعداد أنواع الإشعارات
enum NotificationType {
  order,          // إشعار متعلق بالطلبات
  promotion,      // إشعار ترويجي
  system,         // إشعار نظام
  payment,        // إشعار متعلق بالدفع
  delivery,       // إشعار متعلق بالتوصيل
  product,        // إشعار متعلق بالمنتجات
  account,        // إشعار متعلق بالحساب
  chat,           // إشعار محادثة
  other,          // أخرى
}

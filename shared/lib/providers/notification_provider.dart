import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/notification_service.dart';
import 'package:shared/models/notification_model.dart'; // ✅ تم نقل الكلاس هنا

/// نموذج حالة الإشعارات
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  /// نسخة أولية من الحالة
  factory NotificationState.initial() {
    return NotificationState(notifications: []);
  }

  /// نسخة من الحالة مع تحميل
  NotificationState copyWithLoading() {
    return NotificationState(
      notifications: notifications,
      isLoading: true,
      error: null,
      unreadCount: unreadCount,
    );
  }

  /// نسخة من الحالة مع خطأ
  NotificationState copyWithError(String errorMessage) {
    return NotificationState(
      notifications: notifications,
      isLoading: false,
      error: errorMessage,
      unreadCount: unreadCount,
    );
  }

  /// نسخة من الحالة مع إشعارات جديدة
  NotificationState copyWithNotifications(
      List<NotificationModel> newNotifications) {
    final unread =
        newNotifications.where((notification) => !notification.isRead).length;
    return NotificationState(
      notifications: newNotifications,
      isLoading: false,
      error: null,
      unreadCount: unread,
    );
  }
}

/// مزود خدمة الإشعارات
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// مزود حالة الإشعارات
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});

/// مدير حالة الإشعارات
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationNotifier(this._notificationService)
      : super(NotificationState.initial()) {
    fetchNotifications();
  }

  /// جلب الإشعارات
  Future<void> fetchNotifications() async {
    state = state.copyWithLoading();

    try {
      final notifications = await _notificationService.getNotifications();
      state = state.copyWithNotifications(notifications);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            timestamp: notification.timestamp,
            isRead: true,
            imageUrl: notification.imageUrl,
            data: notification.data,
          );
        }
        return notification;
      }).toList();

      state = state.copyWithNotifications(updatedNotifications);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      final updatedNotifications = state.notifications.map((notification) {
        return NotificationModel(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          timestamp: notification.timestamp,
          isRead: true,
          imageUrl: notification.imageUrl,
          data: notification.data,
        );
      }).toList();

      state = state.copyWithNotifications(updatedNotifications);
    } catch (e) {
      state = state.copyWithError(e.toString());
    }
  }

  /// إضافة إشعار جديد
  void addNotification(NotificationModel notification) {
    final updatedNotifications = [notification, ...state.notifications];
    state = state.copyWithNotifications(updatedNotifications);
  }
}

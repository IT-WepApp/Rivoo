import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../../../shared_libs/lib/theme/app_colors.dart';

/// صفحة إدارة الإشعارات للبائع
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  // تغيير نوع المتغير ليتوافق مع البيانات المرجعة من getSellerNotifications
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // استخدام مزود sellerNotificationsProvider بدلاً من استدعاء getSellerNotifications مباشرة
      ref.listen(sellerNotificationsProvider, (previous, next) {
        next.when(
          data: (snapshot) {
            final notificationsList = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'title': data['title'] ?? 'إشعار',
                'message': data['body'] ?? '',
                'type': data['type'] ?? 'default',
                'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
                'isRead': data['read'] ?? false,
              };
            }).toList();

            setState(() {
              _notifications = notificationsList;
              _isLoading = false;
            });
          },
          loading: () {
            setState(() {
              _isLoading = true;
            });
          },
          error: (error, stackTrace) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'حدث خطأ أثناء تحميل الإشعارات: $error';
            });
          },
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل الإشعارات: $e';
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markNotificationAsRead(notificationId);

      // تحديث القائمة المحلية
      setState(() {
        final notificationIndex =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (notificationIndex != -1) {
          _notifications[notificationIndex]['isRead'] = true;
        }

        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث حالة الإشعار: $e';
      });
    }
  }

  Future<void> _markAllAsRead() async {
    // التحقق من وجود إشعارات غير مقروءة
    final unreadNotifications =
        _notifications.where((n) => !(n['isRead'] as bool? ?? false)).toList();
    if (unreadNotifications.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جميع الإشعارات مقروءة بالفعل'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAllNotificationsAsRead();

      // تحديث القائمة المحلية
      setState(() {
        for (final notification in _notifications) {
          notification['isRead'] = true;
        }

        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث جميع الإشعارات كمقروءة'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث حالة الإشعارات: $e';
      });
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (mounted) {
      final confirmed = await AppWidgets.showConfirmDialog(
        context: context,
        title: 'حذف الإشعار',
        message: 'هل أنت متأكد من رغبتك في حذف هذا الإشعار؟',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        isDangerous: true,
      );

      if (!confirmed) {
        return;
      }
    } else {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.deleteNotification(notificationId);

      // تحديث القائمة المحلية
      setState(() {
        _notifications.removeWhere((n) => n['id'] == notificationId);
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الإشعار بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل حذف الإشعار: $e';
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    if (_notifications.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد إشعارات للحذف'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (mounted) {
      final confirmed = await AppWidgets.showConfirmDialog(
        context: context,
        title: 'حذف جميع الإشعارات',
        message:
            'هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
        confirmText: 'حذف الكل',
        cancelText: 'إلغاء',
        isDangerous: true,
      );

      if (!confirmed) {
        return;
      }
    } else {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.clearAllNotifications();

      // تحديث القائمة المحلية
      setState(() {
        _notifications.clear();
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف جميع الإشعارات بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل حذف الإشعارات: $e';
      });
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'product':
        return Icons.inventory;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.system_update;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.info;
      case 'product':
        return AppColors.success;
      case 'payment':
        return AppColors.secondary;
      case 'system':
        return AppColors.warning;
      case 'alert':
        return AppColors.error;
      default:
        return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'تحديد الكل كمقروء',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllNotifications,
            tooltip: 'حذف الكل',
          ),
        ],
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل الإشعارات...')
          : _isSubmitting
              ? AppWidgets.loadingIndicator(message: 'جاري تنفيذ العملية...')
              : _errorMessage.isNotEmpty && _notifications.isEmpty
                  ? AppWidgets.errorMessage(
                      message: _errorMessage,
                      onRetry: _loadNotifications,
                    )
                  : _buildNotificationsList(theme),
    );
  }

  Widget _buildNotificationsList(ThemeData theme) {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات حالياً',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final notificationId = notification['id'] as String;
        final title = notification['title'] as String? ?? 'إشعار';
        final message = notification['message'] as String? ?? '';
        final type = notification['type'] as String? ?? 'default';
        final timestamp =
            notification['timestamp'] as DateTime? ?? DateTime.now();
        final isRead = notification['isRead'] as bool? ?? false;

        return Dismissible(
          key: Key(notificationId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.error,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            await _deleteNotification(notificationId);
            return true;
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isRead ? null : theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isRead
                  ? BorderSide.none
                  : BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: _getNotificationColor(type).withOpacity(0.1),
                child: Icon(
                  _getNotificationIcon(type),
                  color: _getNotificationColor(type),
                ),
              ),
              title: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timestamp.day}/${timestamp.month}/${timestamp.year} - ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              trailing: isRead
                  ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteNotification(notificationId),
                      tooltip: 'حذف',
                    )
                  : IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () => _markAsRead(notificationId),
                      tooltip: 'تحديد كمقروء',
                    ),
              onTap: isRead ? null : () => _markAsRead(notificationId),
            ),
          ),
        );
      },
    );
  }
}

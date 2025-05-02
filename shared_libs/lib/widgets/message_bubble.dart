import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';

/// نوع فقاعة الرسالة
enum MessageBubbleType {
  /// رسالة من المستخدم
  user,
  
  /// رسالة من فريق الدعم
  support,
}

/// فقاعة رسالة
class MessageBubble extends StatelessWidget {
  /// معرف الرسالة
  final String id;
  
  /// نص الرسالة
  final String message;
  
  /// تاريخ الرسالة
  final DateTime timestamp;
  
  /// نوع فقاعة الرسالة
  final MessageBubbleType type;
  
  /// اسم المرسل
  final String? senderName;

  /// إنشاء فقاعة رسالة
  const MessageBubble({
    Key? key,
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
    this.senderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = type == MessageBubbleType.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المرسل (للدعم فقط)
            if (!isUser && senderName != null) ...[
              Text(
                senderName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isUser ? Colors.white : AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
            ],
            
            // نص الرسالة
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isUser ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // الوقت
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: isUser
                      ? Colors.white.withOpacity(0.7)
                      : AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تنسيق الوقت
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

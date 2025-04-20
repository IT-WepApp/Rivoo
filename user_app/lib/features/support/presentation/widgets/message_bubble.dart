import 'package:flutter/material.dart';
import 'package:user_app/features/support/domain/ticket.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final SupportMessage message;
  final bool showAvatar;

  const MessageBubble({
    Key? key,
    required this.message,
    this.showAvatar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFromSupport = message.isFromSupport;
    final alignment = isFromSupport ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // عرض معلومات المرسل فقط إذا كان مطلوباً
          if (showAvatar) ...[
            Row(
              mainAxisAlignment: isFromSupport ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (isFromSupport) _buildAvatar(context),
                const SizedBox(width: 8),
                Text(
                  isFromSupport ? 'فريق الدعم' : 'أنت',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!isFromSupport) ...[
                  const SizedBox(width: 8),
                  _buildAvatar(context),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],
          
          // فقاعة الرسالة
          Row(
            mainAxisAlignment: isFromSupport ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // وقت الرسالة للرسائل من الدعم
              if (isFromSupport)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ),
              
              // محتوى الرسالة
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isFromSupport
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.0).copyWith(
                      bottomLeft: isFromSupport ? Radius.zero : null,
                      bottomRight: !isFromSupport ? Radius.zero : null,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نص الرسالة
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isFromSupport
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      
                      // المرفقات إذا وجدت
                      if (message.attachmentUrl != null) ...[
                        const SizedBox(height: 8),
                        _buildAttachment(context, message.attachmentUrl!),
                      ],
                    ],
                  ),
                ),
              ),
              
              // وقت الرسالة للرسائل من المستخدم
              if (!isFromSupport)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء الصورة الرمزية
  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: message.isFromSupport
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: Icon(
        message.isFromSupport ? Icons.support_agent : Icons.person,
        size: 16,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  // بناء المرفق
  Widget _buildAttachment(BuildContext context, String url) {
    // تحديد نوع المرفق
    final isImage = url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.gif');

    if (isImage) {
      // عرض الصورة
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.error),
              ),
            );
          },
        ),
      );
    } else {
      // عرض رابط للملف
      return InkWell(
        onTap: () {
          // فتح الملف
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _getFileName(url),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // استخراج اسم الملف من الرابط
  String _getFileName(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    return 'ملف مرفق';
  }

  // تنسيق وقت الرسالة
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays < 1) {
      return timeago.format(time, locale: 'ar');
    } else if (difference.inDays < 7) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
